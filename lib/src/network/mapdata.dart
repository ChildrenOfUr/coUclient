part of couclient;

class MapData {
	Map<String, Map<String, dynamic>> streetData;
	Map<int, dynamic> hubData;

	MapData();

	init() async {
		String json = await HttpRequest.requestCrossOrigin("http://${Configs.utilServerAddress}/getMapData?token=$rsToken");
		try {
			Map data = JSON.decode(json);
			logmessage("[Server Communication] Map data loaded.");
			streetData = data["streets"];
			hubData = data["hubs"];
			transmit("mapdataloaded", true);
		} catch (e) {
			logmessage("[Server Communication] Could not load map data: $e");
			transmit("mapdataloaded", false);
		}
	}

	String getSong(String streetName) {
		int hub_id;
		try {
			hub_id = streetData[streetName]["hub_id"];
		} catch (e) {
			logmessage("[StreetService] Hub ID not availabale for $streetName");
			return "forest";
		}

		if (streetData[streetName] != null && streetData[streetName]["music"] != null) {
			// Check #1: Street
			return streetData[streetName]["music"];
		} else if (hubData[hub_id] != null && hubData[hub_id]["music"] != null) {
			// Check #2: Hub
			return hubData[hub_id]["music"];
		} else {
			// Check #3: Default
			return "forest";
		}
	}

	int getMinimapOverride([String streetName]) {
		if (streetName == null) {
			streetName = currentStreet.label;
		}

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