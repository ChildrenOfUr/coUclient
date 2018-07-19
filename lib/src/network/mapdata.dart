part of couclient;

class MapData {
	Map<String, Map<String, dynamic>>
		hubData = {},
		streetData = {};
	 Map<String, Map<String, Map<String, dynamic>>>
	 	renderData = {};

	Completer<bool> load = new Completer();

	MapData() {
		// Download the map data from the server
		try {
			HttpRequest.requestCrossOrigin(
				'${Configs.http}//${Configs.utilServerAddress}/getMapData?token=$rsToken')
			.timeout(new Duration(seconds: 5),
				onTimeout: () => _serverIsDown('Connection timed out.'))
			.then((String json) {
				try {
					Map<String, Map<String, dynamic>> data = jsonDecode(json);
					logmessage('[Server Communication] Map data loaded.');
					hubData = data['hubs'];
					streetData = data['streets'];
					renderData = data['render'];
					load.complete(true);
				} catch (e) {
					load.complete(false);
					_serverIsDown('$e');
				}
			});
		} catch (e) {
			load.complete(false);
			_serverIsDown('$e');
		}
	}

	// Shows the "server down" screen
	Future<Null> _serverIsDown([String errorText = ""]) async {
		logmessage("[Server Communication] Server down thrown: Could not load map data. $errorText");
		querySelector('#server-down').hidden = false;
		serverDown = true;
	}

	// Gets the name of the street with the given TSID
	String getLabel(String tsid) {
		int i = 0;
		for (Map data in streetData.values) {
			if (data["tsid"] != null && tsidL(data["tsid"]) == tsidL(tsid)) {
				return streetData.keys.toList()[i];
			}
			i++;
		}
		return "";
	}

	// Returns a list of all hub names
	List<String> get hubNames {
		List<String> returnHubNames = [];
		hubData.values.toList().forEach((Map data) {
			returnHubNames.add(data["name"]);
		});
		return returnHubNames;
	}

	// Returns a list of all street names
	List<String> get streetNames {
		return streetData.keys.toList();
	}

	// Returns the ID for the hub with given name
	String getHubId(String hubName) {
		String result = "";
		for (String id in hubData.keys) {
			String name = hubData[id]["name"];
			if (name == hubName) {
				result = id;
				break;
			}
		}
		return result;
	}

	// Returns the hub ID for the street with the given name
	String getHubIdForLabel(String streetName) {
		return streetData[streetName]['hub_id'].toString();
	}

	// Returns the physics on a given street name
	String getStreetPhysics(String streetName) {
		return checkStringSetting('physics', streetName: streetName, defaultValue: Physics.DEFAULTID);
	}

	// Returns the value of a setting in the map data
	dynamic checkSetting(String setting, {String streetName, var defaultValue}) {
		// Check to make sure we have data
		if (!load.isCompleted) {
			return defaultValue;
		}

		// Check for provided street
		if (streetName == null || streetName == "") {
			streetName = currentStreet.label;
		}

		String hubId = streetData[streetName]['hub_id'].toString();

		// Find the actual value
		if (streetData[streetName] != null && streetData[streetName][setting] != null) {
			// Check #1: Street
			return streetData[streetName][setting];
		} else if (hubData[hubId] != null && hubData[hubId][setting] != null) {
			// Check #2: Hub
			return hubData[hubId][setting];
		} else {
			// Check #3: Default
			return defaultValue;
		}
	}

	// Returns the value of a boolean setting, or the default value provided (defaults to false if not) if null
	bool checkBoolSetting(String setting, {String streetName, bool defaultValue: false})
	=> checkSetting(setting, streetName: streetName, defaultValue: defaultValue);

	// Returns the value of an integer setting, or the default value provided (defaults to -1 if not) if null
	int checkIntSetting(String setting, {String streetName, int defaultValue: -1})
	=> checkSetting(setting, streetName: streetName, defaultValue: defaultValue);

	// Returns the value of a string setting, or the default value provided (defaults to "" if not) if null
	String checkStringSetting(String setting, {String streetName, String defaultValue: ""})
	=> checkSetting(setting, streetName: streetName, defaultValue: defaultValue);

	// Returns whether to disable weather on a street
	bool forceDisableWeather([String streetName = ""])
	=> checkBoolSetting("disable_weather", streetName: streetName);

	// Returns whether to snow instead of rain
	bool snowyWeather([String streetName = ""])
	=> checkBoolSetting("snowy_weather", streetName: streetName);

	// Returns whether to disable game window size expansion to fit window
	bool boundsExpansionDisabled([String streetName = ""])
	=> checkBoolSetting("disallow_bound_expansion", streetName: streetName);

	// Returns whether to force showing/hiding of minimap objects
	// -1: no override
	//  0: override to HIDE objects
	//  1: override to SHOW objects
	int getMinimapOverride([String streetName])
	=> checkIntSetting("minimap_objects", streetName: streetName);

	// Returns whether to force enabling of minimap expansion
	bool getMinimapExpandOverride([String streetName])
	=> checkBoolSetting("minimap_expand", streetName: streetName);

	// Returns the song for a location
	String getSong([String streetName])
	=> checkStringSetting("music", streetName: streetName, defaultValue: "forest");
}
