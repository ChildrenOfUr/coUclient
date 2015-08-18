part of couclient;

Street currentStreet;
String playerTeleFrom = "";

class Street {
  Map streetData;

  List<Platform> platforms = new List();
  List<Ladder> ladders = new List();
  List<Wall> walls = new List();
  List<Signpost> signposts = new List();

  String hub_id, hub_name, _tsid;
  String street_load_color_top;
  String street_load_color_btm;

  int groundY;
  bool loaded = false;

  DataMaps map = new DataMaps();

  String get tsid {
    if (_tsid.startsWith('G')) {
      _tsid = _tsid.replaceFirst('G', 'L');
    }
    return _tsid;
  }

  String get label {
    String hub_id = currentStreet.hub_id;
    String currentStreetName;
    Map<int, Map<String, String>> moteInfo = map.data_maps_streets['9']();
    currentStreetName = moteInfo[hub_id][tsid];

    return currentStreetName;
  }

  Stopwatch loadTime;

  Rectangle bounds;

  Street(this.streetData) {
    _tsid = streetData['tsid'];
    hub_id = streetData['hub_id'];

    if (game.username != null && currentStreet != null)
      sendLeftMessage(currentStreet.label);

    bounds = new Rectangle(streetData['dynamic']['l'],
    streetData['dynamic']['t'],
    streetData['dynamic']['l'].abs() + streetData['dynamic']['r'].abs(),
    (streetData['dynamic']['t'] - streetData['dynamic']['b']).abs());

    view.playerHolder
      ..style.width = bounds.width.toString() + 'px'
      ..style.height = bounds.height.toString() + 'px'
      ..classes.add('streetcanvas')
      ..style.position = "absolute"
      ..attributes["ground_y"] = "0"
      ..attributes['width'] = bounds.width.toString()
      ..attributes['height'] = bounds.height.toString()
      ..style.transform = "translateZ(0)";

    // set the street.
    loaded = false;
    currentStreet = this;
    sendJoinedMessage(currentStreet.label);
  }

  Future load() async {
    // clean up old street data
    entities.clear();
    quoins.clear();
    otherPlayers.clear();
    if (CurrentPlayer != null) {
      CurrentPlayer.intersectingObjects.clear();
    }

    view.layers.children.clear();
    view.playerHolder.children.clear();

    view.location = label;

    // Load the music
    if (streetData["music"] != null) {
      // Attempt to get music from server
      audio.setSong(streetData["music"]);
      print("[StreetService] Loaded song ${streetData["music"]} from server");
    } else {
      // Otherwise, get stored preset music
      audio.setSong(mapData.getSong(label));
    }

    // Collect the url's of each deco to load.
    List decosToLoad = [];
    for (Map layer in streetData['dynamic']['layers'].values) {
      String layerName = layer['name'].replaceAll(' ', '_');
      String url = 'http://childrenofur.com/assets/streetLayers/$tsid/$layerName.png';
      if (!decosToLoad.contains(url)) {
        decosToLoad.add(url);
      }
    }

    // turn them into assets
    List assetsToLoad = [];
    for (String deco in decosToLoad) {
      assetsToLoad.add(new Asset(deco));
    }

    // Load each of them, and then continue.
    Batch decos = new Batch(assetsToLoad);
    await decos.load(setLoadingPercent);
    //Decos should all be loaded at this point//

    groundY = -(streetData['dynamic']['ground_y'] as num).abs();

    /* //// Gradient Canvas //// */
    DivElement gradientCanvas = new DivElement();

    // Color the gradientCanvas
    String top = streetData['gradient']['top'];
    String bottom = streetData['gradient']['bottom'];

    gradientCanvas
      ..classes.add('streetcanvas')
      ..id = 'gradient'
      ..attributes['ground_y'] = "0"
      ..attributes['width'] = bounds.width.toString()
      ..attributes['height'] = bounds.height.toString();
    gradientCanvas.style
      ..zIndex = (-100).toString()
      ..width = bounds.width.toString() + "px"
      ..height = bounds.height.toString() + "px"
      ..position = 'absolute'
      ..background = 'linear-gradient(to bottom, #$top, #$bottom)';

    // Append it to the screen*/
    view.layers.append(gradientCanvas);

    /* //// Scenery Canvases //// */
    //For each layer on the street . . .
    for (Map layer in new Map.from(streetData['dynamic']['layers']).values) {
      DivElement decoCanvas = new DivElement()
        ..classes.add('streetcanvas');
      decoCanvas.id = (layer['name'] as String).replaceAll(" ", "_");

      decoCanvas.style.zIndex = layer['z'].toString();
      decoCanvas.style.width = layer['w'].toString() + 'px';
      decoCanvas.style.height = layer['h'].toString() + 'px';
      decoCanvas.style.position = 'absolute';
      decoCanvas.attributes['ground_y'] = groundY.toString();
      decoCanvas.attributes['width'] = layer['w'].toString();
      decoCanvas.attributes['height'] = layer['h'].toString();

      //put the one layer image in
      try {
        String layerName = layer['name'].replaceAll(' ', '_');
        ImageElement layerImage = ASSET[layerName].get();
        layerImage.style.transform = 'translateY(${groundY}px)';
        decoCanvas.append(layerImage);
      } catch(e) {
        logmessage("Could not load layer image ${layer["name"]}");
      }

      for (Map platformLine in layer['platformLines']) {
        platforms.add(new Platform(platformLine, layer, groundY));
      }

      platforms.sort((x, y) => x.compareTo(y));

      for (Map ladder in layer['ladders']) {
        ladders.add(new Ladder(ladder, layer, groundY));
      }

      for (Map wall in layer['walls']) {
        if (wall['pc_perm'] == 0) {
          continue;
        }
        walls.add(new Wall(wall, layer, groundY));
      }

      if (showCollisionLines) {
        showLineCanvas();
      }

      for (Map signpost in layer['signposts']) {
        int h = 200, w = 100;

        if (signpost['h'] != null) {
          h = signpost['h'];
        }

        if (signpost['w'] != null) {
          w = signpost['w'];
        }

        int x = signpost['x'] - w ~/ 2;
        int y = signpost['y'] - h;

        if (layer['name'] == 'middleground') {
          //middleground has different layout needs
          y += layer['h'];
          x += layer['w'] ~/ 2;
        }

        new Signpost(signpost, x, y);

        // show signpost in minimap {

        List<String> connects = signpost['connects'];
        List<String> streets = new List();

        for (Map exit in connects) {
          streets.add(exit['label']);
        }

        minimap.currentStreetExits.add({
          "streets": streets,
          "x": x,
          "y": y
        });

        // } end minimap code

      }

      // Append the canvas to the screen
      view.layers.append(decoCanvas);
    }

    //make sure to redraw the screen (in case of street switching)
    camera.dirty = true;
    loaded = true;
    // Done initializing street.
  }

  //Parallaxing: Adjust the position of each canvas in #GameScreen
  //based on the camera position and relative size of canvas to Street
  render() {
    //only update if camera x,y have changed since last render cycle
    if (camera.dirty) {
      num currentPercentX = camera.getX() / (bounds.width - view.worldElementWidth);
      num currentPercentY = camera.getY() / (bounds.height - view.worldElementHeight);

      //modify left and top for parallaxing
      for (Element canvas in view.worldElement.querySelectorAll('.streetcanvas')) {
        Map attributes = canvas.attributes;
        num canvasWidth = num.parse(attributes['width']);
        num canvasHeight = num.parse(attributes['height']);
        num offsetX = (canvasWidth - view.worldElementWidth) * currentPercentX;
        num offsetY = (canvasHeight - view.worldElementHeight) * currentPercentY;

        num groundY = num.parse(attributes['ground_y']);
        offsetY += groundY;

        canvas.style.transform = "translateZ(0) translateX(${-offsetX}px) translateY(${-offsetY}px)";
      }

      camera.dirty = false;
    }
  }
}

// Initialization, loads all the streets in our master file into memory.
Future load_street() {
  view.loadStatus.text = "Loading Streets";
  // allows us to load street files as though they are json files.
  jsonExtensions.add('street');

  Completer c = new Completer();

  // loads the master street json.
  new Asset('packages/couclient/json/streets.json').load().then((Asset streetList) {
    // Load each street file into memory. If this gets too expensive we'll move this elsewhere.
    List toLoad = [];
    for (String url in streetList.get().values)
      toLoad.add(new Asset(url).load(statusElement: view.loadStatus2));

    c.complete(Future.wait(toLoad));
  });

  return c.future;
}

setStreetLoading() {
  view.mapLoadingScreen.style.background =
  '-webkit-gradient(linear,left top,left bottom,color-stop(0, ' + currentStreet.street_load_color_top +
  '),color-stop(1, ' + currentStreet.street_load_color_btm + '))';
  view.mapLoadingScreen.style.background =
  '-o-linear-gradient(bottom, ' + currentStreet.street_load_color_top + ' 0%, ' +
  currentStreet.street_load_color_btm + ' 100%)';
  view.mapLoadingScreen.style.background =
  '-moz-linear-gradient(bottom, ' + currentStreet.street_load_color_top + ' 0%, ' +
  currentStreet.street_load_color_btm + ' 100%)';
  view.mapLoadingScreen.style.background =
  '-webkit-linear-gradient(bottom, ' + currentStreet.street_load_color_top + ' 0%, ' +
  currentStreet.street_load_color_btm + ' 100%)';
  view.mapLoadingScreen.style.background =
  '-ms-linear-gradient(bottom, ' + currentStreet.street_load_color_top + ' 0%, ' +
  currentStreet.street_load_color_btm + ' 100%)';
  view.mapLoadingScreen.style.background =
  'linear-gradient(to bottom, ' + currentStreet.street_load_color_top + ' 0%, ' +
  currentStreet.street_load_color_btm + ' 100%)';
}

// the callback function for our deco loading 'Batch'
setLoadingPercent(int percent) {
  view.streetLoadingBar.attributes['percent'] = percent.toString();
  currentStreet.loadTime = new Stopwatch();
  currentStreet.loadTime.start();

  if (percent >= 99) {
    //TODO: Whatever '1000' is changed to, that's how long it takes to display street image
    new KeepingTime().delayMilliseconds(1000 - currentStreet.loadTime.elapsedMilliseconds);
    view.streetLoadingBar.attributes['status'] = '    done! ... 100%';
    view.streetLoadingBar.attributes['percent'] = '100';
    view.mapLoadingScreen.className = "MapLoadingScreen";
    view.mapLoadingScreen.style.opacity = '0.0';
    minimap.containerE.hidden = false;
    gpsIndicator.loadingNew = false;
    new Timer(new Duration(seconds: 1), () => view.mapLoadingContent.style.opacity = '0.0');
    currentStreet.loadTime.stop();
    currentStreet.loadTime.reset();
  }
  else {
    view.streetLoadingBar.attributes['status'] = 'reticulating splines ... ' + (percent).toString() + '%';
    view.streetLoadingBar.attributes['percent'] = percent.toString();
  }
}

//test stopwatch

class KeepingTime {
  Stopwatch watch;

  KeepingTime() {
    watch = new Stopwatch();
  }

  void delayMilliseconds(int milliseconds) {
    watch.start();

    while (watch.elapsedMilliseconds < (milliseconds));

    watch.stop();
  }
}