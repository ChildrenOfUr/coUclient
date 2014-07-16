part of streetlib;

Deco _deco = new Deco._();
class Deco {
  // Take a source Map from a layer and generate a new graphic.
  factory  Deco(Map source, Element container) {
    
    int x = source['x'] - source['w']~/2;
        int y = source['y'] - source['h'];

    ImageElement deco = container.append(ASSET[source['filename']].get().clone(true));
    deco.style
      ..position = 'absolute'
      ..width = source['w'].toString() + 'px'
      ..height = source['h'].toString() + 'px'
      ..transform = 'translate3d(0,0,0)' // Push to GPU, saves about 5fps for me.
      ..zIndex = source['z'].toString() + 'px'
      ..left = x.toString() + 'px'
      ..top = y.toString() + 'px';
    
    if (source['h_flip'] != null)
         deco.style.transform += ' scale(-1,1)';
    
    return _deco;
  }
  Deco._(); // Make the first deco object that gets reused.
}