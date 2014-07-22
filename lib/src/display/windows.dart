part of couclient;

class WindowManager {

  WindowManager() {

    Rectangle windowSize = new Rectangle(0,0,550,350);
    
    
    // Close button listener, closes popup windows
    for (Element e in querySelectorAll('.fa-times.close')) e.onClick.listen((MouseEvent m) {
      e.parent.hidden = true;
    });

    for (Element w in querySelectorAll('.window header')) {
      
      // init vars
      int new_x = document.documentElement.client.width~/2 - windowSize.width~/2;
      int new_y = document.documentElement.client.height~/2 - windowSize.height~/2;
      w.parent.style
        ..top = '${new_y}px'
        ..left = '${new_x}px';
      
      bool dragging = false;
      
      // mouse down listeners
      w.onMouseDown.listen((_) {
        dragging = true;
      });
      
      // mouse is moving
      document.onMouseMove.listen((MouseEvent m) {
        if (dragging == true) {
          new_x += m.movement.x;
          new_y += m.movement.y;
          
          w.parent.style
            ..top = '${new_y}px'
            ..left = '${new_x}px';
        }
      });
      
      // mouseUp listener
      document.onMouseUp.listen((_){
        dragging = false;
      });
      
      
    }
  }
}
