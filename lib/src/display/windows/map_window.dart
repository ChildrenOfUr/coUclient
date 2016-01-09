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
			..onKeyDown.listen((_) => filter(searchBox.value))
			..onBlur.listen((_) {
				new Timer(new Duration(milliseconds: 100), () {
					inputManager.ignoreKeys = ignoreShortcuts = false;
					filter("");
				});
			});
	}

	_drawWorldMap() {
		worldMap = new WorldMap(currentStreet.hub_id);
	}

	@override
	open() {
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
		if (entry.trim().length < 2) {
			searchResultsContainer.hidden = true;
			return;
		} else {
			searchResultsContainer.hidden = false;
		}

		// Clear previous results
		searchResults.children.clear();

		for (String streetname in mapData.streetData.keys) {
			Map data = mapData.streetData[streetname];

			// Format TSID
			String tsid = data["tsid"];
			if (tsid == null) {
				tsid = "NULL_TSID";
			} else {
				tsid = tsid.substring(1);
			}

			bool checkVisibility() {
				// Allowed to be shown on map?
				return (mapData.streetData[streetname] != null &&
				  !(mapData.streetData[streetname]["map_hidden"]));
			}

			bool checkName() {
				// Partial name match?
				return (streetname.toLowerCase().contains(entry.toLowerCase()));
			}

			bool checkTsid() {
				// Exact TSID match?
				return (tsid.toLowerCase().contains(entry.substring(1).toLowerCase()));
			}

			// Check if street matches search
			if (checkVisibility() && (checkName() || checkTsid())) {
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
	}
}