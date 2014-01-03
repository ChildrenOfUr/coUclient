part of coUclient;

Street currentStreet;


// Streets do not operate on an entity-component framework, but their inhabitants do.
class Street {
  World street = new World();
    
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

  Street(String ID){
    if (assets[ID] == null)
      throw('Error: Street Asset not loaded!');
    else {
      // sets the label for the street
      label = assets[ID]['label'];
        
      // pulls the gradient from our json
      gradientTop = '#' + assets[ID]['gradient']['top'];
      gradientBottom = '#' +  assets[ID]['gradient']['bottom'];
        
      //This class could have a or inherit from a Rectangle
      top = assets[ID]['dynamic']['t'];
      bottom = assets[ID]['dynamic']['b'];
      left = assets[ID]['dynamic']['l'];
      right = assets[ID]['dynamic']['r'];
        
      width = (assets[ID]['dynamic']['l'].abs() + assets[ID]['dynamic']['r'].abs());
      height = (assets[ID]['dynamic']['t'].abs());
    }
  }
  
  
  load(){
    currentStreet = this;
    
  }  
}