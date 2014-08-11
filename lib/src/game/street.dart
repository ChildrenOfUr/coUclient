part of couclient;

Street currentStreet;
String playerTeleFrom = "";

class Street 
{    
  String label;
  Map _data;
  
  List<Platform> platforms = new List();
  List<Ladder> ladders = new List();
  
  String hub_id;
  
  Rectangle bounds;
  
  Street(String streetName)
  {
    _data = ASSET[streetName].get();

    // sets the label for the street
    label = _data['label'];
    hub_id = _data['hub_id'];
    
    //if(chat.username != null)
      //sendLeftMessage(label);
          
    bounds = new Rectangle(_data['dynamic']['l'],
                _data['dynamic']['t'],
                _data['dynamic']['l'].abs() + _data['dynamic']['r'].abs(),
                _data['dynamic']['t'].abs());
    
    ui.playerHolder..children.clear()
    	..style.width = bounds.width.toString()+'px'
    	..style.height = bounds.height.toString()+'px'
    	..classes.add('streetcanvas')
    	..style.position = "absolute"
    	..attributes["ground_y"] = "0"
    	..style.transform = "translateZ(0)";
    
    /*if(entities != null)
    	entities.clear();
    if(quoins != null)
    	quoins.clear();
    if(otherPlayers != null)
		otherPlayers.clear();*/
  }
  
  Future <List> load()
  {   
    Completer c = new Completer();
    // clean up old street data
    //currentStreet = null;
    ui.layers.children.clear();
    ui.playerHolder.children.clear(); //clear previous street's quoins and stuff
   
    // set the song loading if necessary
    if (_data['music'] != null)
      soundManager.setSong(_data['music']);
   
    // Collect the url's of each deco to load.
    List decosToLoad = [];
    for (Map layer in _data['dynamic']['layers'].values)
    {
      for (Map deco in layer['decos'])
      {
        if (!decosToLoad.contains('http://childrenofur.com/locodarto/scenery/' + deco['filename'] + '.png'))
              decosToLoad.add('http://childrenofur.com/locodarto/scenery/' + deco['filename'] + '.png');
      }
    }
    
    // turn them into assets
    List assetsToLoad = [];
    for (String deco in decosToLoad)
    {
      assetsToLoad.add(new Asset(deco));
    }
    
    // Load each of them, and then continue.
    Batch decos = new Batch(assetsToLoad);
    decos.load(setStreetLoadBar).then((_)
        {
      //Decos should all be loaded at this point//
      
      // set the street.
      currentStreet = this;
      
      int groundY = -(_data['dynamic']['ground_y'] as num).abs();
          
      DivElement interactionCanvas = new DivElement()
        ..classes.add('streetcanvas')
        ..style.pointerEvents = "auto"
        ..id = "interractions"
        ..style.width = bounds.width.toString() + "px"
        ..style.height = bounds.height.toString() + "px"
        ..style.position = 'absolute'
        ..attributes['ground_y'] = groundY.toString();
                    
      /* //// Gradient Canvas //// */
      DivElement gradientCanvas = new DivElement();
      gradientCanvas.classes.add('streetcanvas');
      gradientCanvas.id = 'gradient';
      gradientCanvas.style.zIndex = (-100).toString();
      gradientCanvas.style.width = bounds.width.toString() + "px";
      gradientCanvas.style.height = bounds.height.toString() + "px";
      gradientCanvas.style.position = 'absolute';
      gradientCanvas.attributes['ground_y'] = "0";
      
      // Color the gradientCanvas
      String top = _data['gradient']['top'];
      String bottom = _data['gradient']['bottom'];
      gradientCanvas.style.background = "-webkit-linear-gradient(top, #$top, #$bottom)";
      gradientCanvas.style.background = "-moz-linear-gradient(top, #$top, #$bottom)";
      gradientCanvas.style.background = "-ms-linear-gradient(#$top, #$bottom)";
      gradientCanvas.style.background = "-o-linear-gradient(#$top, #$bottom)";
      
      // Append it to the screen*/
      ui.layers.append(gradientCanvas);
        
      /* //// Scenery Canvases //// */
      //For each layer on the street . . .
      for(Map layer in new Map.from(_data['dynamic']['layers']).values)
      {
        DivElement decoCanvas = new DivElement()
          ..classes.add('streetcanvas');
        decoCanvas.id = (layer['name'] as String).replaceAll(" ", "_");
        
        decoCanvas.style.zIndex = layer['z'].toString();
        decoCanvas.style.width = layer['w'].toString() + 'px';
        decoCanvas.style.height = layer['h'].toString() + 'px';
        decoCanvas.style.position = 'absolute';
        decoCanvas.attributes['ground_y'] = groundY.toString();
        
        List<String> filters = new List();
        new Map.from(layer['filters']).forEach((String filterName, int value)
        {
          //blur is super expensive (seemed to cut my framerate in half)
          if(localStorage["GraphicsBlur"] == "true" && filterName == "blur")
          {
            filters.add('blur('+value.toString()+'px)');
          }
          if(filterName == "brightness")
          {
            if(value < 0) 
              filters.add('brightness(' + (1-(value/-100)).toString() +')');
            if (value > 0)
              filters.add('brightness(' + (1+(value/100)).toString() +')');
          }
          if(filterName == "contrast")
          {
            if (value < 0) 
              filters.add('contrast(' + (1-(value/-100)).toString() +')');
            if (value > 0)
              filters.add('contrast(' + (1+(value/100)).toString() +')');
          }
          if(filterName == "saturation")
          {
            if (value < 0) 
              filters.add('saturation(' + (1-(value/-100)).toString() +')');
            if (value > 0)
              filters.add('saturation(' + (1+(value/100)).toString() +')');
          }
        });
        decoCanvas.style.filter = filters.join(' ');
          
        //For each decoration in the layer, give its attributes and draw
        for(Map deco in layer['decos'])
        {
  			int x = deco['x'] - deco['w']~/2;
  			int y = deco['y'] - deco['h'] + groundY;
  			if(layer['name'] == 'middleground')
  			{
    			//middleground has different layout needs
				y += layer['h'];
				x += layer['w']~/2;
  			}
          	new Deco(deco,x,y,decoCanvas);
        }
        
        for(Map platformLine in layer['platformLines'])
		{
            platforms.add(new Platform(platformLine,layer,groundY));
		}

        platforms.sort((x,y) => x.compareTo(y));
        
        //debug only: draw platforms
        /*platforms.forEach((Platform platform)
        {
          Element rect = new DivElement();
          rect.text = "(${platform.start.x},${platform.start.y}) - (${platform.end.x},${platform.end.y})";
          rect.style.width = (platform.end.x-platform.start.x).toString() + "px";
          rect.style.height = (platform.end.y-platform.start.y).toString() + "px";
          rect.style.left = platform.start.x.toString()+"px";
          rect.style.top = platform.start.y.toString()+"px";
          rect.style.border = "1px black solid";
          rect.style.position = "absolute";
          rect.style.zIndex = "100";
          decoCanvas.append(rect);
        });*/
        
        for(Map ladder in layer['ladders'])
        {
			int x,y,width,height;
			String id;
  
			width = ladder['w'];
			height = ladder['h'];
			x = ladder['x']+layer['w']~/2-width~/2;
			y = ladder['y']+layer['h']-height+groundY;
			id = ladder['id'];
  
			Rectangle box = new Rectangle(x,y,width,height);
			ladders.add(new Ladder(id,box));
		}
        
        //debug only: draw ladders
        /*for(Ladder ladder in ladders)
        {
          Element rect = new DivElement();
          rect.style.width = ladder.boundary.width.toString() + "px";
          rect.style.height = ladder.boundary.height.toString() + "px";
          rect.style.left = ladder.boundary.left.toString()+"px";
          rect.style.top = ladder.boundary.top.toString()+"px";
          rect.style.border = "1px black solid";
          rect.style.position = "absolute";
          rect.style.zIndex = "100";
          decoCanvas.append(rect);
        }*/
        
		for (Map signpost in layer['signposts'])
        {
			int x = signpost['x'];
			int y = signpost['y'] - signpost['h'] + groundY;
			if(layer['name'] == 'middleground')
  			{
    			//middleground has different layout needs
				y += layer['h'];
				x += layer['w']~/2;
  			}
          
			new Signpost(signpost,x,y,interactionCanvas,gradientCanvas);
        }
        
        // Append the canvas to the screen
        ui.layers.append(decoCanvas);
	}
      
    ui.layers.append(interactionCanvas);
      
    //display current street name     
	ui.currLocation.text = label;
      
	//make sure to redraw the screen (in case of street switching)
      camera.dirty = true;
      c.complete(this);
      //sendJoinedMessage(label,_data['tsid']);
    });
        // Done initializing street.
    return c.future;
  }
  
  //Parallaxing: Adjust the position of each canvas in #GameScreen
  //based on the camera position and relative size of canvas to Street
  render()
  {
    //only update if camera x,y have changed since last render cycle
    if(camera.dirty)
    {
      num currentPercentX = camera.getX() / (bounds.width - ui.worldWidth);
      num currentPercentY = camera.getY() / (bounds.height - ui.worldHeight);
      
      //modify left and top for parallaxing
      Map<String,DivElement> transforms = new Map();
      for(DivElement canvas in ui.worldElement.querySelectorAll('.streetcanvas'))
      {
        int canvasWidth = num.parse(canvas.style.width.replaceAll('px', '')).toInt();
        int canvasHeight = num.parse(canvas.style.height.replaceAll('px', '')).toInt();
        double offsetX = (canvasWidth - ui.worldWidth) * currentPercentX;
        double offsetY = (canvasHeight - ui.worldHeight) * currentPercentY;
        
        int groundY = num.parse(canvas.attributes['ground_y']).toInt();
        offsetY += groundY;
  
        //translateZ(0) forces the gpu to render the transform
        transforms[canvas.id+"translateZ(0) translateX("+(-offsetX).toString()+"px) translateY("+(-offsetY).toString()+"px)"] = canvas;
      }
      //try to bundle DOM writes together for performance.
      transforms.forEach((String transform, DivElement canvas)
      {
        transform = transform.replaceAll(canvas.id, '');
        canvas.style.transform = transform;
      });     
      camera.dirty = false;
    }
  }
}

// Initialization, loads all the streets in our master file into memory.
Future load_streets()
{
  ui.loadStatus.text = "Loading Streets";
  // allows us to load street files as though they are json files.
  jsonExtensions.add('street');
  
  Completer c = new Completer();

  // loads the master street json.
  new Asset('./assets/streets.json').load().then((Asset streetList) 
  {
    // Load each street file into memory. If this gets too expensive we'll move this elsewhere.
    List toLoad = [];
    for (String url in streetList.get().values)
      toLoad.add(new Asset(url).load(statusElement:ui.loadStatus2));
    
    c.complete(Future.wait(toLoad));
  });
  
  return c.future;
}

// the callback function for our deco loading 'Batch'
setStreetLoadBar(int percent)
{
  //streetLoadingStatus.text = 'loading decos...';
  //mapLoadingBar.style.width = (percent + 1).toString() + '%';
  if (percent >= 99)
  {
    //streetLoadingStatus.text = '...done';
    //mapLoadingScreen.className = "MapLoadingScreen";
    querySelector("#streetLoading").style.opacity = '0.0';
  }
}