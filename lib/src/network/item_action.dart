part of couclient;

class Item {
	static Future<List<Map<String, dynamic>>> loadItems() async {
		DateTime expires = new DateTime.now().add(new Duration(days: 1));

		if (
			localStorage["item_cache_date"] != null && // Date set
			!DateTime.parse(localStorage["item_cache_date"]).isAfter(expires) && // Under 24 hours old
			localStorage["item_cache"] != null // Items set
		) {
			// If the cache is fresh
			return (jsonDecode(localStorage["item_cache"]) as List).cast<Map<String, dynamic>>();
		} else {
			// Download item data
			String newJSON = await HttpRequest.getString("${Configs.http}//${Configs.utilServerAddress}/getItems");
			// Store item data
			localStorage["item_cache"] = newJSON;
			localStorage["item_cache_date"] = expires.toString();
			// Return item data
			return (jsonDecode(newJSON) as List).cast<Map<String, dynamic>>();
		}
	}

	static bool isItem({String itemType, String itemName}) {
		if (itemType != null) {
			List<Map> items = jsonDecode(localStorage["item_cache"]);
			return (items.where((Map item) => item["itemType"] == itemType).toList().length > 0);
		}

		if (itemName != null) {
			List<Map> items = jsonDecode(localStorage["item_cache"]);
			return (items.where((Map item) => item["name"] == itemName).toList().length > 0);
		}

		return false;
	}

	static String getName(String itemType) {
		List<Map> items = jsonDecode(localStorage["item_cache"]);
		return items.where((Map item) => item["itemType"] == itemType).toList().first["name"];
	}

	static String getIcon({String itemType, String itemName}) {
		if (itemType != null) {
			List<Map> items = jsonDecode(localStorage["item_cache"]);
			try {
				return items.where((Map item) => item["itemType"] == itemType).toList().first["iconUrl"];
			} catch(e) {
				logmessage("No item with ID `$itemType`");
				return "";
			}
		}

		if (itemName != null) {
			List<Map> items = jsonDecode(localStorage["item_cache"]);
			try {
				return items.where((Map item) => item["name"] == itemName).toList().first["iconUrl"];
			} catch(e) {
				logmessage("No item with ID `$itemType`");
				return "";
			}
		}

		return "";
	}
}