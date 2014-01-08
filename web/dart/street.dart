part of coUclient;

Street currentStreet;

class Camera{
  num x,y;
  Camera(this.x,this.y){
    COMMANDS.add(['camera','',this.setCamera]);
  }
  setCamera(String xy){
    this.x = int.parse(xy.split(',')[0]); this.y = int.parse(xy.split(',')[1]);}
}


Camera camera = new Camera(300,0);



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


DivElement gameScreen = querySelector('#GameScreen');


class Street {    
  String label;
  Map _data;
  
  int width;
  int height;
  
  //the outer bounds of the street
  int top;
  int bottom;
  int left;
  int right;
  
  Street(String streetName){
     _data = ASSET[streetName].get();
     
// sets the label for the street
     label = _data['label'];
      
     //This class could have a or inherit from a Rectangle
     top = _data['dynamic']['t'];
     bottom = _data['dynamic']['b'];
     left = _data['dynamic']['l'];
     right = _data['dynamic']['r'];
     
     width = (_data['dynamic']['l'].abs() + _data['dynamic']['r'].abs());
     height = (_data['dynamic']['t'].abs());
  }
  
  
 Future <List> load(){
   currentStreet = null; 
   
   
   setSong(_data['music']);
    
   // correction for the middleground issue
   for (Map deco in _data['dynamic']['layers']['middleground']['decos'])
     deco['y'] += height;
   
    List decosToLoad = [];
    
    for (Map layer in _data['dynamic']['layers'].values)
    {
      for (Map deco in layer['decos'])
      {
        if (decosToLoad.contains('http://revdancatt.github.io/CAT422-glitch-location-viewer/img/scenery/' + deco['filename'] + '.png')
            == false)
        decosToLoad.add('http://revdancatt.github.io/CAT422-glitch-location-viewer/img/scenery/' + deco['filename'] + '.png');
      }      
    }
    
    List assetsToLoad = [];
    for (String deco in decosToLoad){
      assetsToLoad.add(new Asset(deco));}
         
    
    Batch decos = new Batch(assetsToLoad);
    decos.load(setStreetLoadBar).then((_)
        {
      
      
    currentStreet = this;
      
      
    /* //// Gradient Canvas //// */
    // TODO, this gradient often appears 'banded' we should do something about that later.
    
    CanvasElement gradientCanvas = new CanvasElement();
    gradientCanvas.id = 'gradient';
    gameScreen.append(gradientCanvas);
    
    gradientCanvas.style.zIndex = (-100).toString();
    gradientCanvas.width = width;
    gradientCanvas.height = height;

    gradientCanvas.style.position = 'absolute';
    gradientCanvas.style.left = '0 px';
    gradientCanvas.style.top =  '0 px'; 
    
    var g = gradientCanvas.context2D.createLinearGradient(0,0,0,height);
    g.addColorStop(0,'#' + _data['gradient']['top']);
    g.addColorStop(1,'#' +  _data['gradient']['bottom']);
    gradientCanvas.context2D.fillStyle = g;
    gradientCanvas.context2D.fillRect(0,0,width,height);
    
    
    /* //// Scenery Canvases //// */
    //For each layer on the street, add its name to a List, and sort by z
    List layersOrdered = [];
    _data['dynamic']['layers'].forEach((p, y) => layersOrdered.add(p.toString()));
    layersOrdered.sort((x,y) => _data['dynamic']['layers'][x]['z'].compareTo(_data['dynamic']['layers'][y]['z']));

    //For each layer on the street . . .
    for (var e = 0; e < _data['dynamic']['layers'].length; e++){
      
      //Create a list of the decorations . . .
      List decos = [];
      List canvasesOrdered = [];
      
      for (Map deco in _data['dynamic']['layers'][layersOrdered[e]]['decos']){
        decos.add(deco);
        }
      
      //Then sort them by z-layer, low to high.
      decos.sort((x, y) => x['z'].compareTo(y['z']));

      //Create a new canvas with the layer's attributes
      int width = _data['dynamic']['layers'][layersOrdered[e]]['w'];
      int height = _data['dynamic']['layers'][layersOrdered[e]]['h'];
      int zIndex = _data['dynamic']['layers'][layersOrdered[e]]['z'];
      String id = _data['dynamic']['layers'][layersOrdered[e]]['name'];
      
      CanvasElement decoCanvas = new CanvasElement()
      ..classes.add('streetcanvas');
      decoCanvas.id = id;
      
      gameScreen.append(decoCanvas);
      decoCanvas.style.zIndex = zIndex.toString();
      decoCanvas.width = width;
      decoCanvas.height = height;
        
      decoCanvas.style.position = 'absolute';
      decoCanvas.style.left = '0 px';
      decoCanvas.style.top =  '0 px';        
      
      //For each decoration in the layer, give its attributes and draw
      
      //TODO: FIX THIS
      //Parallax and such is working, BUT
      //Not all images are drawing at the correct y values.
      //It seems this int.y makes foreground and background work, but not middleground???
      for (Map deco in decos){
            
          int x = deco['x'] + width~/(gameScreen.clientWidth);
          int y = deco['y'] - deco['h'] + _data['dynamic']['ground_y'];
          int w = deco['w'];
          int h = deco['h'];
          int z = deco['z'];

          decoCanvas.context2D.imageSmoothingEnabled = false;
          if (ASSET[deco['filename']] != null)
          decoCanvas.context2D.drawImageScaled(ASSET[deco['filename']].get(), x, y, w, h);
          }
        }

    //CurrentStreet = this;

    document.body.children.add(gameCanvas);
    
    gameScreen.append(gameCanvas);
    
    gameCanvas.style.zIndex = ('0');
    //gameCanvas.width = CurrentStreet.width;
    //gameCanvas.height = CurrentStreet.height;
    
    gameCanvas.style.position = 'absolute';
    gameCanvas.style.left = '0 px';
    gameCanvas.style.top =  '0 px';  


        });
  }  
   
 
  //Parallaxing: Adjust the position of each canvas in #GameScreen
  //based on the camera position and relative size of canvas to Street
  render(){
    
    num currentPercentX = camera.x / (width - gameScreen.clientWidth);
    num currentPercentY = camera.y / (height - gameScreen.clientHeight);

    //modify left and top for parallaxing
    for (CanvasElement temp in gameScreen.querySelectorAll('canvas')){
      
      //Don't need to worry about gradientCanvas x changes
      if (temp.id == 'gradient'){
      temp.style.top =  ((temp.height - gameScreen.clientHeight) * -currentPercentY).toString() + 'px';
      }
      
      else{
      double offSetX = (temp.width - gameScreen.clientWidth) * -currentPercentX;
      double offSetY = (temp.height - gameScreen.clientHeight) * -currentPercentY;

      temp.style.position = 'absolute';
      temp.style.left = (offSetX.toString()) + 'px';
      temp.style.top =  (offSetY.toString()) + 'px';
      }
    }
   }

  }

  
setStreetLoadBar(int percent){
  querySelector('#StreetLoadingStatus').text = 'loading decos...';
  querySelector('#MapLoadingBar').style.width = (percent + 1).toString() + '%';
  if (percent >= 99){
    querySelector('#StreetLoadingStatus').text = '...done';
    querySelector('#MapLoadingScreen').style.opacity = '0.0';
  }
}
