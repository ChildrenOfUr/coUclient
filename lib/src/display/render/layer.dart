part of streetlib;


Layer _layer = new Layer._();
class Layer {
  factory Layer(String name, Map source) {
    Element layerElement = _street_canvas.append(new DivElement());
    int w = source['w'];
    int h = source['h'];
    int z = source['z'];
    layerElement.style
      ..position = 'absolute'
      ..top = '0' ..left = '0'      
      ..width = '$w' + 'px'
      ..height = '$h' + 'px'
      ..zIndex = (source['z']-100).toString()
      ..transform = 'translateZ(${z}' + 'px)'; // for parallax
    
    if (name == 'middleground') {
      layerElement.style
        ..top = source['h'].toString() + 'px' 
        ..left = (source['w']~/2).toString() + 'px';
    }
    
    applyFilters(layerElement, source['filters']);      
    for (Map deco in source['decos'])
       new Deco(deco, layerElement);
    return _layer;
  }
  Layer._(); // Make the first Layer object that gets reused.
}