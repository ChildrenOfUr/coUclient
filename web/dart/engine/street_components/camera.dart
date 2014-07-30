part of coUclient;

Camera camera = new Camera(0,400);
class Camera
{
  int _x,_y;
  int zoom = 0; // for future eyeballery
  bool dirty = true;
  Rectangle visibleRect;
  Camera(this._x,this._y)
  {
      COMMANDS.add(['camera','sets the cameras position "camera x,y"',this.setCamera]);
  }
  
    // we're using css transitions for smooth scrolling.
  void setCamera(String xy) //  format 'x,y'
  {
    try
    {
      int newX = int.parse(xy.split(',')[0]);
      int newY = int.parse(xy.split(',')[1]);
      if(newX != _x || newY != _y)
        dirty = true;
      _x = newX;
      _y = newY;
      visibleRect = new Rectangle(_x,_y,ui.gameScreenWidth,ui.gameScreenHeight);
    }
    catch (error)
    {
      printConsole("error: format must be camera [num],[num]: $error");
    }
  }
  
  int getX() => _x;
  int getY() => _y;
}