part of couclient;

class NetChatManager {
	WebSocket _connection;
	static String prefix = Configs.baseAddress.contains('localhost')?'ws://':'wss://';
	String _chatServerUrl = '$prefix${Configs.websocketServerAddress}/chat';

	NetChatManager() {
		setupWebsocket(_chatServerUrl);

		new Service(['chatEvent'], (event) {
			if (event["statusMessage"] == "ping") {
				//used to keep the connection alive
				transmit('outgoingChatEvent', {'statusMessage':'pong'});
			} else if (event["muted"] != null) {
				if (event["toastClick"] == "__EMAIL_COU__") {
					new Toast(event["toastText"], onClick: (_) {
						window.open("mailto:publicrelations@childrenofur.com", "_blank");
					});
				}
			} else {
				for (Chat convo in openConversations) {
					if (convo.title == "Local Chat" && (event['channel'] == 'all' || event['street'] == currentStreet.label))
						convo.processEvent(event);
					else if (convo.title == event['channel'] && convo.title != "Local Chat")
						convo.processEvent(event);
				}
			}
		});

		new Service(['chatListEvent'], (event) {
			for (Chat convo in openConversations) {
				if (convo.title == event['channel']) {
					convo.displayList(event['users']);
				}
			}
		});

		new Service(['startChat'], (event) {
			new Chat(event as String);
		});

		new Service(['outgoingChatEvent'], (event) {
			if (_connection.readyState == WebSocket.OPEN) {
				post(event);
			}
			return;
		});

		refreshOnlinePlayers();
		new Service(["clock_tick"], (_) => refreshOnlinePlayers());
	}

	post(Map data) {
		_connection.sendString(JSON.encoder.convert(data));
	}

	void setupWebsocket(String url) {
		_connection = new WebSocket(url)
			..onOpen.listen((_) {
				// First event, tells the server who we are.
				post(new Map()
					..['tsid'] = currentStreet.streetData['tsid']
					..['street'] = currentStreet.label
					..['username'] = game.username
					..['statusMessage'] = 'join');

				// Get a List of the other players online
				post(new Map()
					..['hide'] = 'true'
					..['username'] = game.username
					..['statusMessage'] = 'list'
					..['channel'] = 'Global Chat');
			})
			..onMessage.listen((MessageEvent event) {
				Map data = JSON.decoder.convert(event.data);
				if (data['statusMessage'] == 'list') {
					transmit('chatListEvent', data);
				} else {
					transmit('chatEvent', data);
				}
			})
			..onClose.listen((_) {
				//wait 5 seconds and try to reconnect
				new Timer(new Duration(seconds: 5), () => setupWebsocket(url));
			})
			..onError.listen((Event e) {
				logmessage('[Chat] Socket error "$e"');
			});
	}

	static void updateTabUnread() {
		Element rightSide = querySelector("#rightSide");
		Element tab = rightSide.querySelector(".toggleSide");
		bool unreadmessages = false;
		for (Element e in rightSide.querySelectorAll("ul li.chatSpawn")) {
			if (e.classes.contains("unread")) {
				unreadmessages = true;
				break;
			}
		}
		if (unreadmessages) {
			tab.classes.add("unread");
		} else {
			tab.classes.remove("unread");
		}
	}

	static Map<String, bool> _lastPlayerList;

	// Update the list of friends in the sidebar
	static Future<int> refreshOnlinePlayers() async {
		// Download list of friends with online status
		Map<String, bool> users = JSON.decode(await HttpRequest
			.requestCrossOrigin(
			'http://${Configs.utilServerAddress}/friends/list/${game.username}'));

		// Reset the list
		Element list = querySelector("#playerList");
		list.children.clear();

		if (users.length == 0) {
			// No friends
			Element message = new LIElement()
				..classes.addAll(["noChatSpawn"])
				..setInnerHtml('<i class="fa-li fa fa-square-o"></i> Nobody, yet :(');
			list.append(message);
		} else {
			users.forEach((String username, bool online) {
				Element user = new LIElement()
					..title = (online ? 'Online' : 'Offline')
					..classes.add(online ? 'online' : 'offline')
					..onClick.listen((_) => window.open('http://childrenofur.com/profile?username=$username', '_blank'))
				//..classes.addAll(["online", "chatSpawn"])
				//..dataset["chat"] = username
					..setInnerHtml(
						'<i class="fa-li fa fa-user"></i>'
						' <i class="fa-li fa fa-user-times busy" title="Remove Friend" hidden></i>'
						' $username');
				user.querySelector('.fa-user')
					..onMouseEnter.listen((_) {
						user.querySelector('.fa-user').hidden = true;
						user.querySelector('.fa-user-times').hidden = false;
					});
				user.querySelector('.fa-user-times')
					..onMouseLeave.listen((_) {
						user?.querySelector('.fa-user')?.hidden = false;
						user?.querySelector('.fa-user-times')?.hidden = true;
					})
					..onClick.first.then((MouseEvent event) {
						event.stopPropagation();
						AddFriendWindow.removeFriend(username).then((bool result) {
							if (result) {
								user.remove();
							}
						});
					});
				list.append(user);
			});
		}

		// Compare this list to the last one
		if (_lastPlayerList != null) {
			// Friends who just came online
			users.keys.where((String username) {
				return (users[username] == true && _lastPlayerList[username] != null && _lastPlayerList[username] == false);
			}).forEach((String username) {
				new Toast('$username is online', notify: NotifyRule.UNFOCUSED);
			});

			// Friends who just went offline
			users.keys.where((String username) {
				return (users[username] == false && _lastPlayerList[username] != null && _lastPlayerList[username] == true);
			}).forEach((String username) {
				new Toast('$username went offline');
			});
		}

		_lastPlayerList = users;
		return users.length;
	}
}