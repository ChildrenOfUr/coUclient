part of couclient;

class WindowManager {
  
  WindowManager() {

    // Close button listener, closes popup windows
    for (Element e in querySelectorAll('.fa-times.close')) e.onClick.listen((MouseEvent m) {
      e.parent.hidden = true;
    });
    
    
    
  }



}
