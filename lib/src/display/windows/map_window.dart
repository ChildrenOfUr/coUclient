part of couclient;

class MapWindow extends Modal {
	String id = 'mapWindow';
	Element trigger = querySelector("#mapButton");
	InputElement searchBox = querySelector("#mapwindow-search");
	Element searchResultsContainer = querySelector("#map-window-search-results");
	UListElement searchResults = querySelector("#map-window-search-results ul");

	MapWindow() {
		prepare();

		setupUiButton(view.mapButton, openCallback: _drawWorldMap);
		setupKeyBinding("Map", openCallback: _drawWorldMap);

		new Service(['teleportByMapWindow'], (event) {
			this.close();
		});

		searchBox
			..onFocus.listen((_) => inputManager.ignoreKeys = ignoreShortcuts = true)
			..onInput.listen((_) => filter(searchBox.value))
			..onBlur.listen((_) {
				new Timer(new Duration(milliseconds: 100), () {
					inputManager.ignoreKeys = ignoreShortcuts = false;
					filter("");
				});
			});
	}

	int levenshtein(String s, String t, {bool caseSensitive: true}) {
		if (!caseSensitive) {
			s = s.toLowerCase();
			t = t.toLowerCase();
		}
		if (s == t)
			return 0;
		if (s.length == 0)
			return t.length;
		if (t.length == 0)
			return s.length;

		List<int> v0 = new List<int>.filled(t.length + 1, 0);
		List<int> v1 = new List<int>.filled(t.length + 1, 0);

		for (int i = 0; i < t.length + 1; i < i++)
			v0[i] = i;

		for (int i = 0; i < s.length; i++) {
			v1[0] = i + 1;

			for (int j = 0; j < t.length; j++) {
				int cost = (s[i] == t[j]) ? 0 : 1;
				v1[j + 1] = min(v1[j] + 1, min(v0[j + 1] + 1, v0[j] + cost));
			}

			for (int j = 0; j < t.length + 1; j++) {
				v0[j] = v1[j];
			}
		}

		return v1[t.length];
	}

	_drawWorldMap() {
		worldMap = new WorldMap(currentStreet.hub_id);
	}

	@override
	open({bool ignoreKeys: false}) {
		super.open();
		trigger.classes.remove('closed');
		trigger.classes.add('open');
	}

	@override
	close() {
		super.close();
		trigger.classes.remove('open');
		trigger.classes.add('closed');
	}

	// Search for a string
	filter(String entry) {
		// Toggle list showing
		if (entry
			    .trim()
			    .length < 2) {
			searchResultsContainer.hidden = true;
			return;
		} else {
			searchResultsContainer.hidden = false;
		}

		// Clear previous results
		searchResults.children.clear();

		List<String> results = [];

		for (String streetname in mapData.streetData.keys) {
			Map data = mapData.streetData[streetname];

			// Format TSID
			String tsid = data["tsid"];
			if (tsid == null) {
				tsid = "NULL_TSID";
			} else {
				tsid = tsid.substring(1);
			}

			// Check if street matches search
			if (checkVisibility(streetname) &&
			    (checkName(streetname, entry) || checkTsid(tsid, entry))) {
				results.add(streetname);
			}
		}

		results.sort((String a, String b) => levenshtein(a, b, caseSensitive: false));

		for(String streetname in results) {
			// Mark if current street
			String streetOut;
			if (currentStreet.label == streetname) {
				streetOut = "<i>$streetname</i>";
			} else {
				streetOut = streetname;
			}

			// Selectable item
			LIElement result = new LIElement()
				..setInnerHtml(streetOut);

			// Link to hub
			if (mapData.streetData[streetname] != null) {
				String hub_id = mapData.streetData[streetname]["hub_id"].toString();
				result.onClick.listen((Event e) {
					e.preventDefault();
					worldMap.loadhubdiv(hub_id, streetname);
					searchBox.value = "";
				});
			} else {
				logmessage("[WorldMap] Could not find the hub_id for $streetname");
			}

			// Add to list
			if (searchResults.children.length <= 13) {
				searchResults.append(result);
			} else {
				break;
			}
		}
	}

	bool checkVisibility(String streetname) {
		// Allowed to be shown on map?
		if (mapData.streetData[streetname] == null) {
			return true;
		} else {
			return !(mapData.streetData[streetname]["map_hidden"] ?? false);
		}
	}

	bool checkName(String streetname, String entry) {
		// Partial name match?
		return (streetname.toLowerCase().contains(entry.toLowerCase()));
	}

	bool checkTsid(String tsid, String entry) {
		// Exact TSID match?
		return (tsid.toLowerCase() == entry.substring(1).toLowerCase());
	}
}