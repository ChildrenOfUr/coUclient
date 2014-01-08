part of coUclient;

Street currentStreet;


Camera camera = new Camera(500,500);
class Camera{
  num x,y;
  num zoom = 0; // for future eyeballery
  Camera(this.x,this.y){
    COMMANDS.add(['camera','sets the cameras position "camera x,y"',this.setCamera]);
  }
  // we're using css transitions for smooth scrolling.
  setCamera(String xy){//  format 'x,y'
    this.x = int.parse(xy.split(',')[0]); this.y = int.parse(xy.split(',')[1]);
  }
}


DivElement gameScreen = querySelector('#GameScreen');

class Street {    
  String label;
  Map _data;
  
  Rectangle bounds;
  
  Street(String streetName){
     _data = ASSET[streetName].get();
     
     // sets the label for the street
     label = _data['label'];
          
     bounds = new Rectangle(_data['dynamic']['l'],_data['dynamic']['t'],_data['dynamic']['l'].abs() + _data['dynamic']['r'].abs(),_data['dynamic']['t'].abs());
     }
  
  
 Future <List> load(){   
   // clean up old street data
   currentStreet = null; 
   
   // set the song.
   if (_data['music'] != null)
   setSong(_data['music']);
   
   
    // Collect the url's of each deco to load.
    List decosToLoad = [];
    for (Map layer in _data['dynamic']['layers'].values)
    {for (Map deco in layer['decos'])
      {if (decosToLoad.contains('http://revdancatt.github.io/CAT422-glitch-location-viewer/img/scenery/' + deco['filename'] + '.png')
            == false)
        decosToLoad.add('http://revdancatt.github.io/CAT422-glitch-location-viewer/img/scenery/' + deco['filename'] + '.png');
      }}
    
    
    // turn them into assets
    List assetsToLoad = [];
    for (String deco in decosToLoad){
      assetsToLoad.add(new Asset(deco));}
         
    // Load each of them, and then continue.
    Batch decos = new Batch(assetsToLoad);
    decos.load(setStreetLoadBar).then((_)
        {
    
    //Decos should all be loaded at this point//
    
    // set the street.
    currentStreet = this;
      
      
    /* //// Gradient Canvas //// */    
    CanvasElement gradientCanvas = new CanvasElement();
    gradientCanvas.id = 'gradient';
    gradientCanvas.style.zIndex = (-100).toString();
    gradientCanvas.width = bounds.width;
    gradientCanvas.height = bounds.height;
    gradientCanvas.style.position = 'absolute';
    gradientCanvas.style.left = '0 px';
    gradientCanvas.style.top =  '0 px'; 
    
    // Color the gradientCanvas
    var g = gradientCanvas.context2D.createLinearGradient(0,0,0,bounds.height);
    g.addColorStop(0,'#' + _data['gradient']['top']);
    g.addColorStop(1,'#' +  _data['gradient']['bottom']);
    gradientCanvas.context2D.fillStyle = g;
    gradientCanvas.context2D.fillRect(0,0,bounds.width,bounds.height);
    // Append it to the screen
    gameScreen.append(gradientCanvas);
    
    
    /* //// Scenery Canvases //// */
    //For each layer on the street . . .
    for (Map layer in new Map.from(_data['dynamic']['layers']).values){

      CanvasElement decoCanvas = new CanvasElement()
      ..classes.add('streetcanvas');
      decoCanvas.id = layer['name'];
      
      decoCanvas.style.zIndex = layer['z'].toString();
      decoCanvas.width = layer['w'];
      decoCanvas.height =  layer['h'];
        
      decoCanvas.style.position = 'absolute';
      decoCanvas.style.left = '0 px';
      decoCanvas.style.top =  '0 px';        
      
      //For each decoration in the layer, give its attributes and draw
      
      //TODO: FIX THIS
      //Parallax and such is working, BUT
      //Not all images are drawing at the correct y values.
      //It seems this int.y makes foreground and background work, but not middleground???
      for (Map deco in layer['decos']){
            
          int x = deco['x'] + bounds.width~/(gameScreen.clientWidth);
          int y = deco['y'] - deco['h'] + _data['dynamic']['ground_y'];
          int w = deco['w'];
          int h = deco['h'];
          int z = deco['z'];

         
          // only draw if the image is loaded.
          if (ASSET[deco['filename']] != null){
            if (layer['name'] == 'middleground')
              decoCanvas.context2D.drawImageScaled(ASSET[deco['filename']].get(), x, y + layer['h'], w, h);
            else
            decoCanvas.context2D.drawImageScaled(ASSET[deco['filename']].get(), x, y, w, h);
          }
          // Append the canvas to the screen
          gameScreen.append(decoCanvas);
          
          }
        }

        }
        // Done initializing street.
    );
  }  
   
 
  //Parallaxing: Adjust the position of each canvas in #GameScreen
  //based on the camera position and relative size of canvas to Street
  render(){
    
    num currentPercentX = camera.x / (bounds.width - gameScreen.clientWidth);
    num currentPercentY = camera.y / (bounds.height - gameScreen.clientHeight);

    //modify left and top for parallaxing
    for (CanvasElement canvas in gameScreen.querySelectorAll('canvas')){
      
      //Don't need to worry about gradientCanvas x changes
      if (canvas.id == 'gradient'){
      canvas.style.top =  ((canvas.height - gameScreen.clientHeight) * -currentPercentY).toString() + 'px';
      }
      else{
      double offSetX = (canvas.width - gameScreen.clientWidth) * -currentPercentX;
      double offSetY = (canvas.height - gameScreen.clientHeight) * -currentPercentY;

      canvas.style.position = 'absolute';
      canvas.style.left = (offSetX.toString()) + 'px';
      canvas.style.top =  (offSetY.toString()) + 'px';
      }
    }
   }

  }


// Initialization, loads all the streets in our master file into memory.
Future load_streets(){
  // allows us to load street files as though they are json files.
  jsonExtensions.add('street');

  // loads the master street json.
  new Asset('./assets/streets.json').load()
      .then((Asset streetList) {
        
        // Load each street file into memory. If this gets too expensive we'll move this elsewhere.
        List toLoad = [];
        for (String url in streetList.get().values)
        toLoad.add(new Asset(url).load());
        
        return Future.wait(toLoad);
        });
}

// the callback function for our deco loading 'Batch'
setStreetLoadBar(int percent){
  querySelector('#StreetLoadingStatus').text = 'loading decos...';
  querySelector('#MapLoadingBar').style.width = (percent + 1).toString() + '%';
  if (percent >= 99){
    querySelector('#StreetLoadingStatus').text = '...done';
    querySelector('#MapLoadingScreen').style.opacity = '0.0';
  }
}
