part of couclient;

class ChatMessage {
	String player, message;

	ChatMessage(this.player, this.message);

	void notify() {
		if (message.toLowerCase().contains(game.username.toLowerCase())
		  && windowManager.settings.playMentionSound
		  && player != game.username) {
			// Popup
			new Notification(
			  player,
			  body: message,
			  icon: "http://childrenofur.com/assets/icon_72.png"
			);

			// Sound effect
			transmit('playSound', 'mention');
		}
	}

	Future<String> toHtml({String overrideUsernameLink}) async {
		// Verify data
		if (message is! String || player is! String) {
			return '';
		}

		String displayName = player;
		List<String> nameClasses = ["name"];

		// Set up labels
		if (player != null) {
			// You
			if (player == game.username) {
				nameClasses.add("you");
				if (!message.startsWith("/me")) {
					displayName = "You";
				}
			}

			// Dev/Guide
			if (overrideUsernameLink == null) {
				String elevation = await game.getElevation(player);
				if (elevation != "_") {
					nameClasses.add(elevation);
				}
			}
		}

		// Get link to username
		Future<AnchorElement> _getUsernameLink() async {
			AnchorElement link = new AnchorElement()
				..classes = (new List.from(nameClasses)
					..add("noUnderline"))
				..target = "_blank"
				..text = displayName;

			if (overrideUsernameLink != null) {
				link
					..href = overrideUsernameLink
					..style.color = 'black';
			} else {
				link
					..href = "http://childrenofur.com/profile?username=${Uri.encodeComponent(player)}"
					..title = "Open Profile Page"
					..style.color = (await getColorFromUsername(player));
			}

			return link;
		}

		// Notify of any mentions
		notify();

		if (player == null) {
			// System message
			return (new ParagraphElement()
				..text = message
				..classes = ["system"]
			).outerHtml;
		} else if (message.startsWith("/me")) {
			// /me message
			return (new ParagraphElement()
				..classes = ["me"]
				..append(await _getUsernameLink())
				..appendText(message.replaceFirst("/me", " "))
			).outerHtml;
		} else if (message == "LocationChangeEvent" && player == "invalid_user") {
			// Switching streets
			if (!metabolics.load.isCompleted) {
				await metabolics.load.future;
			}

			SpanElement messageSpan = new SpanElement()
				..classes = ["message"]
				..text = "${currentStreet.label}";

			return (new ParagraphElement()
				..classes = ["chat-member-change-event"]
				..append(messageSpan)
			).outerHtml;
		} else {
			// Normal message
			return (new ParagraphElement()
				..append(await _getUsernameLink())
				..appendHtml("&#8194;") // en space
				..append(new SpanElement()
					..classes = ["message"]
					..text = parseUrl(message))
			).outerHtml;
		}
	}
}

// chat functions

List<String> EMOTICONS;
List<Chat> openConversations = [];
List<Toast> chatToastBuffer = [];

// global functions

Map<String, String> cachedUsernameColors = {};

Future<String> getColorFromUsername(String username) async {
	if (cachedUsernameColors[username] != null) {
		// Already checked the color
		return cachedUsernameColors[username];
	} else {
		// Download color from server
		String color = await HttpRequest.getString(
		  "http://${Configs.utilServerAddress}/usernamecolors/get/$username"
	  	).timeout(new Duration(seconds: 5), onTimeout: () {
			return '#';
	  	});
		// Cache for later use
		cachedUsernameColors[username] = color;
		// Return for display
		return color;
	}
}

String parseUrl(String message) {
	/*
	    (https?:\/\/)?                    : the http or https schemes (optional)
	    [\w-]+(\.[\w-]+)+\.?              : domain name with at least two components;
	                                        allows a trailing dot
	    (:\d+)?                           : the port (optional)
	    (\/\S*)?                          : the path (optional)

		The r before the string makes dart interpret it as a raw string so that you don't have to escape characters like \
    */
	String regexString = r'((https?:\/\/)?[\w-]+(\.[\w-]+)+\.?(:\d+)?(\/\S*)?)';

	String returnString = '';
	RegExp regex = new RegExp(regexString);
	message.splitMapJoin(regex, onMatch: (Match m) {
		String url = m[0];

		// Add protocol if missing
		if (!url.contains('http')) {
			url = 'http://' + url;
		}

		returnString += '<a href="${url}" target="_blank" class="MessageLink">${m[0]}</a>';
	}, onNonMatch: (String s) => returnString += s);

	return returnString;
}

String parseItemLinks(String message) {
	String returnString = "";
	RegExp regex = new RegExp("#(.+?)#");
	(message.splitMapJoin(regex, onMatch: (Match m) {
		String match = m[1];
		if (Item.isItem(itemType: match)) {
			String name = Item.getName(match);
			String iconUrl = Item.getIcon(itemType: match);
			returnString += '<a class="item-chat-link" title="View Item" href="#">'
			  '<span class="item-chat-link-icon" '
			  'style="background-image: url($iconUrl);">'
			  '</span>$name</a>';
		} else {
			returnString += m[0];
		}
	}, onNonMatch: (String s) => returnString += s));

	return returnString;
}

String parseLocationLinks(String message) {
	String _parseHubLinks(String _message) {
		mapData.hubData.values.forEach((Map<String, dynamic> hubData) {
			if (hubData['name'] == null) {
				// Missing info
				return;
			}

			if (hubData['map_hidden'] ?? false) {
				// Hidden
				return;
			}

			_message = _message.replaceAll(hubData['name'],
				'<a class="location-chat-link hub-chat-link" title="View Hub" href="#">${hubData['name']}</a>');
		});

		return _message;
	}

	String _parseStreetLinks(String _message) {
		mapData.streetData.keys.forEach((String streetName) {
			if (!_message.contains(streetName)) {
				// Not a relevant street
				return;
			}

			if (mapData.checkBoolSetting('map_hidden', streetName: streetName)) {
				// Hidden or hub hidden
				return;
			}

			_message = _message.replaceAll(streetName,
				'<a class="location-chat-link street-chat-link" title="View Street" href="#">$streetName</a>');
		});

		return _message;
	}

	return _parseStreetLinks(_parseHubLinks(message));
}
