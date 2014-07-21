part of coUclient;

Street currentStreet;

Camera camera = new Camera(0,400);
class Camera
{
  int _x,_y;
  int zoom = 0; // for future eyeballery
  bool dirty = true;
  Rectangle visibleRect;
  Camera(this._x,this._y)
  {
      COMMANDS.add(['camera','sets the cameras position "camera x,y"',this.setCamera]);
  }
  
    // we're using css transitions for smooth scrolling.
  void setCamera(String xy) //  format 'x,y'
  {
    try
    {
      int newX = int.parse(xy.split(',')[0]);
      int newY = int.parse(xy.split(',')[1]);
      if(newX != _x || newY != _y)
        dirty = true;
      _x = newX;
      _y = newY;
      visibleRect = new Rectangle(_x,_y,ui.gameScreenWidth,ui.gameScreenHeight);
    }
    catch (error)
    {
      printConsole("error: format must be camera [num],[num]: $error");
    }
  }
  
  int getX() => _x;
  int getY() => _y;
}

class Platform
{
  Point start, end;
  String id;
  bool itemPerm, pcPerm;
  Platform(this.id,this.start,this.end,[this.itemPerm = false, this.pcPerm = false]);
  
  String toString()
  {
    return "(${start.x},${start.y})->(${end.x},${end.y})";
  }
  
  int compareTo(Platform other)
  {
    return other.start.y - start.y;
  }
}

class Ladder
{
  Rectangle boundary;
  String id;
  Ladder(this.id,this.boundary);
}

class WorldMap
{
  Map<String,String> hubInfo;
  Map<String,Map> hubMaps;
  Map<String,String> moteInfo;
  
  DataMaps map = new DataMaps();
  
  WorldMap(String hub_id){
    hubInfo = map.data_maps_hubs[hub_id]();
    hubMaps = map.data_maps_maps[hub_id]();
    moteInfo = map.data_maps_streets['9']();   
    mapTitle.text = hubInfo['name'];
    mapImg.style.backgroundImage = 'url(' +hubInfo['bg']+ ')';
    //mapImg.setInnerHtml('<img src="' + hubInfo['fg']+ '"/>');
    mapCanvas.context2D.clearRect(0, 0, mapCanvas.width, mapCanvas.height);
    
    CanvasElement lineCanvas = new CanvasElement();
    CanvasElement textCanvas = new CanvasElement();
    
    lineCanvas.context2D.lineCap="round";
    lineCanvas.context2D.strokeStyle = "rgba(255, 255, 240, 0.5)";
    
    textCanvas.width = mapCanvas.width;
    textCanvas.height = mapCanvas.height;
    textCanvas.context2D.fillStyle = "#000000";
    
    mapCanvas.context2D.miterLimit=2;
    
    // TODO: Low priority, performance improvement
   
    for (Map object in hubMaps['objs'].values) {

      // Street Objects
      if (object['type'] == 'S') {
        String streetName = moteInfo[hub_id][object['tsid']];    
        int streetMiddleX = ((object['x1']+object['x2'])/2).round();
        int streetMiddleY = ((object['y1']+object['y2'])/2).round();
        
        
             lineCanvas.width = mapCanvas.width;
             lineCanvas.height = mapCanvas.height;
             lineCanvas.context2D.lineCap="round";
             lineCanvas.context2D.miterLimit=2;
             lineCanvas.context2D.strokeStyle = "rgba(255, 255, 240, 0.5)";
             
             // If this is the street we are on, style is slightly different
             if (object['tsid'].substring(1) == currentStreet._data['tsid'].substring(1)) {
               lineCanvas.context2D.strokeStyle = "rgba(255, 255, 240, 1)";
             }
             
             lineCanvas.context2D.lineWidth = 5;
             lineCanvas.context2D.moveTo(object['x1'],object['y1']);
             lineCanvas.context2D.lineTo(object['x2'],object['y2']);
             lineCanvas.context2D.stroke();
             mapCanvas.context2D.drawImage(lineCanvas, 0, 0);
             
             //mapCanvas.context2D.beginPath();

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
             if (object['tsid'].substring(1) == currentStreet._data['tsid'].substring(1)) {
               textCanvas.context2D.fillStyle = "#C50101";
               textCanvas.context2D.font = "15px Arial bold";
             }
             
             textCanvas.context2D.lineWidth = 3;
             textCanvas.context2D.strokeStyle = "#FFFFFF";
             textCanvas.context2D.strokeText(streetName,(streetMiddleX - (mapCanvas.context2D.measureText(streetName).width / 2)), (streetMiddleY + 4));
             textCanvas.context2D.fillText(streetName,(streetMiddleX - (mapCanvas.context2D.measureText(streetName).width / 2)), (streetMiddleY + 4));
             
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
        mapCanvas.context2D.beginPath();
        mapCanvas.context2D.arc(object['x'], object['y'], 18, 0, 2 * PI, false);
        mapCanvas.context2D.fillStyle = map.data_maps_hubs[object['hub_id']]()['color'];
        mapCanvas.context2D.fill();
        mapCanvas.context2D.lineWidth = 2;
        mapCanvas.context2D.font = "18px Arial";
        mapCanvas.context2D.fillStyle = '#FFFFFF';
        mapCanvas.context2D.fillText('GO',object['x']-14, object['y']+7);
        
        // Drawing the name of the region, angle specified in 'label', trig to ajdust pos based on angle
        mapCanvas.context2D.font = "14px Arial";
        mapCanvas.context2D.strokeStyle = '#FFFFFF';
        mapCanvas.context2D.stroke();
        mapCanvas.context2D.lineWidth = 4;
        mapCanvas.context2D.strokeText('To: ' + map.data_maps_hubs[object['hub_id']]()['name'], 
            object['x'] + (sin(PI/180*object['label']) * 70) - mapCanvas.context2D.measureText(map.data_maps_hubs[object['hub_id']]()['name']).width * .8, 
            object['y'] - (cos(PI/180*object['label']) * 35) + 8);
        mapCanvas.context2D.lineWidth = .9;
        mapCanvas.context2D.strokeStyle = map.data_maps_hubs[object['hub_id']]()['color'];
        mapCanvas.context2D.strokeText('To: ' + map.data_maps_hubs[object['hub_id']]()['name'], 
            object['x'] + (sin(PI/180*object['label']) * 70) - mapCanvas.context2D.measureText(map.data_maps_hubs[object['hub_id']]()['name']).width * .8, 
            object['y'] - (cos(PI/180*object['label']) * 35) + 8);
      }
    }
    mapCanvas.context2D.drawImage(lineCanvas, 0, 0);
    mapCanvas.context2D.drawImage(textCanvas, 0, 0);
  }
}

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
    
    if(chat.username != null)
      sendLeftMessage(label);
          
    bounds = new Rectangle(_data['dynamic']['l'],
                _data['dynamic']['t'],
                _data['dynamic']['l'].abs() + _data['dynamic']['r'].abs(),
                _data['dynamic']['t'].abs());
    
    playerHolder.children.clear();
    playerHolder.style.width = bounds.width.toString()+'px';
    playerHolder.style.height = bounds.height.toString()+'px';
    playerHolder.classes.add('streetcanvas');
    playerHolder.style.position = "absolute";
    playerHolder.attributes["ground_y"] = "0";
    playerHolder.style.transform = "translateZ(0)";
    
    if(npcs != null)
      npcs.clear();
    if(quoins != null)
      quoins.clear();
    if(otherPlayers != null)
      otherPlayers.clear();
  }
  
  Future <List> load()
  {   
    Completer c = new Completer();
    // clean up old street data
    //currentStreet = null;
    layers.children.clear();
    querySelector("#PlayerHolder").children.clear(); //clear previous street's quoins and stuff
   
    // set the song loading if necessary
    if (_data['music'] != null)
      setSong(_data['music']);
   
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
      layers.append(gradientCanvas);
        
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
          int w = deco['w'];
          int h = deco['h'];
          int z = deco['z'];
            
          // only draw if the image is loaded.
          if (ASSET[deco['filename']] != null)
          {
            ImageElement d = ASSET[deco['filename']].get();
            
            //resize the image now so that it doesn't have to be done each time
            //it comes into view by the browser's rendering engine
            //TODO maybe uncomment someday - looks terrible
            /*if(w != d.naturalWidth || h != d.naturalHeight)
            {
              print("need to resize ${deco['filename']} from ${d.naturalWidth}x${d.naturalHeight} to ${w}x${h}");
                          resizeImage(d,w,h);
                          print("new size is ${d.width}x${d.height}");
            }*/
            
            d.style.position = 'absolute';
            d.style.left = x.toString() + 'px';
            d.style.top = y.toString() + 'px';
            d.style.width = w.toString() + 'px';
            d.style.height = h.toString() + 'px';
            d.style.zIndex = z.toString();
            
            String transform = "";
            if(deco['r'] != null)
            {
              transform += "rotate("+deco['r'].toString()+"deg)";
              d.style.transformOrigin = "50% bottom 0";
            }
            if(deco['h_flip'] != null && deco['h_flip'] == true)
                          transform += " scale(-1,1)";
            d.style.transform = transform;
            decoCanvas.append(d.clone(false));
          }
        }
        
        for(Map platformLine in layer['platformLines'])
          {
          Point start, end;
          (platformLine['endpoints'] as List).forEach((Map endpoint)
          {
            if(endpoint["name"] == "start")
            {
              start = new Point(endpoint["x"],endpoint["y"]+groundY);
              if(layer['name'] == 'middleground')
                start = new Point(endpoint["x"]+layer['w']~/2,endpoint["y"]+layer['h']+groundY);
            }
            if(endpoint["name"] == "end")
            {
              end = new Point(endpoint["x"],endpoint["y"]+groundY);
              if(layer['name'] == 'middleground')
                end = new Point(endpoint["x"]+layer['w']~/2,endpoint["y"]+layer['h']+groundY);
            }
          });
            platforms.add(new Platform(platformLine['id'],start,end));
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
          
          DivElement pole = new DivElement()
            ..style.backgroundImage = "url('http://childrenofur.com/locodarto/scenery/sign_pole.png')"
            ..style.backgroundRepeat = "no-repeat"
            ..style.width = signpost['w'].toString() + "px"
            ..style.height = signpost['h'].toString() + "px"
            ..style.position = "absolute"
            ..style.top = y.toString() + "px"
            ..style.left = (x-48).toString() + "px";
          interactionCanvas.append(pole);
          
          int i=0;
          List signposts = signpost['connects'] as List;
          for(Map<String,String> exit in signposts)
          {
            if(exit['label'] == playerTeleFrom || playerTeleFrom == "console")
            {
              if(playerTeleFrom == "console")
                print("setting x: $x, y: $y");
              CurrentPlayer.posX = x;
              CurrentPlayer.posY = y;
            }
            
            String tsid = exit['tsid'].replaceFirst("L", "G");
            SpanElement span = new SpanElement()
                    ..style.position = "absolute"
                  ..style.top = (y+i*25+10).toString() + "px"
                  ..style.left = x.toString() + "px"
                  ..text = exit["label"]
                  ..className = "ExitLabel"
                                ..attributes['url'] = 'http://RobertMcDermot.github.io/CAT422-glitch-location-viewer/locations/$tsid.callback.json'
                                ..attributes['tsid'] = tsid
                ..attributes['from'] = currentStreet.label
                                ..style.transform = "rotate(-5deg)";
            
            if(i %2 != 0)
            {
              gradientCanvas.append(span);
              span.style.left = (x-span.clientWidth).toString() + "px";
              span.style.transform = "rotate(5deg)";
            }

            interactionCanvas.append(span);
            i++;
          }
        }
        
        // Append the canvas to the screen
        layers.append(decoCanvas);
      }
      
      layers.append(interactionCanvas);
      
      //display current street name     
        currLocation.text = label;
      
      //make sure to redraw the screen (in case of street switching)
      camera.dirty = true;
      c.complete(this);
      sendJoinedMessage(label);
    });
        // Done initializing street.
    return c.future;
  }
  
  void resizeImage(ImageElement imageObject, int newWidth, int newHeight) 
  {
    // New canvas
        CanvasElement canvas = new CanvasElement();
        canvas.width = newWidth;
        canvas.height = newHeight;

        // Draw Image content in canvas
        CanvasRenderingContext2D context = canvas.context2D;        
        context.drawImageScaled(imageObject, 0, 0, newWidth, newHeight);

        // Replace source of Image
        imageObject.src = canvas.toDataUrl();
    }
 
  //Parallaxing: Adjust the position of each canvas in #GameScreen
  //based on the camera position and relative size of canvas to Street
  render()
  {
    //only update if camera x,y have changed since last render cycle
    if(camera.dirty)
    {
      num currentPercentX = camera.getX() / (bounds.width - ui.gameScreenWidth);
      num currentPercentY = camera.getY() / (bounds.height - ui.gameScreenHeight);
      
      //modify left and top for parallaxing
      Map<String,DivElement> transforms = new Map();
      for(DivElement canvas in gameScreen.querySelectorAll('.streetcanvas'))
      {
        int canvasWidth = int.parse(canvas.style.width.replaceAll('px', ''));
        int canvasHeight = int.parse(canvas.style.height.replaceAll('px', ''));
        double offsetX = (canvasWidth - ui.gameScreenWidth) * currentPercentX;
        double offsetY = (canvasHeight - ui.gameScreenHeight) * currentPercentY;
        
        int groundY = int.parse(canvas.attributes['ground_y']);
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
  loadStatus.text = "Loading Streets";
  // allows us to load street files as though they are json files.
  jsonExtensions.add('street');
  
  Completer c = new Completer();

  // loads the master street json.
  new Asset('./assets/streets.json').load().then((Asset streetList) 
  {
    // Load each street file into memory. If this gets too expensive we'll move this elsewhere.
    List toLoad = [];
    for (String url in streetList.get().values)
      toLoad.add(new Asset(url).load(statusElement:loadStatus2));
    
    c.complete(Future.wait(toLoad));
  });
  
  return c.future;
}

// the callback function for our deco loading 'Batch'
setStreetLoadBar(int percent)
{
  streetLoadingStatus.text = 'loading decos...';
  mapLoadingBar.style.width = (percent + 1).toString() + '%';
  if (percent >= 99)
  {
    streetLoadingStatus.text = '...done';
    mapLoadingScreen.className = "MapLoadingScreen";
    mapLoadingScreen.style.opacity = '0.0';
  }
}