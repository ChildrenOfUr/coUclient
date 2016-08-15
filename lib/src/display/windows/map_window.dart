part of couclient;

class MapWindow extends Modal {
	WorldMap worldMap;

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
				result.onMouseDown.listen((Event e) {
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

		bool hubVisible, streetVisible;
		// Hub level
		Map hub = mapData.hubData[mapData.getHubIdForLabel(streetname)];
		if (hub == null) {
			hubVisible = true;
		} else {
			hubVisible = !(hub['map_hidden'] ?? false);
		}

		// Street level
		if (mapData.streetData[streetname] == null) {
			streetVisible = true;
		} else {
			streetVisible = !(mapData.streetData[streetname]["map_hidden"] ?? false);
		}

		return (hubVisible && streetVisible);
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

class WorldMap {
	static final num DEG_TO_RAD = PI / 180;

	String showingHub;
	Map<String, String> hubInfo;

	bool worldMapVisible = false;
	Element WorldMapDiv = querySelector("#WorldMapLayer");
	Element HubMabDiv = querySelector("#HubMapLayer");
	Element HubMapFG = querySelector("#HubMapLayerFG");

	WorldMap(String hub_id) {
		loadhubdiv(hub_id);

		// toggle main and hub maps
		Element toggleMapView = querySelector("#map-window-world");
		toggleMapView.onClick.listen((_) {
			if (worldMapVisible) {
				// go to current hub
				hubMap();
				toggleMapView.setInnerHtml('<i class="fa fa-fw fa-globe"></i>');
			} else if (!worldMapVisible) {
				// go to world map
				mainMap();
				toggleMapView.setInnerHtml('<i class="fa fa-fw fa-map-marker"></i>');
			}
		});

		new Service(['streetLoaded'], (_) {
			if (!worldMapVisible) {
				// hub visible
				loadhubdiv(showingHub);
			}
		});

		new Service(['gpsCancel'], (_) {
			if (!worldMapVisible) {
				// hub visible
				loadhubdiv(showingHub);
			}
		});
	}

	navigate(String toStreetName) {
		GPS.getRoute(currentStreet.label, toStreetName);
		loadhubdiv(showingHub);
	}

	loadhubdiv(String hub_id, [String highlightStreet]) {
		showingHub = hub_id;

		Map<String, dynamic> hubInfo = mapData.hubData[hub_id];

		if (hubInfo == null) {
			logmessage('[MapWindow] Missing hub $hub_id');
		}

		// prepare ui elements
		view.mapTitle.text = hubInfo['name'];
		view.mapImg
			..style.backgroundImage = 'url(' + hubInfo['img_bg'] + ')'
			..title = hubInfo["name"];
		HubMapFG.style.backgroundImage = 'url(' + (hubInfo['img_fg'] ?? '') + ')';
		HubMabDiv.children.clear();

		// render
		for (Map object in mapData.renderData[hub_id].values) {
			if (object['type'] == 'S') {
				// STREETS

				String streetName = mapData.getLabel(object['tsid']);

				Map streetPlacement = {
					'x1': object['x1'],
					'x2': object['x2'],
					'y1': object['y1'],
					'y2': object['y2'],
					'deg': 0,
					'length': 0,
				};
				streetPlacement['deg'] = getStreetAngle(streetPlacement);
				streetPlacement['length'] = getStreetLength(streetPlacement);
				Map customAttributes = {"tsid": object['tsid']};

				DivElement street = new DivElement()
					..classes.add('hm-street')
					..title = streetName
					..text = streetName
					..attributes.addAll(customAttributes)
					..style.left = streetPlacement['x1'].toString() + 'px'
					..style.top = streetPlacement['y1'].toString() + 'px'
					..style.width = streetPlacement['length'].toString() + 'px'
					..style.transform =
						'rotate(' + streetPlacement['deg'].toString() + 'rad)';

				street
					..onClick.listen((e) {
						new Timer(new Duration(milliseconds: 100), () {
							createStreetMenu(e, street);
						});
					})
					..onContextMenu.listen((e) {
						new Timer(new Duration(milliseconds: 100), () {
							createStreetMenu(e, street);
						});
					});

				if (object['tsid'].substring(1) == currentStreet.streetData['tsid'].substring(1)) {
					// current street
					street.classes.add('hm-street-current');
				}

				if (highlightStreet != null && highlightStreet == streetName) {
					street.classes.add("hm-street-highlight");
				}

				for (String streetNameOnRoute in GPS.currentRoute) {
					if (streetNameOnRoute.substring(1) == streetName.substring(1)) {
						street.classes.add('hm-street-route');
						break;
					}
				}

				if (mapData.streetData[streetName] != null) {
					DivElement indicators = new DivElement()
						..classes.add("street-contents-indicators");

					// show vendor symbol if vendor is on street
					if (mapData.streetData[streetName]["vendor"] != null) {
						String ref;
						String text = mapData.streetData[streetName]["vendor"];
						if (["a", "e", "i", "o", "u"].contains(text.substring(0, 1).toLowerCase())) {
							ref = "an";
						} else {
							ref = "a";
						}
						DivElement vendorIndicator = new DivElement()
							..classes.add("sci-vendor")
							..title = streetName +
								" has " +
								ref +
								" " +
								mapData.streetData[streetName]["vendor"] +
								" Vendor";
						indicators.append(vendorIndicator);
					}

					// show shrine symbol if shrine is on street
					if (mapData.streetData[streetName]["shrine"] != null) {
						DivElement shrineIndicator = new DivElement()
							..classes.add("sci-shrine")
							..title = streetName +
								" has a shrine to " +
								mapData.streetData[streetName]["shrine"];
						indicators.append(shrineIndicator);
					}

					// show block symbol if machine room is on street
					if (mapData.streetData[streetName]["machine_room"] == true) {
						DivElement machinesIndicator = new DivElement()
							..classes.add("sci-machines")
							..title = streetName + " has a machine room";
						indicators.append(machinesIndicator);
					}

					// show gavel symbol if bureaucratic hall is on street
					if (mapData.streetData[streetName]["bureaucratic_hall"] == true) {
						DivElement bureauIndicator = new DivElement()
							..classes.add("sci-bureau")
							..title = streetName + " has a bureaucratic hall";
						indicators.append(bureauIndicator);
					}

					// show mailbox symbol if mailbox is on street
					if (mapData.streetData[streetName]["mailbox"] == true) {
						DivElement mailboxIndicator = new DivElement()
							..classes.add("sci-mailbox")
							..title = streetName + " has a mailbox";
						indicators.append(mailboxIndicator);
					}

					street.append(indicators);

					try {
						// Visited streets
						String tsid = mapData.streetData[streetName]["tsid"];
						if (tsid.startsWith("L")) {
							tsid = tsid.replaceFirst("L", "G");
						}
						if (metabolics.playerMetabolics.location_history.contains(tsidL(tsid))) {
							street.classes.add("visited");
						}
					} catch (e) {
						logmessage("[MapWindow] Could not check visited status of street $streetName: $e");
					}
				}

				// do not show certain streets
				if (mapData.streetData[streetName] == null ||
					(mapData.streetData[streetName] != null &&
						(mapData.streetData[streetName]["map_hidden"] == null ||
							mapData.streetData[streetName]["map_hidden"] == false))) {
					HubMabDiv.append(street);
				}

				// END STREETS

			} else if (object['type'] == 'X') {
				// GO CIRCLES

				Map goPlacement = {
					"x": object["x"], // int pos
					"y": object["y"], // int pos
					"arrow": object["arrow"], // int deg
					"label": object["label"], // int deg
					"id": object["hub_id"],
					"name": mapData.hubData[object['hub_id']]['name'],
					"color": mapData.hubData[object['hub_id']]['color']
				};

				if (!goPlacement["color"].startsWith("#")) {
					goPlacement["color"] = "#" + goPlacement["color"];
				}

				// Position pointer arrow x/y

				num arrowX = (cos((goPlacement["arrow"] - 90) * DEG_TO_RAD) * 16);
				num arrowY = (sin((goPlacement["arrow"] - 90) * DEG_TO_RAD) * 16);
				num arrowZ = goPlacement["arrow"] + 45;

				// Position "Go to" text

				// Round off degrees to 45deg increments
				int labelR = 0;
				for (int theta in [360, 315, 270, 225, 180, 135, 90, 45]) {
					if ((goPlacement["label"] - theta).abs() < 30) {
						labelR = theta;
					}
				}
				labelR -= 90;

				// Position text x/y
				num labelX = (cos((labelR) * DEG_TO_RAD) * 40);
				num labelY = (sin((labelR) * DEG_TO_RAD) * 40);

				DivElement goCircle = new DivElement()
					..classes.add('hm-go-circle')
					..text = 'GO'
					..style.backgroundColor = goPlacement["color"]
					..style.left = (goPlacement["x"] - 20).toString() + 'px'
					..style.top = (goPlacement["y"] - 20).toString() + 'px'
					..dataset["x"] = goPlacement["x"].toString()
					..dataset["y"] = goPlacement["y"].toString();

				DivElement goArrow = new DivElement()
					..classes.add("hm-go-arrow")
					..style.backgroundColor = goPlacement["color"]
					..style.transform = "translateX(${arrowX}px) translateY(${arrowY}px) rotateZ(${arrowZ}deg)"
					..style.left = (goPlacement["x"] - 8).toString() + 'px'
					..style.top = (goPlacement["y"] - 8).toString() + 'px'
					..dataset["r"] = goPlacement["arrow"].toString();

				DivElement goArrowOutline = new DivElement()
					..classes.add("hm-go-arrow-outline")
					..style.transform = goArrow.style.transform
					..style.left = (goPlacement["x"] - 11).toString() + 'px'
					..style.top = (goPlacement["y"] - 11).toString() + 'px';

				DivElement goCircleOutline = new DivElement()
					..classes.add("hm-go-circle-outline")
					..style.left = goCircle.style.left
					..style.top = goCircle.style.top;

				DivElement goText = new DivElement()
					..classes.add("hm-go-text")
					..style.color = goPlacement["color"]
					..text = "To: ${goPlacement["name"]}"
					..style.left = ((goPlacement["x"]) + labelX).toString() + 'px'
					..style.top = ((goPlacement["y"]) + labelY).toString() + 'px'
					..dataset["r"] = goPlacement["label"].toString();

				DivElement goParent = new DivElement()
					..append(goArrowOutline)
					..append(goCircleOutline)
					..append(goArrow)
					..append(goCircle)
					..append(goText)
					..classes.add("hm-go-parent")
					..onClick.listen((_) => loadhubdiv(goPlacement["id"]));

				HubMabDiv.append(goParent);

				// END GO CIRCLES
			}
		}

		HubMabDiv.classes.add('scaled');
		//HubMapFG.classes.add('scaled');

		worldMapVisible = false;
		HubMabDiv.hidden = false;
		//HubMapFG.hidden = false;
		WorldMapDiv.hidden = true;
	}

	getStreetAngle(Map street) {
		num radians;
		if (street['y1'] < street['y2']) {
			Rectangle streetBox = new Rectangle(street['x1'], street['y1'],
				street['x2'] - street['x1'], street['y2'] - street['y1']);
			radians = (PI / 2) - atan2(streetBox.width, streetBox.height);
		} else if (street['y1'] > street['y2']) {
			Rectangle streetBox = new Rectangle(street['x1'], street['y1'],
				street['x2'] - street['x1'], street['y1'] - street['y2']);
			radians = atan2(streetBox.width, streetBox.height);
			if (streetBox.width > streetBox.height) {
				radians -= (PI / 2);
			}
			radians = -atan2(streetBox.height, streetBox.width);
		}
		return radians;
	}

	getStreetLength(Map street) {
		num base = street['x2'] - street['x1'];
		num height = street['y2'] - street['y1'];
		num hyp = (base * base) + (height * height);
		return sqrt(hyp) + 8;
	}

	createStreetMenu(Event e, Element street) {
		String tsid = street.attributes['tsid'];
		String streetName = street.text;
		List<Map> options = [
			{
				"name": "Navigate",
				"description": "Get walking directions",
				"enabled": true,
				"timeRequired": 0,
				"clientCallback": () {
					navigate(streetName);
				}
			},
			{
				"name": "Teleport",
				"description": "You need at least 50 energy to teleport",
				"enabled": false,
				"timeRequired": 0,
				"clientCallback": () {
					transmit('teleportByMapWindow', tsid);
					if (inputManager.konamiDone && !inputManager.freeTeleportUsed) {
						// Free teleport for doing the konami code
						streetService.requestStreet(tsid);
						inputManager.freeTeleportUsed = true;
					} else {
						// Normal teleport
						sendGlobalAction('teleport', {'tsid':tsid});
						bool awaitingLoad = true;
						new Service(["streetLoaded"], (_) {
							if (awaitingLoad) {
								new Toast("-50 energy for teleporting");
								awaitingLoad = false;
							}
						});
					}
				}
			}
		];
		if (metabolics.energy >= 50 || (inputManager.konamiDone && !inputManager.freeTeleportUsed)) {
			options[1]["enabled"] = true;
			if (inputManager.konamiDone && !inputManager.freeTeleportUsed) {
				options[1]['description'] = "This one's on me kid";
			} else {
				options[1]["description"] = "Spend 50 energy to get here right now";
			}
		}
		document.body.append(RightClickMenu.create2(e, streetName, options));
	}

	void mainMap() {
		WorldMapDiv.hidden = true;
		HubMabDiv.hidden = true;
		view.mapTitle.text = "World Map";
		view.mapImg.style.backgroundImage = 'url(files/system/windows/worldmap.png)';
		WorldMapDiv.children.clear();

		mapData.hubData.forEach((key, value) {
			if (value["map_hidden"] != true && value['x'] != null && value['y'] != null) {
				DivElement hub = new DivElement();
				hub
					..className = "wml-hub"
					..dataset["hub"] = key.toString()
					..style.left = value['x'].toString() + 'px'
					..style.top = value['y'].toString() + 'px'
					..append(new SpanElement()..text = value['name'])
					..onMouseEnter.listen((_) =>
						hub.style.backgroundImage = 'url(' + value['img_bg'] + ')')
					..onMouseLeave.listen((_) => hub.style.backgroundImage = '');
				if (currentStreet.hub_id == key) {
					hub.classes.add('currentlocationhub');
				}
				WorldMapDiv.append(hub);
			}
		});
		WorldMapDiv.hidden = false;
		//HubMapFG.hidden = true;
		worldMapVisible = true;

		WorldMapDiv.onClick.listen((e) {
			Element target = (e.target is SpanElement ? e.target.parent : e.target);
			loadhubdiv(target.dataset["hub"]);
			querySelector("#map-window-world").setInnerHtml('<i class="fa fa-fw fa-globe"></i>');
		});
	}

	void hubMap({String hub_id, String hub_name, String highlightStreet}) {
		if (hub_id == null) {
			hub_id = currentStreet.hub_id;
		}
		if (highlightStreet != null) {
			loadhubdiv(hub_id, highlightStreet);
		} else {
			loadhubdiv(hub_id);
		}
		view.mapTitle.text = hub_name;
		view.mapImg.style.backgroundImage = 'url(' + mapData.hubData[hub_id]['img_bg'] + ')';
		view.mapTitle.text = mapData.hubData[hub_id]['name'];
		worldMapVisible = false;
		HubMabDiv.hidden = false;
		//HubMapFG.hidden = false;
	}
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
