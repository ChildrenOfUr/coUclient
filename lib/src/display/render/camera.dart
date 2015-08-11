part of couclient;

Camera camera = new Camera();

class Camera {
  int _x = 0, _y = 0, zoom = 0;

  // for future eyeballery
  bool dirty = true;
  MutableRectangle visibleRect;

  void setCameraPosition(int newX, int newY) {
    if (newX != _x || newY != _y)
      dirty = true;
    _x = newX;
    _y = newY;

    if (visibleRect == null) {
      visibleRect = new MutableRectangle(_x, _y, view.worldElementWidth, view.worldElementHeight);
    }
    else {
      visibleRect.left = _x;
      visibleRect.top = _y;
      visibleRect.width = view.worldElementWidth;
      visibleRect.height = view.worldElementHeight;
    }
  }

  int getX() => _x;

  int getY() => _y;
}