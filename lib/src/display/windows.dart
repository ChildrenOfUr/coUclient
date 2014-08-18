part of couclient;





class WindowManager extends Pump{
  WindowManager() {

    new MapWindow();
    new SettingsWindow();
    new BugWindow();
    new BagWindow();
    new VendorWindow();
    
    EVENT_BUS > this;
  }

  @override
  process(Moment event) {
    
  }  
}

/// A Dart interface to an html Modal
abstract class Modal {
  Element window;
  String id;
  open() {
    window.hidden = false;
    this.focus();
  }
  close() {
    window.hidden = true;
  }
  focus() {
    for (Element others in querySelectorAll('.window')) {
      others.style.zIndex = '2';
    }
    this.window.style.zIndex = '3';
    window.focus();
  }

  prepare() {
    // GET 'window' ////////////////////////////////////
    window = querySelector('#$id');

    // CLOSE BUTTON ////////////////////////////////////
    window.querySelector('.fa-times.close').onClick.listen((_) => this.close());

    
    // TABS ////////////////////////////////////////////
    window.querySelectorAll('.tab').onClick.listen((MouseEvent m) {
      Element tab = m.target as Element;
      Element tabView = window.querySelector('article #${tab.text.toLowerCase()}');
      // hide all tabs
      for (Element t in window.querySelectorAll('article .tab-content')) t.hidden = true;
      for (Element t in window.querySelectorAll('article .tab')) t.classes.remove('active');
      // show intended tab
      tab.classes.add('active');
      tabView.hidden = false;
    });
    // DRAGGING/////////////////////////////////////////
    // init vars
    int new_x = ui.mainElement.client.width ~/ 2 - 550 ~/ 2;
    int new_y = ui.mainElement.client.height ~/ 2 - 350 ~/ 2;
    window.style
        ..top = '${new_y}px'
        ..left = '${new_x}px';
    bool dragging = false;

    // mouse down listeners
    window.onMouseDown.listen((_) => this.focus());

    window.querySelector('header').onMouseDown.listen((_) {
      dragging = true;
    });
    // mouse is moving
    document.onMouseMove.listen((MouseEvent m) {
      if (dragging == true) {
        new_x += m.movement.x;
        new_y += m.movement.y;
        window.style
            ..top = '${new_y}px'
            ..left = '${new_x}px';
      }
    });
    // mouseUp listener
    document.onMouseUp.listen((_) {
      dragging = false;
    });
  }

  

}
