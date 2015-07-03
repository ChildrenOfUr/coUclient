part of couclient;

WorldMap worldMap;

class WorldMap {
	Map<String, String> hubInfo;
	Map<String, Map> hubMaps;
	Map<String, String> moteInfo;

	DataMaps map = new DataMaps();

	bool worldMapVisible = false;
	Element WorldMapDiv = querySelector("#WorldMapLayer");
	Element HubMabDiv = querySelector("#HubMapLayer");
	Element HubMapFG = querySelector("#HubMapLayerFG");

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
	}

	loadhubdiv(String hub_id) {
		// read in street data
		hubInfo = map.data_maps_hubs[hub_id]();
		hubMaps = map.data_maps_maps[hub_id]();
		moteInfo = map.data_maps_streets['9']();

		// prepare ui elements
		view.mapTitle.text = hubInfo['name'];
		view.mapImg.style.backgroundImage = 'url(' + hubInfo['bg'] + ')';
		HubMapFG.style.backgroundImage = "url(" + hubInfo['fg'] + ")";
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
				Map customAttributes = {
					"tsid": object['tsid']
				};

				DivElement street = new DivElement()
					..classes.add('hm-street')
					..title = "Teleport to " + streetName
					..text = streetName
					..attributes.addAll(customAttributes)
					..style.left = streetPlacement['x1'].toString() + 'px'
					..style.top = streetPlacement['y1'].toString() + 'px'
					..style.width = streetPlacement['length'].toString() + 'px'
					..style.transform = 'rotate(' + streetPlacement['deg'].toString() + 'rad)';
				street.onClick.first.then((_) {
					// Clicked on a street
					String tsid = street.attributes['tsid'];
					view.mapLoadingScreen.className = "MapLoadingScreenIn";
					view.mapLoadingScreen.style.opacity = "1.0";
					minimap.containerE.hidden = true;
					//changes first letter to match revdancatt's code - only if it starts with an L
					if(tsid.startsWith("L")) {
						tsid = tsid.replaceFirst("L", "G");
					}
					streetService.requestStreet(tsid);
					loadhubdiv(currentStreet.hub_id);
				});

				if(object['tsid'].substring(1) == currentStreet.streetData['tsid'].substring(1)) {
					// current street
					street.classes.add('hm-street-current');
				}

				// do not show streets with this in their name
				List<String> streetFilter = [
					"machine room",
					"the forgotten floor",
					"towers"
				];
				if(streetFilter.contains(street.text.toLowerCase()) == false) {
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
				Map customAttributes = {
					"tohub": goPlacement["id"]
				};
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
		HubMapFG.classes.add('scaled');

		worldMapVisible = false;
		HubMabDiv.hidden = false;
		HubMapFG.hidden = false;
		WorldMapDiv.hidden = true;
	}

	getStreetAngle(Map street) {
		num radians;
		if(street['y1'] < street['y2']) {
			Rectangle streetBox = new Rectangle(street['x1'], street['y1'], street['x2'] - street['x1'], street['y2'] - street['y1']);
			radians = (PI / 2) - atan2(streetBox.width, streetBox.height);
		} else if(street['y1'] > street['y2']) {
			Rectangle streetBox = new Rectangle(street['x1'], street['y1'], street['x2'] - street['x1'], street['y1'] - street['y2']);
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

	loadhub(String hub_id) {
		hubInfo = map.data_maps_hubs[hub_id]();
		hubMaps = map.data_maps_maps[hub_id]();
		moteInfo = map.data_maps_streets['9']();
		view.mapTitle.text = hubInfo['name'];
		view.mapImg.style.backgroundImage = 'url(' + hubInfo['bg'] + ')';
		//mapImg.setInnerHtml('<img src="' + hubInfo['fg']+ '"/>');
		view.mapCanvas.context2D.clearRect(0, 0, view.mapCanvas.width, view.mapCanvas.height);

		CanvasElement lineCanvas = new CanvasElement();
		CanvasElement textCanvas = new CanvasElement();

		lineCanvas.context2D.lineCap = "round";
		lineCanvas.context2D.strokeStyle = "rgba(255, 255, 240, 0.5)";

		textCanvas.width = view.mapCanvas.width;
		textCanvas.height = view.mapCanvas.height;
		textCanvas.context2D.fillStyle = "#000000";

		view.mapCanvas.context2D.miterLimit = 2;

		// TODO: Low priority, performance improvement

		for(Map object in hubMaps['objs'].values) {

			// Street Objects
			if(object['type'] == 'S') {
				String streetName = moteInfo[hub_id][object['tsid']];
				int streetMiddleX = ((object['x1'] + object['x2']) / 2).round();
				int streetMiddleY = ((object['y1'] + object['y2']) / 2).round();


				lineCanvas.width = view.mapCanvas.width;
				lineCanvas.height = view.mapCanvas.height;
				lineCanvas.context2D.lineCap = "round";
				lineCanvas.context2D.miterLimit = 2;
				lineCanvas.context2D.strokeStyle = "rgba(255, 255, 240, 0.5)";

				// If this is the street we are on, style is slightly different
				if(object['tsid'].substring(1) == currentStreet.streetData['tsid'].substring(1)) {
					lineCanvas.context2D.strokeStyle = "rgba(255, 255, 240, 1)";
				}

				lineCanvas.context2D.lineWidth = 5;
				lineCanvas.context2D.moveTo(object['x1'], object['y1']);
				lineCanvas.context2D.lineTo(object['x2'], object['y2']);
				lineCanvas.context2D.stroke();
				view.mapCanvas.context2D.drawImage(lineCanvas, 0, 0);

				//ui.mapCanvas.context2D.beginPath();

				// Rotates the canvas to the slope of the street's line. Translate to center of text, rotate around that point

				//streetHitBox.style.transform = "rotate("+ (atan((object['y2']-object['y1'])/(object['x2']-object['x1']))).toString() +"deg)";
				//TODO: draw shrine and vendor icons here

				// For name of each street
				textCanvas.context2D.save();
				textCanvas.context2D.miterLimit = 2;
				textCanvas.context2D.font = "normal 13px Lato";

				textCanvas.context2D.moveTo(0, 0);
				textCanvas.context2D.translate(streetMiddleX, streetMiddleY);
				textCanvas.context2D.rotate(atan((object['y2'] - object['y1']) / (object['x2'] - object['x1'])));
				textCanvas.context2D.translate(-streetMiddleX - (1.2 * streetName.length), -streetMiddleY);

				// If this is the street we are on, style is slightly different
				if(object['tsid'].substring(1) == currentStreet.streetData['tsid'].substring(1)) {
					textCanvas.context2D.fillStyle = "#C50101";
					textCanvas.context2D.font = "bold 15px Lato";
					// disabled until it is positioned correctly
//               drawStar(textCanvas.context2D,streetMiddleX,streetMiddleY-14,10,fillColor:textCanvas.context2D.fillStyle,strokeColor:textCanvas.context2D.strokeStyle);
				}

				textCanvas.context2D.lineWidth = 2;
				textCanvas.context2D.strokeStyle = "#FFFFFF";
				textCanvas.context2D.strokeText(streetName, (streetMiddleX - (view.mapCanvas.context2D.measureText(streetName).width / 2)), (streetMiddleY + 4));
				textCanvas.context2D.fillText(streetName, (streetMiddleX - (view.mapCanvas.context2D.measureText(streetName).width / 2)), (streetMiddleY + 4));

				textCanvas.context2D.restore();

				/* TODO: WIP, working towards onClick events like with street signs, not far along
        //String tsid = exit['tsid'].replaceFirst("L", "G");
          SpanElement streetHitBox = new SpanElement()
          * //width is length of street line
              ..style.width = sqrt(pow(object['x2']-object['x1'],2) + pow(object['y2']-object['y1'],2)).round().toString() + "px"
              ..style.height = "10px"
              ..style.position = "absolute"
              ..style.top = object['y1'].toString() + "px"
              ..style.left = object['x1'].toString() + "px"
              ..style.backgroundColor = "black"
              //..text = streetName
              ..className = "ExitLabel";
              //              ..attributes['url'] = 'http://RobertMcDermot.github.io/CAT422-glitch-location-viewer/locations/' + moteInfo[hub_id][object['tsid']] +'.callback.json'
              //              ..attributes['tsid'] = moteInfo[hub_id][object['tsid']];
        */
				//mapCanvas.append(streetHitBox);
			}

			// Exit Objects
			else if(object['type'] == 'X') {
				// Drawing the "GO" Circle. Needs small arrow addition, math similar to text below
				view.mapCanvas.context2D.beginPath();
				view.mapCanvas.context2D.arc(object['x'], object['y'], 18, 0, 2 * PI, false);
				view.mapCanvas.context2D.fillStyle = map.data_maps_hubs[object['hub_id']]()['color'];
				view.mapCanvas.context2D.fill();
				view.mapCanvas.context2D.lineWidth = 2;
				view.mapCanvas.context2D.font = "normal 18px Fredoka One";
				view.mapCanvas.context2D.fillStyle = '#FFFFFF';
				view.mapCanvas.context2D.fillText('GO', object['x'] - 14, object['y'] + 7);

				// Drawing the name of the region, angle specified in 'label', trig to ajdust pos based on angle
				view.mapCanvas.context2D.font = "normal 14px Lato";
				view.mapCanvas.context2D.strokeStyle = '#FFFFFF';
				view.mapCanvas.context2D.stroke();
				view.mapCanvas.context2D.lineWidth = 4;
				view.mapCanvas.context2D.strokeText('To: ' + map.data_maps_hubs[object['hub_id']]()['name'],
				                                    object['x'] + (sin(PI / 180 * object['label']) * 70) - view.mapCanvas.context2D.measureText(map.data_maps_hubs[object['hub_id']]()['name']).width * .8,
				                                    object['y'] - (cos(PI / 180 * object['label']) * 35) + 8);
				view.mapCanvas.context2D.lineWidth = .9;
				view.mapCanvas.context2D.strokeStyle = map.data_maps_hubs[object['hub_id']]()['color'];
				view.mapCanvas.context2D.strokeText('To: ' + map.data_maps_hubs[object['hub_id']]()['name'],
				                                    object['x'] + (sin(PI / 180 * object['label']) * 70) - view.mapCanvas.context2D.measureText(map.data_maps_hubs[object['hub_id']]()['name']).width * .8,
				                                    object['y'] - (cos(PI / 180 * object['label']) * 35) + 8);
			}
		}
		view.mapCanvas.context2D.drawImage(lineCanvas, 0, 0);
		view.mapCanvas.context2D.drawImage(textCanvas, 0, 0);

		//scale canvas to match map window size
		num scaleX = view.mapCanvas.parent.clientWidth / view.mapCanvas.clientWidth;
		num scaleY = view.mapCanvas.parent.clientHeight / view.mapCanvas.clientHeight;
		view.mapCanvas.style.transform = 'scaleX($scaleX) scaleY($scaleY)';
		view.mapCanvas.style.transformOrigin = '-21px -21px';

		worldMapVisible = false;
	}

	/**
	 * Taken from http://programmingthomas.wordpress.com/2012/05/16/drawing-stars-with-html5-canvas/
	 *
	 * You call the function by using star(context, x of center, y of center, radius)
	 *
	 **/
	void drawStar(CanvasRenderingContext2D ctx, num xOfCenter, num yOfCenter, num radius,
	              {num numPoints : 5, num insetFraction : .5, String fillColor : "#ffff00",
	              String strokeColor: "#000000", num strokeWidth : 2}) {
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
		view.mapImg.style.backgroundImage = 'url(files/system/windows/worldmap.png)';
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
			Map customAttributes = {
				"hub": key
			};
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
		HubMapFG.hidden = true;
		worldMapVisible = true;

		WorldMapDiv.onClick.listen((e) {
			loadhubdiv(e.target.attributes['hub']);
			querySelector("#map-window-world").setInnerHtml('<i class="fa fa-fw fa-globe"></i>');
		});
	}

	void hubMap({String hub_id, String hub_name}) {
		if(hub_id == null) {
			hub_id = currentStreet.hub_id;
		}
		loadhubdiv(hub_id);
		view.mapTitle.text = hub_name;
		view.mapImg.style.backgroundImage = 'url(' + map.data_maps_hubs[hub_id]()['bg'] + ')';
		view.mapTitle.text = map.data_maps_hubs[hub_id]()['name'];
		worldMapVisible = false;
		HubMabDiv.hidden = false;
		HubMapFG.hidden = false;
	}
}