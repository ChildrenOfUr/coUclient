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




class Street {
  String ID;
  
  String label;
  
  int width;
  int height;
  String gradientTop;
  String gradientBottom;
  
  Point origin;
  
  List scenery = new List();
  
  Street(this.ID){
        
        String json = resourceManager.getTextFile(ID);
      
        Map data = JSON.decode(json);
        
        // sets the label for the street
        label = data['label'];
        
        // pulls the gradient from our json
        gradientTop = '#' + data['gradient']['top'];
        gradientBottom = '#' +  data['gradient']['bottom'];
        
        width = (data['dynamic']['l'].abs() + data['dynamic']['r'].abs());
        height = (data['dynamic']['t'].abs());
  
        Point origin = new Point(data['dynamic']['l'].abs(),data['dynamic']['t'].abs());
        
        for (Map deco in data['dynamic']['layers']['middleground']['decos'])
        {
          
          
          
          int x = deco['x'];
          int y = deco['y'];
          int w = deco['w'];
          int h = deco['h'];

          
          
        } 
  
  
  
  }
    
  load(){
    // Sets the size of our canvases.
    gradientCanvas.style.width = width.toString() + 'px';
    gradientCanvas.style.height = height.toString() + 'px';
    
    skyCanvas.style.width = width.toString() + 'px';
    skyCanvas.style.height = height.toString() + 'px';
    
    bg2Canvas.style.width = width.toString() + 'px';
    bg2Canvas.style.height = height.toString() + 'px';
    
    bg1Canvas.style.width = width.toString() + 'px';
    bg1Canvas.style.height = height.toString() + 'px';
    
    middleCanvas.style.width = width.toString() + 'px';
    middleCanvas.style.height = height.toString() + 'px';
    
    middleplusCanvas.style.width = width.toString() + 'px';
    middleplusCanvas.style.height = height.toString() + 'px';
    
    
    // sets the gradient background (This never changes, so we only do it once)
    // TODO, we could change this in relation to the time making days actually feel like days. :P
    var g = gradientCanvas.context2D.createLinearGradient(0,0,0,height);
    g.addColorStop(0,gradientTop);
    g.addColorStop(1,gradientBottom);
    gradientCanvas.context2D.fillStyle = g;
    gradientCanvas.context2D.fillRect(0,0,width,height);

    
    
    
    
    
    
  }  
  // stitch together our canvases and render onto our main one.
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