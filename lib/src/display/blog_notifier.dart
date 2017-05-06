part of couclient;

class BlogNotifier {
	static const _LS_KEY = "cou_blog_post";
	static const _RSS_URL = "https://childrenofur.com/feed/";

	static dynamic get _lastSaved {
		if (localStorage[_LS_KEY] != null) {
			return localStorage[_LS_KEY];
		} else {
			return "";
		}
	}

	static set _lastSaved(dynamic id) {
		localStorage[_LS_KEY] = id.toString();
	}

	static void _notify(String link, String title) {
		new Notification(
			"Children of Ur Blog",
			body: "Click here to read the new post: \n$title",
			icon: Toast.notifIconUrl
		)..onClick.listen((_) {
			window.open(link, "_blank");
		});
	}

	static void refresh() {
		HttpRequest.getString(_RSS_URL).then((String xml) {
			// Parse RSS -> XML -> Document
			XML.XmlDocument feed = XML.parse(xml);
			// Find the latest post
			XML.XmlElement item = feed.findAllElements("item").first;
			// Get the title
			String title = item.findElements("title").first.text;
			// Get the link
			String permalink = item.findElements("guid").first.text;
			// Get the ID
			String guid = permalink.split("/?p=")[1];
			// Compare to last known post
			if (guid != _lastSaved) {
				// New post
				_notify(permalink, title);
				// Update cached
				_lastSaved = guid;
			}
		});
	}
}