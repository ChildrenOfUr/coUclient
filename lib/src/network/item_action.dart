part of couclient;

class Item {
	static Future<List<Map>> loadItems() async {
		// YYYY-MM-DD
		String today = new DateTime.now().toString().split(" ")[0];

		if (
		localStorage["item_cache_date"] != null && // Date set
		!DateTime.parse(localStorage["item_cache_date"]).isAfter(DateTime.parse(today)) && // Under 24 hours old
		localStorage["item_cache"] != null // Items set
		) {
			// If the cache is fresh
			return JSON.decode(localStorage["item_cache"]);
		} else {
			// Download item data
			String newJSON = await HttpRequest.getString("http://${Configs.utilServerAddress}/getItems");
			// Store item data
			localStorage["item_cache"] = newJSON;
			localStorage["item_cache_date"] = today;
			// Return item data
			print(localStorage["item_cache_date"]);
			return JSON.decode(newJSON);
		}
	}

	static bool isItem({String itemType, String itemName}) {
		if (itemType != null) {
			List<Map> items = JSON.decode(localStorage["item_cache"]);
			return (items.where((Map item) => item["itemType"] == itemType).toList().length > 0);
		}

		if (itemName != null) {
			List<Map> items = JSON.decode(localStorage["item_cache"]);
			return (items.where((Map item) => item["name"] == itemName).toList().length > 0);
		}

		return false;
	}

	static String getName(String itemType) {
		List<Map> items = JSON.decode(localStorage["item_cache"]);
		return items.where((Map item) => item["itemType"] == itemType).toList().first["name"];
	}

	static String getIcon({String itemType, String itemName}) {
		if (itemType != null) {
			List<Map> items = JSON.decode(localStorage["item_cache"]);
			try {
				return items.where((Map item) => item["itemType"] == itemType).toList().first["iconUrl"];
			} catch(e) {
				logmessage("No item with ID `$itemType`");
				return "";
			}
		}

		if (itemName != null) {
			List<Map> items = JSON.decode(localStorage["item_cache"]);
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