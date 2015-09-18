part of couclient;

class MapData {
	Map<String, Map<String, dynamic>> hubData, streetData;
	bool loaded;

	MapData();

	init() async {
		String json = await HttpRequest.requestCrossOrigin("http://${Configs.utilServerAddress}/getMapData?token=$rsToken");
		try {
			Map data = JSON.decode(json);
			logmessage("[Server Communication] Map data loaded.");
			hubData = data["hubs"];
			streetData = data["streets"];
			loaded = true;
		} catch (e) {
			logmessage("[Server Communication] Could not load map data: $e");
			loaded = false;
		}
	}

	String getLabel(String tsid) {
		int i = 0;
		for (Map data in streetData.values) {
			if (
			data["tsid"] != null &&
			data["tsid"].substring(1) == tsid.substring(1)
			) {
				return streetData.keys.toList()[i];
			}
			i++;
		}
		return "";
	}

	String getSong(String streetName) {
		// Provide a default
		String defaultSong = "forest";

		// Check to make sure we have data
		if (!loaded) {
			return defaultSong;
		}

		// Find the song
		if (streetData[streetName] != null && streetData[streetName]["music"] != null) {
			// Check #1: Street
			return streetData[streetName]["music"];
		} else if (hubData[currentStreet.hub_id] != null && hubData[currentStreet.hub_id]["music"] != null) {
			// Check #2: Hub
			return hubData[currentStreet.hub_id]["music"];
		} else {
			// Check #3: Default
			return defaultSong;
		}
	}

	int getMinimapOverride([String streetName]) {
		// Check to make sure we have data
		if (!loaded) {
			return -1;
		}

		// Get the current street if one was not given
		if (streetName == null) {
			streetName = currentStreet.label;
		}

		// Check the override status
		if (streetData[streetName] == null || streetData[streetName]["minimap_objects"] == null) {
			// Unknown
			return -1;
		} else if (streetData[streetName]["minimap_objects"] == true) {
			// Override to show objects
			return 1;
		} else if (streetData[streetName]["minimap_objects"] == false) {
			// Override to hide objects
			return 0;
		} else {
			return -1;
		}
	}

	int getBoundExpansionOverride([String streetName]) {
		if (!loaded) {
			return -1;
		}

		if (streetName == null) {
			streetName = currentStreet.label;
		}

		if (streetData[streetName] == null || streetData[streetName]["disallow_bound_expansion"] == null) {
			// Unknown
			return -1;
		} else if (streetData[streetName]["disallow_bound_expansion"] == false) {
			// Override to allow expansion
			return 1;
		} else if (streetData[streetName]["disallow_bound_expansion"] == true) {
			// Override to disallow expansion
			return 0;
		} else {
			return -1;
		}
	}
}