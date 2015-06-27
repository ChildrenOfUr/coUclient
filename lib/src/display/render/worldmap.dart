part of couclient;

WorldMap worldMap;

class WorldMap
{
  Map<String,String> hubInfo;
  Map<String,Map> hubMaps;
  Map<String,String> moteInfo;

  DataMaps map = new DataMaps();

  bool worldMapVisible = false;

  WorldMap(String hub_id){
    hubInfo = map.data_maps_hubs[hub_id]();
    hubMaps = map.data_maps_maps[hub_id]();
    moteInfo = map.data_maps_streets['9']();
    view.mapTitle.text = hubInfo['name'];
    view.mapImg.style.backgroundImage = 'url(' +hubInfo['bg']+ ')';
    //mapImg.setInnerHtml('<img src="' + hubInfo['fg']+ '"/>');
    view.mapCanvas.context2D.clearRect(0, 0, view.mapCanvas.width, view.mapCanvas.height);

    CanvasElement lineCanvas = new CanvasElement();
    CanvasElement textCanvas = new CanvasElement();

    lineCanvas.context2D.lineCap="round";
    lineCanvas.context2D.strokeStyle = "rgba(255, 255, 240, 0.5)";

    textCanvas.width = view.mapCanvas.width;
    textCanvas.height = view.mapCanvas.height;
    textCanvas.context2D.fillStyle = "#000000";

    view.mapCanvas.context2D.miterLimit=2;

    // TODO: Low priority, performance improvement

    for (Map object in hubMaps['objs'].values) {

      // Street Objects
      if (object['type'] == 'S') {
        String streetName = moteInfo[hub_id][object['tsid']];
        int streetMiddleX = ((object['x1']+object['x2'])/2).round();
        int streetMiddleY = ((object['y1']+object['y2'])/2).round();


             lineCanvas.width = view.mapCanvas.width;
             lineCanvas.height = view.mapCanvas.height;
             lineCanvas.context2D.lineCap="round";
             lineCanvas.context2D.miterLimit=2;
             lineCanvas.context2D.strokeStyle = "rgba(255, 255, 240, 0.5)";

             // If this is the street we are on, style is slightly different
             if (object['tsid'].substring(1) == currentStreet.streetData['tsid'].substring(1)) {
               lineCanvas.context2D.strokeStyle = "rgba(255, 255, 240, 1)";
             }

             lineCanvas.context2D.lineWidth = 5;
             lineCanvas.context2D.moveTo(object['x1'],object['y1']);
             lineCanvas.context2D.lineTo(object['x2'],object['y2']);
             lineCanvas.context2D.stroke();
             view.mapCanvas.context2D.drawImage(lineCanvas, 0, 0);

             //ui.mapCanvas.context2D.beginPath();

             // Rotates the canvas to the slope of the street's line. Translate to center of text, rotate around that point

             //streetHitBox.style.transform = "rotate("+ (atan((object['y2']-object['y1'])/(object['x2']-object['x1']))).toString() +"deg)";
             //TODO: draw shrine and vendor icons here

             // For name of each street
             textCanvas.context2D.save();
             textCanvas.context2D.miterLimit=2;
             textCanvas.context2D.font = "13px Arial bold";

             textCanvas.context2D.moveTo(0,0);
             textCanvas.context2D.translate(streetMiddleX, streetMiddleY);
             textCanvas.context2D.rotate(atan((object['y2']-object['y1'])/(object['x2']-object['x1'])));
             textCanvas.context2D.translate(-streetMiddleX, -streetMiddleY);

             // If this is the street we are on, style is slightly different
             if (object['tsid'].substring(1) == currentStreet.streetData['tsid'].substring(1)) {
               textCanvas.context2D.fillStyle = "#C50101";
               textCanvas.context2D.font = "15px Arial bold";
               drawStar(textCanvas.context2D,streetMiddleX,streetMiddleY-14,10,fillColor:textCanvas.context2D.fillStyle,strokeColor:textCanvas.context2D.strokeStyle);
             }

             textCanvas.context2D.lineWidth = 3;
             textCanvas.context2D.strokeStyle = "#FFFFFF";
             textCanvas.context2D.strokeText(streetName,(streetMiddleX - (view.mapCanvas.context2D.measureText(streetName).width / 2)), (streetMiddleY + 4));
             textCanvas.context2D.fillText(streetName,(streetMiddleX - (view.mapCanvas.context2D.measureText(streetName).width / 2)), (streetMiddleY + 4));

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
      else if (object['type'] == 'X') {

        // Drawing the "GO" Circle. Needs small arrow addition, math similar to text below
        view.mapCanvas.context2D.beginPath();
        view.mapCanvas.context2D.arc(object['x'], object['y'], 18, 0, 2 * PI, false);
        view.mapCanvas.context2D.fillStyle = map.data_maps_hubs[object['hub_id']]()['color'];
        view.mapCanvas.context2D.fill();
        view.mapCanvas.context2D.lineWidth = 2;
        view.mapCanvas.context2D.font = "18px Arial";
        view.mapCanvas.context2D.fillStyle = '#FFFFFF';
        view.mapCanvas.context2D.fillText('GO',object['x']-14, object['y']+7);

        // Drawing the name of the region, angle specified in 'label', trig to ajdust pos based on angle
        view.mapCanvas.context2D.font = "14px Arial";
        view.mapCanvas.context2D.strokeStyle = '#FFFFFF';
        view.mapCanvas.context2D.stroke();
        view.mapCanvas.context2D.lineWidth = 4;
        view.mapCanvas.context2D.strokeText('To: ' + map.data_maps_hubs[object['hub_id']]()['name'],
            object['x'] + (sin(PI/180*object['label']) * 70) - view.mapCanvas.context2D.measureText(map.data_maps_hubs[object['hub_id']]()['name']).width * .8,
            object['y'] - (cos(PI/180*object['label']) * 35) + 8);
        view.mapCanvas.context2D.lineWidth = .9;
        view.mapCanvas.context2D.strokeStyle = map.data_maps_hubs[object['hub_id']]()['color'];
        view.mapCanvas.context2D.strokeText('To: ' + map.data_maps_hubs[object['hub_id']]()['name'],
            object['x'] + (sin(PI/180*object['label']) * 70) - view.mapCanvas.context2D.measureText(map.data_maps_hubs[object['hub_id']]()['name']).width * .8,
            object['y'] - (cos(PI/180*object['label']) * 35) + 8);
      }
    }
    view.mapCanvas.context2D.drawImage(lineCanvas, 0, 0);
    view.mapCanvas.context2D.drawImage(textCanvas, 0, 0);

    //scale canvas to match map window size
    num scaleX = view.mapCanvas.parent.clientWidth/view.mapCanvas.clientWidth;
    num scaleY = view.mapCanvas.parent.clientHeight/view.mapCanvas.clientHeight;
    view.mapCanvas.style.transform = 'scaleX($scaleX) scaleY($scaleY)';
    view.mapCanvas.style.transformOrigin = '-21px -21px';

    worldMapVisible = true;

    // toggle main and hub maps

    Element toggleMapView = querySelector("#map-window-world");
    toggleMapView.onClick.listen((_) {
      if (worldMapVisible) {
        // go to current hub
        toggleMapView.setInnerHtml('<i class="fa fa-fw fa-globe"></i>');
        worldMapVisible = false;
      } else {
        // go to world map
        mainMap();
        toggleMapView.setInnerHtml('<i class="fa fa-fw fa-map-marker"></i>');
        worldMapVisible = true;
      }
    });
  }

  /**
   * Taken from http://programmingthomas.wordpress.com/2012/05/16/drawing-stars-with-html5-canvas/
   *
   * You call the function by using star(context, x of center, y of center, radius)
   *
   **/
  void drawStar(CanvasRenderingContext2D ctx, num xOfCenter, num yOfCenter, num radius,
      {num numPoints : 5, num insetFraction : .5, String fillColor : "#ffff00",
    	String strokeColor: "#000000", num strokeWidth : 2})
  {
      ctx.save();
      ctx.fillStyle = fillColor;
      ctx.strokeStyle = strokeColor;
      ctx.lineWidth = strokeWidth;
      ctx.beginPath();
      ctx.translate(xOfCenter, yOfCenter);
      ctx.moveTo(0,0-radius);
      for (var i = 0; i < numPoints; i++)
      {
          ctx.rotate(PI / numPoints);
          ctx.lineTo(0, 0 - (radius*insetFraction));
          ctx.rotate(PI / numPoints);
          ctx.lineTo(0, 0 - radius);
      }
      ctx.fill();
      ctx.stroke();
      ctx.restore();
  }

  void mainMap() {
    view.mapCanvas.context2D.clearRect(0, 0, view.mapCanvas.width, view.mapCanvas.height);
    view.mapTitle.text = "World Map";
    view.mapImg.style.backgroundImage = 'url(files/system/worldmap.png)';
    Element WorldMap = querySelector("#WorldMapLayer");
    WorldMap.setInnerHtml('');
    WorldMap.hidden = false;
    // TODO: get from server
    String json = '''
{
  "alakol": {
    "name": "Alakol",
    "x": 360,
    "y": 129
  },
  "andra": {
    "name": "Andra",
    "x": 314,
    "y": 98
  },
  "aranna": {
    "name": "Aranna",
    "x": 397,
    "y": 24
  },
  "balzare": {
    "name": "Balzare",
    "x": 80,
    "y": 90
  },
  "baqala": {
    "name": "Baqala",
    "x": 355,
    "y": 78
  },
  "besara": {
    "name": "Besara",
    "x": 404,
    "y": 46
  },
  "bortola": {
    "name": "Bortola",
    "x": 405,
    "y": 99
  },
  "brillah": {
    "name": "Brillah",
    "x": 497,
    "y": 74
  },
  "callopee": {
    "name": "Callopee",
    "x": 449,
    "y": 43
  },
  "cauda": {
    "name": "Cauda",
    "x": 416,
    "y": 256
  },
  "chakraphool": {
    "name": "Chakra Phool",
    "x": 200,
    "y": 240
  },
  "choru": {
    "name": "Choru",
    "x": 354,
    "y": 56
  },
  "drifa": {
    "name": "Drifa",
    "x": 390,
    "y": -2
  },
  "fenneq": {
    "name": "Fenneq",
    "x": 431,
    "y": 225
  },
  "firozi": {
    "name": "Firozi",
    "x": 375,
    "y": 156
  },
  "folivoria": {
    "name": "Folivoria",
    "x": 258,
    "y": 63
  },
  "groddleforest": {
    "name": "Groddle Forest",
    "x": 340,
    "y": 191
  },
  "groddleheights": {
    "name": "Groddle Heights",
    "x": 310,
    "y": 171
  },
  "groddlemeadow": {
    "name": "Groddle Meadow",
    "x": 293,
    "y": 194
  },
  "haoma": {
    "name": "Haoma",
    "x": 78,
    "y": 118
  },
  "haraiva": {
    "name": "Haraiva",
    "x": 519,
    "y": 122
  },
  "ix": {
    "name": "Ix",
    "x": 122,
    "y": 53
  },
  "jal": {
    "name": "Jal",
    "x": 332,
    "y": 151
  },
  "jethimadh": {
    "name": "Jethimadh",
    "x": 241,
    "y": 248
  },
  "kajuu": {
    "name": "Kajuu",
    "x": 358,
    "y": 102
  },
  "kalavana": {
    "name": "Kalavana",
    "x": 196,
    "y": 266
  },
  "karnata": {
    "name": "Karnata",
    "x": 497,
    "y": 100
  },
  "kloro": {
    "name": "Kloro",
    "x": 71,
    "y": 143
  },
  "lida": {
    "name": "Lida",
    "x": 451,
    "y": 117
  },
  "massadoe": {
    "name": "Massadoe",
    "x": 446,
    "y": 19
  },
  "muufo": {
    "name": "Muufo",
    "x": 451,
    "y": 92
  },
  "nottis": {
    "name": "Nottis",
    "x": 344,
    "y": 9
  },
  "ormonos": {
    "name": "Ormonos",
    "x": 407,
    "y": 125
  },
  "pollokoo": {
    "name": "Pollokoo",
    "x": 445,
    "y": 66
  },
  "rasana": {
    "name": "Rasana",
    "x": 261,
    "y": 122
  },
  "roobrik": {
    "name": "Roobrik",
    "x": 120,
    "y": 100
  },
  "salatu": {
    "name": "Salatu",
    "x": 313,
    "y": 121
  },
  "samudra": {
    "name": "Samudra",
    "x": 285,
    "y": 147
  },
  "shimlamirch": {
    "name": "Shimla Mirch",
    "x": 238,
    "y": 219
  },
  "sura": {
    "name": "Sura",
    "x": 461,
    "y": 256
  },
  "tahli": {
    "name": "Tahli",
    "x": 263,
    "y": 94
  },
  "tamila": {
    "name": "Tamila",
    "x": 400,
    "y": 72
  },
  "uralia": {
    "name": "Uralia",
    "x": 125,
    "y": 125
  },
  "vantalu": {
    "name": "Vantalu",
    "x": 353,
    "y": 35
  },
  "xalanga": {
    "name": "Xalanga",
    "x": 305,
    "y": 43
  },
  "zhambu": {
    "name": "Zhambu",
    "x": 306,
    "y": 74
  }
}
    ''';

    Map hubs = JSON.decode(json);
    hubs.forEach((key, value) {
      DivElement hub = new DivElement()
        ..className = "wml-hub"
        ..id = "hub-" + key
        ..style.left = value['x'].toString() + 'px'
        ..style.top = value['y'].toString() + 'px'
        ..text = value['name'];
      WorldMap.append(hub);
    });

  }

  void hubMap() {
    // TODO: return to hub actions
    view.mapCanvas.context2D.clearRect(0, 0, view.mapCanvas.width, view.mapCanvas.height); // repopulate
    view.mapTitle.text = "World Map"; // set to hub
    view.mapImg.style.backgroundImage = 'url(files/system/worldmap.png)'; // set to hub
    querySelector("#WorldMapLayer").hidden = true;
  }
}