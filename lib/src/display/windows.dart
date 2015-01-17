part of couclient;

class WindowManager {
  // Declaring all the possible popup windows
  MapWindow map = new MapWindow();
  SettingsWindow settings = new SettingsWindow();
  BugWindow bugs = new BugWindow();
  BagWindow bag = new BagWindow();
  VendorWindow vendor = new VendorWindow();
  MotdWindow motdWindow = new MotdWindow();

  WindowManager() {
    new Service([#vedorWindow], (Message event) {
      vendor(event.content);
    });
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
      openTab(tab.text);
      // show intended tab
      tab.classes.add('active');
    });

    // DRAGGING/////////////////////////////////////////
    // init vars
    int new_x = view.mainElement.client.width ~/ 2 - 550 ~/ 2;
    int new_y = view.mainElement.client.height ~/ 2 - 350 ~/ 2;
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

  openTab(String tabID) {
    Element tabView = window.querySelector('article #${tabID.toLowerCase()}');
    // hide all tabs
    for (Element t in window.querySelectorAll('article .tab-content')) t.hidden = true;
    for (Element t in window.querySelectorAll('article .tab')) t.classes.remove('active');
    tabView.hidden = false;

  }

}
