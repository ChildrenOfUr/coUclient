part of couclient;

class WindowManager {
  WindowManager() {
    // Declaring all the possible popup windows
    SettingsWindow settings = new SettingsWindow();
    mapWindow = new MapWindow();
    BugWindow bugs = new BugWindow();
    BagWindow bag = new BagWindow();
    VendorWindow vendor = new VendorWindow();
    MotdWindow motdWindow = new MotdWindow();
    //GoWindow goWindow = new GoWindow();
    CalendarWindow calendarWindow = new CalendarWindow();
    RockWindow rockWindow = new RockWindow();
//		ItemWindow itemWindow = new ItemWindow();
    EmoticonPicker emoticonPicker = new EmoticonPicker();
  }
}

class AuctionWindow extends Modal {
  String id = 'auctionWindow';

  AuctionWindow() {
    prepare();
  }
}

class MailboxWindow extends Modal {
  String id = 'mailboxWindow';

  MailboxWindow() {
    prepare();
  }

  open() {
    (querySelector("ur-mailbox") as Mailbox).refresh();
    inputManager.ignoreKeys = true;
    super.open();
  }

  close() {
    inputManager.ignoreKeys = false;
    super.close();
  }
}

Map<String, Modal> modals = {};

/// A Dart interface to an html Modal
abstract class Modal extends InformationDisplay {
  String id;
  StreamSubscription escListener;

  open() {
    displayElement.hidden = false;
    elementOpen = true;
    this.focus();
  }

  close() {
    _destroyEscListener();
    displayElement.hidden = true;
    elementOpen = false;

    //see if there's another window that we want to focus
    for (Element modal in querySelectorAll('.window')) {
      if (!modal.hidden) {
        modals[modal.id].focus();
      }
    }
  }

  focus() {
    for (Element others in querySelectorAll('.window')) {
      others.style.zIndex = '2';
    }
    this.displayElement.style.zIndex = '3';
    displayElement.focus();
  }

  _createEscListener() {
    if (escListener != null) {
      return;
    }

    escListener = document.onKeyUp.listen((KeyboardEvent e) {
      //27 == esc key
      if (e.keyCode == 27) {
        close();
      }
    });
  }

  _destroyEscListener() {
    if (escListener != null) {
      escListener.cancel();
      escListener = null;
    }
  }

  prepare() {
    // GET 'window' ////////////////////////////////////
    displayElement = querySelector('#$id');

    // CLOSE BUTTON ////////////////////////////////////
    displayElement.querySelector('.fa-times.close').onClick.listen((_) => this.close());

    // PREVENT PLAYER MOVEMENT WHILE WINDOW IS FOCUSED /
    displayElement.querySelectorAll('input, textarea').onFocus.listen((_) {
      inputManager.ignoreKeys = true;
      inputManager.ignoreChatFocus = true;
    });
    displayElement.querySelectorAll('input, textarea').onBlur.listen((_) {
      inputManager.ignoreKeys = false;
      inputManager.ignoreChatFocus = false;
    });

    //make div focusable. see: http://stackoverflow.com/questions/11280379/is-it-possible-to-write-onfocus-lostfocus-handler-for-a-div-using-js-or-jquery
    displayElement.tabIndex = -1;

    displayElement.onFocus.listen((_) => _createEscListener());
    displayElement.onBlur.listen((_) => _destroyEscListener());

    // TABS ////////////////////////////////////////////
    displayElement.querySelectorAll('.tab').onClick.listen((MouseEvent m) {
      Element tab = m.target as Element;
      openTab(tab.text);
      // show intended tab
      tab.classes.add('active');
    });

    // DRAGGING ////////////////////////////////////////
    // init vars
    if (displayElement.querySelector('header') != null) {
      int new_x = 0, new_y = 0;
      bool dragging = false;

      // mouse down listeners
      displayElement.onMouseDown.listen((_) => this.focus());
      displayElement.querySelector('header').onMouseDown.listen((_) => dragging = true);

      // mouse is moving
      document.onMouseMove.listen((MouseEvent m) {
        if (dragging == true) {
          new_x += m.movement.x;
          new_y += m.movement.y;
          displayElement.style
            ..top = 'calc(50% + ${new_y}px)'
            ..left = 'calc(50% + ${new_x}px)';
        }
      });

      // mouseUp listener
      document.onMouseUp.listen((_) => dragging = false);

      modals[id] = this;
    }
  }

  openTab(String tabID) {
    Element tabView = displayElement.querySelector('article #${tabID.toLowerCase()}');
    // hide all tabs
    for (Element t in displayElement.querySelectorAll('article .tab-content'))
      t.hidden = true;
    for (Element t in displayElement.querySelectorAll('article .tab'))
      t.classes.remove('active');
    tabView.hidden = false;
  }
}
