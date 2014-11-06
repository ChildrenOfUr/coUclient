part of couclient;

Camera camera = new Camera(0,0);
class Camera
{
  int _x,_y;
  int zoom = 0; // for future eyeballery
  bool dirty = true;
  Rectangle visibleRect;
  Camera(this._x,this._y)
  {
      COMMANDS['camera'] = setCamera;
  }
  
    // we're using css transitions for smooth scrolling.
  void setCamera(String xy) //  format 'x,y'
  {
    try
    {
      int newX = int.parse(xy.split(',')[0]);
      int newY = int.parse(xy.split(',')[1]);
      setCameraPosition(newX,newY);
    }
    catch (error)
    {
      //printConsole("error: format must be camera [num],[num]: $error");
    }
  }
  
  void setCameraPosition(int newX, int newY)
  {
	  if(newX != _x || newY != _y)
		  dirty = true;
	  _x = newX;
	  _y = newY;
	  visibleRect = new Rectangle(_x,_y,view.worldWidth,view.worldHeight);
  }
  
  int getX() => _x;
  int getY() => _y;
}