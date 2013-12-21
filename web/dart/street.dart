part of coUclient;

//Major change - for each layer on the street, make a new canvas

//All environmental layers are created in load()
//gradientCanvas only contains the street's gradient and only repositions with camera.y changes
//decorative canvases are created for each layer (bg_1, bg_2, etc.)
//These are added to #GameScreen, and repositioned in render

//Separately, gameCanvas contains all moving elements, because the canvas must be cleared periodically
//It is instatiated in main.dart, its values specified in init()


//If we wanted to, we could create the #GameScreen in dart
DivElement gameScreen = querySelector('#GameScreen');
int gameScreenWidth;
int gameScreenHeight;

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
  
  double currentPercentX; 
  double currentPercentY;
  
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
        
      //This class could have a or inherit from a Rectangle
      top = _data['dynamic']['t'];
      bottom = _data['dynamic']['b'];
      left = _data['dynamic']['l'];
      right = _data['dynamic']['r'];
        
      width = (_data['dynamic']['l'].abs() + _data['dynamic']['r'].abs());
      height = (_data['dynamic']['t'].abs());
    }
  }
    
  load(){

    //Canvases are created here for each layer, because
    //there are a variable number of layers in each lvl,
    //some are empty, and all are different sizes.
        
    //TODO: make ui class, overlaycanvas; dynamic in size
    /*
    overlayCanvas.width = width;
    overlayCanvas.height = height;
    */
    
    /* //// Gradient Canvas //// */

    // TODO, we could change this in relation to the time making days actually feel like days. :P
    // CB - +1 this idea ^ (but maybe hold off on new features until old features all work)
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
    g.addColorStop(0,gradientTop);
    g.addColorStop(1,gradientBottom);
    gradientCanvas.context2D.fillStyle = g;
    gradientCanvas.context2D.fillRect(0,0,width,height);
    
    /* //// Scenery Canvases //// */
    
    //For each layer on the street, add its name to a List, and sort by z
    List layersOrdered = [];
    _data['dynamic']['layers'].forEach((p, y) => layersOrdered.add(p.toString()));
    layersOrdered.sort((x,y) => _data['dynamic']['layers'][x]['z'].compareTo(_data['dynamic']['layers'][y]['z']));

    //For each layer on the street . . .
    for (var e = 0; e < 6; e++){
      
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
      
      CanvasElement decoCanvas = new CanvasElement();
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
            
          int x = deco['x'] + width~/(gameScreenWidth) ;
          int y = deco['y'] - deco['h'] + _data['dynamic']['ground_y'];
          int w = deco['w'];
          int h = deco['h'];
          int z = deco['z'];

          decoCanvas.context2D.imageSmoothingEnabled = false;
          
          ImageElement source = new ImageElement()
            ..src = 'http://revdancatt.github.io/CAT422-glitch-location-viewer/img/scenery/' + deco['filename'] + '.png'
            ..style.position = 'absolute'
            ..style.left = '-9999999px'
            ..style.zIndex = z.toString();
            
            //keeping this in makes the app run weird, will add efficiency back in later
            //document.body.children.add(source);

          decoCanvas.context2D.drawImageScaled(source, x, y, w, h);
          }
        }
    CurrentStreet = this;
  }  
  
  //Parallaxing: Adjust the position of each canvas in #GameScreen
  //based on the camera position and relative size of canvas to Street
  render(){
    
    currentPercentX = CurrentCamera.x / (width - gameScreenWidth);
    currentPercentY = CurrentCamera.y / (height - gameScreenHeight);

    //modify left and top for parallaxing
    for (CanvasElement temp in gameScreen.children){
      
      //Don't need to worry about gradientCanvas x changes
      if (temp.id == 'gradient'){
      temp.style.top =  ((temp.height - gameScreenHeight) * -currentPercentY).toString() + 'px';
      }
      
      else{
      double offSetX = (temp.width - gameScreenWidth) * -currentPercentX;
      double offSetY = (temp.height - gameScreenHeight) * -currentPercentY;

      temp.style.position = 'absolute';
      temp.style.left = (offSetX.toString()) + 'px';
      temp.style.top =  (offSetY.toString()) + 'px';
      }
    }
  }  
}