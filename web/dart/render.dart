part of coUclient;


// This will be what we use to change the view of the street.
Map camera = new Map()
  ..['x'] = 0
  ..['y'] = 0;

// The various canvases.
CanvasElement gradientCanvas = querySelector('#gradientCanvas');
CanvasElement skyCanvas = querySelector('#skyCanvas');
CanvasElement bg2Canvas = querySelector('#bg2Canvas');
CanvasElement bg1Canvas = querySelector('#bg1Canvas');
CanvasElement middleCanvas = querySelector('#middleCanvas');
CanvasElement middleplusCanvas = querySelector('#middleplusCanvas');


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
    
    skyCanvas.width = width;
    skyCanvas.height = height;
    
    bg2Canvas.width = width;
    bg2Canvas.height = height;
    
    bg1Canvas.width = width;
    bg1Canvas.height = height;
    
    middleCanvas.width = width;
    middleCanvas.height = height;
    
    middleplusCanvas.width = width;
    middleplusCanvas.height = height;
    
    
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
      
      middleCanvas.context2D.imageSmoothingEnabled = false;
      
      // for now we'll piggyback off of revdancatt's work. :P
      ImageElement source = new ImageElement()
      ..src = 'http://revdancatt.github.io/CAT422-glitch-location-viewer/img/scenery/' + deco['filename'] + '.png'
      ..style.position = 'absolute'
      ..style.left = '-9999999px';
      
      //document.body.children.add(source);
      
      middleCanvas.context2D.drawImageScaled(source, x, y, w, h);
    } 
    
    

    
    
    
    CurrentStreet = this;
}  
  // render loop
  render(){
    gradientCanvas.style.position = 'absolute';
    gradientCanvas.style.left = (-camera['x']).toString() + 'px';
    gradientCanvas.style.top =  (-camera['y']).toString() + 'px';
    
    skyCanvas.style.position = 'absolute';
    skyCanvas.style.left = (-camera['x']).toString() + 'px';
    skyCanvas.style.top =  (-camera['y']).toString() + 'px';
    
    
    bg2Canvas.style.position = 'absolute';
    bg2Canvas.style.left = (-camera['x']).toString() + 'px';
    bg2Canvas.style.top =  (-camera['y']).toString() + 'px';
    
    
    bg1Canvas.style.position = 'absolute';
    bg1Canvas.style.left = (-camera['x']).toString() + 'px';
    bg1Canvas.style.top =  (-camera['y']).toString() + 'px';
    
    
    middleCanvas.style.position = 'absolute';
    middleCanvas.style.left = (-camera['x']).toString() + 'px';
    middleCanvas.style.top =  (-camera['y']).toString() + 'px';
    
    
    middleplusCanvas.style.position = 'absolute';
    middleplusCanvas.style.left = (-camera['x']).toString() + 'px';
    middleplusCanvas.style.top =  (-camera['y']).toString() + 'px';
    

    
    
    
  }  
}


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
}









