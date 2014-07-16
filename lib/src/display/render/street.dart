part of streetlib;


final Element _street_canvas = querySelector('#street');
final Element _street_loadbar = querySelector('#newLocation .bar .percent');



Street _street;
class Street {  
  Camera camera;
  factory Street(Map source) {
    // Make our first street, if needed
    if (_street == null)
      _street = new Street._();
    
    // initialize a disposable camera
    _street.camera = new Camera();
   
    
    // Prepare the loading splash
    querySelector('#streetLoading')
      ..style.opacity = '1'
      ..style.transition = 'opacity 0.5s'
      ..hidden = false
      ..querySelector('#location').text = source['label'];
    
    // Gather up all the image assets
    List decos = [];
    for (Map layer in source['dynamic']['layers'].values)
      for (Map deco in layer['decos'])
        decos.add(new Asset('http://childrenofur.com/locodarto/scenery/' + deco['filename'] + '.png'));
    
    // Load the images and remove the loader.
    Batch decoBatch = new Batch(decos);
    decoBatch.load((num percent) => querySelector('#streetLoading .percent').style.width = percent.toString() + '%').then( (_) {
    
    // Color, and position the street
    String gt = source['gradient']['top'];
    String gb = source['gradient']['bottom'];
    _street_canvas.children.clear(); // Remove all the old decos and layers
    _street_canvas.style
      ..position = 'absolute'
      ..top = '0' ..left = '0'
      ..zIndex = '-1'
      ..overflow = 'hidden'
      ..width = (source['dynamic']['r'] + source['dynamic']['l'].abs()).toString() + 'px' // set width
      ..height = (source['dynamic']['b'] + source['dynamic']['t'].abs()).toString() + 'px' // set height
      ..background = '-webkit-linear-gradient(#$gt, #$gb)'
      ..background = '-moz-linear-gradient(#$gt, #$gb)'
      ..background = 'linear-gradient(#$gt, #$gb)'
      ..perspective = '50'
      ..transition = 'top 0.5s, left 0.5s';
    
    
    
    for (String layerName in source['dynamic']['layers'].keys)
      new Layer(layerName, source['dynamic']['layers'][layerName]);
    
    // done loading, hide the splash
    querySelector('#streetLoading').style.opacity = '0';
    new Timer(new Duration(seconds: 1), () => querySelector('#streetLoading').hidden = true);
    });
    
    // exit and return our reusable Street object
    return _street;
  }
  
  update() {
    // Position the screen //TODO check to see if we need to first.
    _street_canvas.style.left = (_street_canvas.clientLeft.abs() - camera.x*camera.zoom).toString() + 'px';
    _street_canvas.style.top = (_street_canvas.clientTop.abs() - camera.y*camera.zoom).toString() + 'px';
    
    // Update the perspective
    int xpos = (int.parse(_street_canvas.style.left.replaceFirst('px', '')) ).abs() 
        + (_street_canvas.parent.clientWidth~/1.2);
    int ypos = (int.parse(_street_canvas.style.top.replaceFirst('px', '')) ).abs() 
        + (_street_canvas.parent.clientHeight);
    _street_canvas.style
      ..perspectiveOrigin = xpos.toString() + 'px ' + ypos.toString() + 'px'
      ..transform = 'scale('+ camera.zoom.toString() + ')';
    window.requestAnimationFrame(update());
  }
  
  Street._(); // Creates the first reusable street;
}

/* TODO
 * Perhaps it would be useful to create a Street.readable constructor to produce non-reusable Street objects.
 * Then we could build in a way to get Json streets out of a Street object.
 */
