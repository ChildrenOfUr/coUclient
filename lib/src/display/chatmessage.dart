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

	Future<String> toHtml() async {
		// Verify data
		if (message is! String || player is! String) {
			return '';
		}

		String displayName = player;
		List<String> nameClasses = ["name"];

		// Get link to username
		Future<AnchorElement> getUsernameLink() async {
			return new AnchorElement()
				..classes = (new List.from(nameClasses)
					..add("noUnderline"))
				..href = "http://childrenofur.com/profile?username=${Uri.encodeComponent(player)}"
				..target = "_blank"
				..title = "Open Profile Page"
				..text = displayName
				..style.color = (await getColorFromUsername(player));
		}

		// Notify of any mentions
		notify();

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
			if (game.devs.contains(player)) {
				nameClasses.add("dev");
			} else if (game.guides.contains(player)) {
				nameClasses.add("guide");
			}
		}

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
				..append(await getUsernameLink())
				..appendText(message.replaceFirst("/me", ""))
			).outerHtml;
		} else if (message == "LocationChangeEvent" && player == "invalid_user") {
			// Switching streets
			if (!metabolics.load.isCompleted) {
				await metabolics.load.future;
			}

			String prefix = (
			  metabolics.playerMetabolics.location_history.contains(currentStreet.tsid_g)
				? "Back"
				: "First time"
			);

			SpanElement messageSpan = new SpanElement()
				..classes = ["message"]
				..text = "$prefix in ${currentStreet.label}";

			return (new ParagraphElement()
				..classes = ["chat-member-change-event"]
				..append(messageSpan)
			).outerHtml;
		} else {
			// Normal message
			return (new ParagraphElement()
				..append(await getUsernameLink())
				..appendHtml("&#8194;") // en space
				..append(new SpanElement()
					..classes = ["message"]
					..text = message)
			).outerHtml;
		}
	}
}

// chat functions

List<String> EMOTICONS;
List<Chat> openConversations = [];
List<String> chatToastBuffer = [];

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
		);
		// Cache for later use
		cachedUsernameColors[username] = color;
		// Return for display
		return color;
	}
}

String parseEmoji(String message) {
	String returnString = "";
	RegExp regex = new RegExp("::(.+?)::");
	message.splitMapJoin(regex, onMatch: (Match m) {
		String match = m[1];
		if (EMOTICONS.contains(match)) {
			returnString += '<i class="emoticon emoticon-sm $match" title="$match"></i>';
		} else {
			returnString += m[0];
		}
	}, onNonMatch: (String s) => returnString += s);

	return returnString;
}

String parseUrl(String message) {
	/*
    (https?:\/\/)?                    : the http or https schemes (optional)
    [\w-]+(\.[\w-]+)+\.?              : domain name with at least two components;
                                        allows a trailing dot
    (:\d+)?                           : the port (optional)
    (\/\S*)?                          : the path (optional)
    */
	String regexString = r"((https?:\/\/)?[\w-]+(\.[\w-]+)+\.?(:\d+)?(\/\S*)?)";
	//the r before the string makes dart interpret it as a raw string so that you don't have to escape characters like \

	String returnString = "";
	RegExp regex = new RegExp(regexString);
	message.splitMapJoin(regex, onMatch: (Match m) {
		String url = m[0];
		if (url.contains('"')) {
			// Don't match URLs already in <a> tags
			returnString += url;
		} else {
			if (!url.contains("http")) {
				url = "http://" + url;
			}
			returnString += '<a href="${url}" target="_blank" class="MessageLink">${m[0]}</a>';
		}
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
		mapData.hubNames.forEach((String hubName) {
			_message = _message.replaceAll(
			  hubName,
			  '<a class="location-chat-link hub-chat-link" title="View Hub" href="#">'
				'$hubName</a>'
			);
		});

		return _message;
	}

	String _parseStreetLinks(String _message) {
		mapData.streetNames.forEach((String streetName) {
			_message = _message.replaceAll(
			  streetName,
			  '<a class="location-chat-link street-chat-link" title="View Street" href="#">'
				'$streetName</a>'
			);
		});

		return _message;
	}

	return _parseStreetLinks(_parseHubLinks(message));
}
