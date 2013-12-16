part of coUclient;

//Major change - for each layer on the street, make a new canvas
//About half done, still need to move canvases and create parallaxing effect

DivElement gameScreen = querySelector('#GameScreen');
CanvasElement gradientCanvas = querySelector('#gradientCanvas');
CanvasElement backgroundCanvas = querySelector('#backgroundCanvas');
CanvasElement middleCanvas = querySelector('#middleCanvas');
CanvasElement foregroundCanvas = querySelector('#foregroundCanvas');
CanvasElement overlayCanvas = querySelector('#overlayCanvas');

Street CurrentStreet;

class Street {
  String ID;
  Map _data;
  
  String label;
  
  int width;
  int height;
  
  //the outer bounds of the street
  int top;
  int bottom;
  int left;
  int right;
  
  String gradientTop;
  String gradientBottom;
  
  Point origin;
  
  List scenery = new List();
  
  CanvasElement TestCanvas;
  
  Street(this.ID){
        if (assets[ID] == null)
       throw('Error: Asset not loaded!');
        else {
      
        _data = assets[ID];
        
        // sets the label for the street
        label = _data['label'];
        
        // pulls the gradient from our json
        gradientTop = '#' + _data['gradient']['top'];
        gradientBottom = '#' +  _data['gradient']['bottom'];
        
        //This class should have a or inherit from Rectangle
        top = _data['dynamic']['t'];
        bottom = _data['dynamic']['b'];
        left = _data['dynamic']['l'];
        right = _data['dynamic']['r'];
        
        width = (_data['dynamic']['l'].abs() + _data['dynamic']['r'].abs());
        height = (_data['dynamic']['t'].abs());
    
        }
  }
    
  load(){
    //Creating canvases outside of this code is impractical
    //Canvases are created here for each layer, because
    //there are a variable number of layers in each lvl,
    //some are empty, and all are different sizes.
    
    // Sets the size of our canvases.
    gradientCanvas.width = width;
    gradientCanvas.height = height;
    
    backgroundCanvas.width = width;
    backgroundCanvas.height = height;
    
    middleCanvas.width = width;
    middleCanvas.height = height;
    
    foregroundCanvas.width = width;
    foregroundCanvas.height = height;
        
    //TODO: make ui class, overlaycanvas size of gamescreen
    /*
    overlayCanvas.width = width;
    overlayCanvas.height = height;
    */
    
    // sets the gradient background (This never changes, so we only do it once)
    // TODO, we could change this in relation to the time making days actually feel like days. :P
    // TODO, this gradient often appears 'banded' we should do something about that later.

    var g = gradientCanvas.context2D.createLinearGradient(0,0,0,height);
    g.addColorStop(0,gradientTop);
    g.addColorStop(1,gradientBottom);
    gradientCanvas.context2D.fillStyle = g;
    gradientCanvas.context2D.fillRect(0,0,width,height);
    
    //TODO: Better variable names

    List layersOrdered = []; 
    List layers = [];
    
    for (var x = 0; x < _data['dynamic']['layers'].length; x++) {
      layersOrdered.add(_data['dynamic']['layers']);
      layersOrdered[x].forEach((p, y) => layers.add(p.toString()));
    }

    for (var e = 0; e < _data['dynamic']['layers'].length; e++){
      
      List decos = [];
      
      for (Map deco in _data['dynamic']['layers'][layers[e]]['decos']){
        decos.add(deco);
        }
      
      decos.sort((x, y) => x['z'].compareTo(y['z']));

      int width = _data['dynamic']['layers'][layers[e]]['w'];
      int height = _data['dynamic']['layers'][layers[e]]['h'];
      int zlayer = _data['dynamic']['layers'][layers[e]]['z'];

      CanvasElement tempCanvas = new CanvasElement();
      document.body.children.add(tempCanvas);

      tempCanvas.style.zIndex = zlayer.toString();
      tempCanvas.width = width;
      tempCanvas.height = height;
        
      tempCanvas.style.position = 'absolute';
      tempCanvas.style.left = '0 px';
      tempCanvas.style.top =  '0 px';        
        
      for (Map deco in decos){
            
          origin = new Point(_data['dynamic']['l'].abs(),_data['dynamic']['t'].abs());
          int x = deco['x'] + origin.x;
          int y = deco['y'] + origin.y -300;
          int w = deco['w'];
          int h = deco['h'];
          int z = deco['z'];
          middleCanvas.context2D.imageSmoothingEnabled = false;
          
          // for now we'll piggyback off of revdancatt's work. :P
          ImageElement source = new ImageElement()
            ..src = 'http://revdancatt.github.io/CAT422-glitch-location-viewer/img/scenery/' + deco['filename'] + '.png'
            ..style.position = 'absolute'
            ..style.left = '-9999999px';
            
            //keeping this in makes the app run weird, will add efficiency back in later
            //document.body.children.add(source);

            if(z>0)
            tempCanvas.context2D.drawImageScaled(source, x, y, w, h);
            
          }
        }
      
    CurrentStreet = this;
    
  }  
  
  // render loop
  //Will need to change
  render(){



    
    //Currently, everything is drawn on these canvases in the load
    //then the canvases move around to match the camera's position
    //may change in future commits
    
    gradientCanvas.style.position = 'absolute';
    gradientCanvas.style.left = (-CurrentCamera.x).toString() + 'px';
    gradientCanvas.style.top =  (-CurrentCamera.y).toString() + 'px';
    
    backgroundCanvas.style.position = 'absolute';
    backgroundCanvas.style.left = (-CurrentCamera.x).toString() + 'px';
    backgroundCanvas.style.top =  (-CurrentCamera.y).toString() + 'px';
    
    
    middleCanvas.style.position = 'absolute';
    middleCanvas.style.left = (-CurrentCamera.x).toString() + 'px';
    middleCanvas.style.top =  (-CurrentCamera.y).toString() + 'px';
    
    foregroundCanvas.style.position = 'absolute';
    foregroundCanvas.style.left = (-CurrentCamera.x).toString() + 'px';
    foregroundCanvas.style.top =  (-CurrentCamera.y).toString() + 'px';

  }  
}

//TODO: change to UI class
resize(){
  Element chatPane = querySelector('#ChatPane');
  Element gameScreen = querySelector('#GameScreen');
  Element gameStage = querySelector('#GameStage');
  
  int width = window.innerWidth - 80 - 40 - chatPane.clientWidth;
  int height = window.innerHeight - 180;
  
  chatPane.style.right;
  chatPane.clientWidth;
  
  gameScreen.style.width = width.toString()+'px';
  gameScreen.style.height = height.toString()+'px';
  
  chatPane.style.height = (height + 50).toString()+'px';
  
  //TODO When the window becomes too small, we should spawn an overlay that tells the user this fact.
  //This should go in UserInterface
}









