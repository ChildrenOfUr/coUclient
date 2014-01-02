part of coUclient;

ComponentMapper positionMapper = new ComponentMapper(Position,world);
class Position extends Component {
  num x, y, z;
  Position(this.x, this.y, this.z);
}

class Velocity extends Component{
  num angle, value;
  Velocity(this.angle, this.value);
}

class StaticSprite extends Component{
  ImageElement image; 
  int width, height;
}


class StreetVars extends Component{
  String label;
  int width;
  int height;
  //the outer bounds of the street
  int top;
  int bottom;
  int left;
  int right;
  //the gradient values
  String gradientTop;
  String gradientBottom;
  StreetVars
  (
    this.label,
    this.width,
    this.height,
    this.top,
    this.bottom,
    this.left,
    this.right,
    this.gradientTop,
    this.gradientBottom    
  );
}





// Determines the current focus of the camera,
// if not properly aligned, the CameraFocusSystem will pan to the correct location.
// Eyeballery will give the player the ability to change the x and y.
ComponentMapper cameraPositionMapper = new ComponentMapper(CameraPosition,world);
class CameraPosition extends Component {
  num x, y;
  CameraPosition(this.x, this.y);
}


