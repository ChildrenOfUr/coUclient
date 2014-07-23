part of couclient;

class WindowManager {


  WindowManager() {
    // WINDOW DECLARATION //

    // MAPWINDOW LISTENERS //
    ui.mapButton.onClick.listen((_) {
      openWindow('map');
    });

    // SETTINGS WINDOW LISTENERS //
    ui.settingsButton.onClick.listen((_) {
      openWindow('settings');
    });

    // BUG REPORT LISTENERS
    ui.bugButton.onClick.listen((_) {
      Element w = openWindow('bugs/suggestions');
      TextAreaElement input = w.querySelector('textarea');
      input.value = 'UserAgent:' + window.navigator.userAgent + '\n////////////////////////////////\n';

      // Submits the Bug
      w.querySelector('.button').onClick.listen((_) {
        slack.Message m = new slack.Message()
            ..username = ui.username
            ..text = input.value;
        slack.team = SLACK_TEAM;
        slack.token = SLACK_TOKEN;
        slack.send(m);

        w.hidden = true;
      });
    });

    // INVENTORY WINDOW LISTENERS
    ui.inventorySearch.onClick.listen((_) {
      openWindow('bag');
    });
   
    
    
    
    
    
    // UNIVERSAL WINDOW EVENT LISTENERS //
    Rectangle windowSize = new Rectangle(0, 0, 550, 350);
    // Close button listener, closes popup windows
    for (Element e in querySelectorAll('.fa-times.close')) e.onClick.listen((MouseEvent m) {
      e.parent.hidden = true;
    });

    // Window Drag listener
    for (Element w in querySelectorAll('.window header')) {
      // init vars
      int new_x = document.documentElement.client.width ~/ 2 - windowSize.width ~/ 2;
      int new_y = document.documentElement.client.height ~/ 2 - windowSize.height ~/ 2;
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
      document.onMouseUp.listen((_) {
        dragging = false;
      });
    }
  }
  // Handle window opening and closing
  Element openWindow(String title) {
    for (Element window in querySelectorAll('.window')) {
      window.hidden = true;
    }
    for (Element window in querySelectorAll('.window')) {
      if (window.querySelector('header').text.toLowerCase().trim() == title) {
        window.hidden = false;
        return window;
      }
    }
    return null;
  }
}
