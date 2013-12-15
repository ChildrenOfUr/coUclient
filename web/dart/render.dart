part of coUclient;

//The various canvases. These have been changed to fit new display model
//Check notes on Google Drive for explanations if needed
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
  String gradientTop;
  String gradientBottom;
  
  Point origin;
  
  List scenery = new List();
  
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
        
        width = (_data['dynamic']['l'].abs() + _data['dynamic']['r'].abs());
        height = (_data['dynamic']['t'].abs());
        }
  }
    
  load(){
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

  
  
    // draws the middleground decorations
    for (Map deco in _data['dynamic']['layers']['middleground']['decos'])
    {
      origin = new Point(_data['dynamic']['l'].abs(),_data['dynamic']['t'].abs());
      int x = deco['x'] + origin.x;
      int y = deco['y'] + origin.y;
      int w = deco['w'];
      int h = deco['h'];
      int z = deco['z'];
      middleCanvas.context2D.imageSmoothingEnabled = false;
      
      // for now we'll piggyback off of revdancatt's work. :P
      ImageElement source = new ImageElement()
      ..src = 'http://revdancatt.github.io/CAT422-glitch-location-viewer/img/scenery/' + deco['filename'] + '.png'
      ..style.position = 'absolute'
      ..style.left = '-9999999px';
      
      document.body.children.add(source);
      
      if(z>0)
      backgroundCanvas.context2D.drawImageScaled(source, x, y, w, h);
      if(z==0)
      middleCanvas.context2D.drawImageScaled(source, x, y, w, h);
      if (z<0)
      foregroundCanvas.context2D.drawImageScaled(source, x, y, w, h);
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









