part of couclient;

WorldMap worldMap;

class WorldMap {
	Map<String, String> hubInfo;
	Map<String, Map> hubMaps;
	Map<String, String> moteInfo;
	String showingHub;

	DataMaps map = new DataMaps();

	bool worldMapVisible = false;
	Element WorldMapDiv = querySelector("#WorldMapLayer");
	Element HubMabDiv = querySelector("#HubMapLayer");

	//Element HubMapFG = querySelector("#HubMapLayerFG");

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

		// read in street data
		hubInfo = map.data_maps_hubs[hub_id]();
		hubMaps = map.data_maps_maps[hub_id]();
		moteInfo = map.data_maps_streets['9']();

		// check visited streets with server

		// prepare ui elements
		view.mapTitle.text = hubInfo['name'];
		view.mapImg.style.backgroundImage = 'url(' + hubInfo['bg'] + ')';
		//HubMapFG.style.backgroundImage = "url(" + hubInfo['fg'] + ")";
		HubMabDiv.children.clear();

		// render
		for (Map object in hubMaps['objs'].values) {
			if (object['type'] == 'S') {
				// STREETS

				String streetName = moteInfo[hub_id][object['tsid']];

				Map streetPlacement = {
					"x1": object["x1"],
					"x2": object["x2"],
					"y1": object["y1"],
					"y2": object["y2"],
					"deg": 0,
					"length": 0,
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
						if (text.toLowerCase().startsWith("a") ||
							text.toLowerCase().startsWith("e") ||
							text.toLowerCase().startsWith("i") ||
							text.toLowerCase().startsWith("o") ||
							text.toLowerCase().startsWith("u")) {
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
						if (metabolics.playerMetabolics.location_history.contains(tsid)) {
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
					"x": object["x"],
					"y": object["y"],
					"id": object["hub_id"],
					"name": map.data_maps_hubs[object["hub_id"]]()["name"],
					"color": map.data_maps_hubs[object["hub_id"]]()["color"]
				};

				DivElement go = new DivElement()
					..classes.add('hm-go')
					..text = 'GO'
					..title = 'Go to ' + goPlacement["name"]
					..style.left = (goPlacement["x"] - 20).toString() + 'px'
					..style.top = (goPlacement["y"] - 20).toString() + 'px'
					..style.backgroundColor = goPlacement["color"]
					..onClick.listen((_) => loadhubdiv(goPlacement["id"]));

				HubMabDiv.append(go);

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
			options[1]["description"] = "Spend 50 energy to get here right now";
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
			if (value["hidden"] == null || value["hidden"] != true) {
				DivElement hub = new DivElement();
				hub
					..className = "wml-hub"
					..dataset["hub"] = key.toString()
					..style.left = value['x'].toString() + 'px'
					..style.top = value['y'].toString() + 'px'
					..append(new SpanElement()..text = value['name'])
					..onMouseEnter.listen((_) => hub.style.backgroundImage = 'url(' + map.data_maps_hubs[key]()['bg'] + ')')
					..onMouseLeave.listen((_) => hub.style.backgroundImage = "");
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
		view.mapImg.style.backgroundImage =
			'url(' + map.data_maps_hubs[hub_id]()['bg'] + ')';
		view.mapTitle.text = map.data_maps_hubs[hub_id]()['name'];
		worldMapVisible = false;
		HubMabDiv.hidden = false;
		//HubMapFG.hidden = false;
	}
}
