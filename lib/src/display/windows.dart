part of couclient;





class WindowManager {
  Map<String, Modal> modals = {};

  WindowManager() {


    // WINDOW COLLECTION //
    for (Element w in querySelectorAll('#windowHolder .window')) {
      Modal newModal = new Modal(w.id);
      modals[w.id] = newModal;
    }

    // MAPWINDOW LISTENERS //
    ui.mapButton.onClick.listen((_) {
      modals['mapWindow'].open();
    });

    // SETTINGS WINDOW LISTENERS //
    ui.settingsButton.onClick.listen((_) {
      modals['settingsWindow'].open();
    });

    ui.settingsTabs.onClick.listen((MouseEvent m) {
      Element tab = m.target as Element;
      Element tabView = querySelector('#settingsWindow article #${tab.text.toLowerCase()}');
      // hide all tabs
      for (Element t in querySelectorAll('#settingsWindow article .tab-content')) t.hidden = true;
      for (Element t in querySelectorAll('#settingsWindow article .tab')) t.classes.remove('active');
      // show intended tab
      tab.classes.add('active');
      tabView.hidden = false;

    });




    // BUG REPORT LISTENERS
    bool listening = false;
    ui.bugButton.onClick.listen((_) {
      modals['bugWindow'].open();
      Element w = modals['bugWindow'].window;
      TextAreaElement input = w.querySelector('textarea');
      ui.bugReportMeta.text = 'UserAgent:' + window.navigator.userAgent + '\n////////////////////////////////\n';

      // Submits the Bug
      // TODO someday this should be serverside. Let's not give our keys to the client unless we have to.
      if (listening == false) {
        listening = true;
        w.querySelector('.button').onClick.listen((_) {
          slack.Message m = new slack.Message()
              ..username = ui.username
              ..text = '${ui.bugReportMeta.text} \n REPORT TYPE:${ui.bugReportType.value} \n ${input.value} \n ${ui.bugReportEmail.value}';
          slack.team = SLACK_TEAM;
          slack.token = SLACK_TOKEN;
          slack.send(m);
          w.hidden = true;
        });
      }
    });

    // INVENTORY WINDOW LISTENERS
    ui.inventorySearch.onClick.listen((_) {
      modals['bagWindow'].open();
    });

  }
}

/// A Dart interface to an html Modal
class Modal {
  Element window;

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

  Modal(String id) {
    // GET 'window' ////////////////////////////////////
    window = querySelector('#$id');

    // CLOSE BUTTON ////////////////////////////////////
    window.querySelector('.fa-times.close').onClick.listen((_) => this.close());

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
