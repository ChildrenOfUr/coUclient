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
			if(worldMapVisible) {
				// go to current hub
				hubMap();
				toggleMapView.setInnerHtml('<i class="fa fa-fw fa-globe"></i>');
			} else if(!worldMapVisible) {
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
		GPS.getRoute(currentStreet.label,toStreetName);
		loadhubdiv(showingHub);
	}

	teleport(String tsid) {
		mapWindow.close();
		streetService.requestStreet(tsid);
		loadhubdiv(showingHub);
		mapWindow.close();
	}

	loadhubdiv(String hub_id) {
		showingHub = hub_id;

		// read in street data
		hubInfo = map.data_maps_hubs[hub_id]();
		hubMaps = map.data_maps_maps[hub_id]();
		moteInfo = map.data_maps_streets['9']();

		// prepare ui elements
		view.mapTitle.text = hubInfo['name'];
		view.mapImg.style.backgroundImage = 'url(' + hubInfo['bg'] + ')';
		//HubMapFG.style.backgroundImage = "url(" + hubInfo['fg'] + ")";
		HubMabDiv.children.clear();

		// render
		for(Map object in hubMaps['objs'].values) {
			if(object['type'] == 'S') {
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

				street.onClick.listen((e) => createStreetMenu(e, street));
				street.onContextMenu.listen((e) => createStreetMenu(e, street));

				if(object['tsid'].substring(1) == currentStreet.streetData['tsid'].substring(1)) {
					// current street
					street.classes.add('hm-street-current');
				}

				for (String streetNameOnRoute in GPS.currentRoute) {
					if (streetNameOnRoute.substring(1) == streetName.substring(1)) {
						street.classes.add('hm-street-route');
						break;
					}
				}

				if(streetContentsData[streetName] == null) {
					logmessage("[Map] Street contents not available for " + streetName);
				} else {
					DivElement indicators = new DivElement()
						..classes.add("street-contents-indicators");

					// show vendor symbol if vendor is on street
					if(streetContentsData[streetName]["vendor"] != null) {
						String ref;
						String text = streetContentsData[streetName]["vendor"];
						if(text.toLowerCase().startsWith("a") ||
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
							          streetContentsData[streetName]["vendor"] +
							          " Vendor";
						indicators.append(vendorIndicator);
					}

					// show shrine symbol if shrine is on street
					if(streetContentsData[streetName]["shrine"] != null) {
						DivElement shrineIndicator = new DivElement()
							..classes.add("sci-shrine")
							..title = streetName +
							          " has a shrine to " +
							          streetContentsData[streetName]["shrine"];
						indicators.append(shrineIndicator);
					}

					// show block symbol if machine room is on street
					if(streetContentsData[streetName]["machine_room"] == true) {
						DivElement machinesIndicator = new DivElement()
							..classes.add("sci-machines")
							..title = streetName + " has a machine room";
						indicators.append(machinesIndicator);
					}

					// show gavel symbol if bureaucratic hall is on street
					if(streetContentsData[streetName]["bureaucratic_hall"] == true) {
						DivElement bureauIndicator = new DivElement()
							..classes.add("sci-bureau")
							..title = streetName + " has a bureaucratic hall";
						indicators.append(bureauIndicator);
					}

					// show mailbox symbol if mailbox is on street
					if(streetContentsData[streetName]["mailbox"] == true) {
						DivElement mailboxIndicator = new DivElement()
							..classes.add("sci-mailbox")
							..title = streetName + " has a mailbox";
						indicators.append(mailboxIndicator);
					}

					street.append(indicators);
				}

				// do not show streets with this in their name
				if(!street.text.contains(new RegExp(r'(towers|machine room|the forgotten floor|manor|' + hubInfo['name'] + ' Start)', caseSensitive: false))) {
					HubMabDiv.append(street);
				}

				// END STREETS
			} else if(object['type'] == 'X') {
				// GO CIRCLES

				Map goPlacement = {
					"x": object["x"],
					"y": object["y"],
					"id": object["hub_id"],
					"name": map.data_maps_hubs[object["hub_id"]]()["name"],
					"color": map.data_maps_hubs[object["hub_id"]]()["color"]
				};
				Map customAttributes = {"tohub": goPlacement["id"]};
				DivElement go = new DivElement()
					..classes.add('hm-go')
					..text = 'GO'
					..title = 'Go to ' + goPlacement["name"]
					..attributes.addAll(customAttributes)
					..style.left = (goPlacement["x"] - 20).toString() + 'px'
					..style.top = (goPlacement["y"] - 20).toString() + 'px'
					..style.backgroundColor = goPlacement["color"];
				go.onClick.first.then((_) {
					// Clicked on a GO marker
					querySelector("body").style.cursor = "progress";
					loadhubdiv(go.attributes['tohub']);
					querySelector("body").style.cursor = "pointer";
				});
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
		if(street['y1'] < street['y2']) {
			Rectangle streetBox = new Rectangle(street['x1'], street['y1'],
			                                    street['x2'] - street['x1'], street['y2'] - street['y1']);
			radians = (PI / 2) - atan2(streetBox.width, streetBox.height);
		} else if(street['y1'] > street['y2']) {
			Rectangle streetBox = new Rectangle(street['x1'], street['y1'],
			                                    street['x2'] - street['x1'], street['y1'] - street['y2']);
			radians = atan2(streetBox.width, streetBox.height);
			if(streetBox.width > streetBox.height) {
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
				"clientCallback": (){navigate(streetName);}
			},
			{
				"name": "Teleport",
				"description": "You need at least 50 energy to teleport",
				"enabled": false,
				"timeRequired": 0,
				"clientCallback": (){teleport(tsid);}
			}
		];
		if(metabolics.energy >= 50) {
			options[1]["enabled"] = true;
			options[1]["description"] = "Spend 50 energy to get here right now";
		}
		new Timer(new Duration(milliseconds: 50), () {
			document.body.append(RightClickMenu.create2(e, streetName, options));
		});
	}

	/**
	 * Taken from http://programmingthomas.wordpress.com/2012/05/16/drawing-stars-with-html5-canvas/
	 *
	 * You call the function by using star(context, x of center, y of center, radius)
	 *
	 **/
	void drawStar(
		CanvasRenderingContext2D ctx, num xOfCenter, num yOfCenter, num radius,
		{num numPoints: 5, num insetFraction: .5, String fillColor: "#ffff00",
		String strokeColor: "#000000", num strokeWidth: 2}) {
		ctx.save();
		ctx.fillStyle = fillColor;
		ctx.strokeStyle = strokeColor;
		ctx.lineWidth = strokeWidth;
		ctx.beginPath();
		ctx.translate(xOfCenter, yOfCenter);
		ctx.moveTo(0, 0 - radius);
		for(var i = 0; i < numPoints; i++) {
			ctx.rotate(PI / numPoints);
			ctx.lineTo(0, 0 - (radius * insetFraction));
			ctx.rotate(PI / numPoints);
			ctx.lineTo(0, 0 - radius);
		}
		ctx.fill();
		ctx.stroke();
		ctx.restore();
	}

	void mainMap() {
		WorldMapDiv.hidden = true;
		HubMabDiv.hidden = true;
		view.mapTitle.text = "World Map";
		view.mapImg.style.backgroundImage =
		'url(files/system/windows/worldmap.png)';
		WorldMapDiv.children.clear();
		String json = '''
{
  "76": {
    "name": "Alakol",
    "x": 360,
    "y": 129
  },
  "89": {
    "name": "Andra",
    "x": 314,
    "y": 98
  },
  "101": {
    "name": "Aranna",
    "x": 397,
    "y": 24
  },
  "128": {
    "name": "Balzare",
    "x": 80,
    "y": 90
  },
  "86": {
    "name": "Baqala",
    "x": 355,
    "y": 78
  },
  "98": {
    "name": "Besara",
    "x": 404,
    "y": 46
  },
  "75": {
    "name": "Bortola",
    "x": 405,
    "y": 99
  },
  "112": {
    "name": "Brillah",
    "x": 497,
    "y": 74
  },
  "107": {
    "name": "Callopee",
    "x": 449,
    "y": 43
  },
  "120": {
    "name": "Cauda",
    "x": 416,
    "y": 256
  },
  "72": {
    "name": "Chakra Phool",
    "x": 200,
    "y": 240
  },
  "90": {
    "name": "Choru",
    "x": 354,
    "y": 56
  },
  "141": {
    "name": "Drifa",
    "x": 390,
    "y": -2
  },
  "123": {
    "name": "Fenneq",
    "x": 431,
    "y": 225
  },
  "114": {
    "name": "Firozi",
    "x": 375,
    "y": 156
  },
  "119": {
    "name": "Folivoria",
    "x": 258,
    "y": 63
  },
  "56": {
    "name": "Groddle Forest",
    "x": 340,
    "y": 191
  },
  "64": {
    "name": "Groddle Heights",
    "x": 310,
    "y": 171
  },
  "58": {
    "name": "Groddle Meadow",
    "x": 293,
    "y": 194
  },
  "131": {
    "name": "Haoma",
    "x": 78,
    "y": 118
  },
  "116": {
    "name": "Haraiva",
    "x": 519,
    "y": 122
  },
  "27": {
    "name": "Ix",
    "x": 122,
    "y": 53
  },
  "136": {
    "name": "Jal",
    "x": 332,
    "y": 151
  },
  "71": {
    "name": "Jethimadh",
    "x": 241,
    "y": 248
  },
  "85": {
    "name": "Kajuu",
    "x": 358,
    "y": 102
  },
  "99": {
    "name": "Kalavana",
    "x": 196,
    "y": 266
  },
  "88": {
    "name": "Karnata",
    "x": 497,
    "y": 100
  },
  "133": {
    "name": "Kloro",
    "x": 71,
    "y": 143
  },
  "105": {
    "name": "Lida",
    "x": 451,
    "y": 117
  },
  "110": {
    "name": "Massadoe",
    "x": 446,
    "y": 19
  },
  "97": {
    "name": "Muufo",
    "x": 451,
    "y": 92
  },
  "137": {
    "name": "Nottis",
    "x": 344,
    "y": 9
  },
  "102": {
    "name": "Ormonos",
    "x": 407,
    "y": 125
  },
  "106": {
    "name": "Pollokoo",
    "x": 445,
    "y": 66
  },
  "109": {
    "name": "Rasana",
    "x": 261,
    "y": 122
  },
  "126": {
    "name": "Roobrik",
    "x": 120,
    "y": 100
  },
  "93": {
    "name": "Salatu",
    "x": 313,
    "y": 121
  },
  "140": {
    "name": "Samudra",
    "x": 285,
    "y": 147
  },
  "63": {
    "name": "Shimla Mirch",
    "x": 238,
    "y": 219
  },
  "121": {
    "name": "Sura",
    "x": 461,
    "y": 256
  },
  "113": {
    "name": "Tahli",
    "x": 263,
    "y": 94
  },
  "92": {
    "name": "Tamila",
    "x": 400,
    "y": 72
  },
  "51": {
    "name": "Uralia",
    "x": 125,
    "y": 125
  },
  "100": {
    "name": "Vantalu",
    "x": 353,
    "y": 35
  },
  "95": {
    "name": "Xalanga",
    "x": 305,
    "y": 43
  },
  "91": {
    "name": "Zhambu",
    "x": 306,
    "y": 74
  }
}
    ''';

		Map hubs = JSON.decode(json);
		hubs.forEach((key, value) {
			Map customAttributes = {"hub": key};
			DivElement hub = new DivElement()
				..className = "wml-hub"
				..attributes.addAll(customAttributes)
				..style.left = value['x'].toString() + 'px'
				..style.top = value['y'].toString() + 'px'
				..text = value['name'];
			if(currentStreet.hub_id == key) {
				hub.classes.add('currentlocationhub');
			}
			WorldMapDiv.append(hub);
		});
		WorldMapDiv.hidden = false;
		//HubMapFG.hidden = true;
		worldMapVisible = true;

		WorldMapDiv.onClick.listen((e) {
			loadhubdiv(e.target.attributes['hub']);
			querySelector("#map-window-world")
			.setInnerHtml('<i class="fa fa-fw fa-globe"></i>');
		});
	}

	void hubMap({String hub_id, String hub_name}) {
		if(hub_id == null) {
			hub_id = currentStreet.hub_id;
		}
		loadhubdiv(hub_id);
		view.mapTitle.text = hub_name;
		view.mapImg.style.backgroundImage =
		'url(' + map.data_maps_hubs[hub_id]()['bg'] + ')';
		view.mapTitle.text = map.data_maps_hubs[hub_id]()['name'];
		worldMapVisible = false;
		HubMabDiv.hidden = false;
		//HubMapFG.hidden = false;
	}
}
