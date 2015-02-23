part of couclient;

Camera camera = new Camera();
class Camera
{
  int _x = 0;
  int _y = 0;
  int zoom = 0; // for future eyeballery
  bool dirty = true;
  Rectangle visibleRect;

  void setCameraPosition(int newX, int newY)
  {
	  if(newX != _x || newY != _y)
		  dirty = true;
	  _x = newX;
	  _y = newY;
	  visibleRect = new Rectangle(_x,_y,view.worldElement.clientWidth ,view.worldElement.clientHeight);
  }

  int getX() => _x;
  int getY() => _y;
}