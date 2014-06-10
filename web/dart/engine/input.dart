part of couclient;



Input input = new Input();
class Input {
  bool leftKey, rightKey, upKey, downKey, jumpKey;
  Map<String, int> keys = {
    "LeftBindingPrimary": 65,
    "LeftBindingAlt": 37,
    "RightBindingPrimary": 68,
    "RightBindingAlt": 39,
    "UpBindingPrimary": 87,
    "UpBindingAlt": 38,
    "DownBindingPrimary": 83,
    "DownBindingAlt": 40,
    "JumpBindingPrimary": 32,
    "JumpBindingAlt": 32,
  };
  bool ignoreKeys = false,
      touched = false,
      clickUsed = false;
  StreamSubscription keyPressSub, keyDownSub;

  Input() {
    leftKey = false;
    rightKey = false;
    upKey = false;
    downKey = false;
    jumpKey = false;
  }

  //Starts listening to user input.
  init() {
    setupKeyBindings();

    //handle chat input getting focused/unfocused so that the character doesn't move while typing
    ElementList chatInputs = querySelectorAll('textarea');
    chatInputs.onFocus.listen((_) {
      ignoreKeys = true;
    });
    chatInputs.onBlur.listen((_) {
      ignoreKeys = false;
    });

    //Handle player input
    //KeyUp and KeyDown are neccesary for preventing weird movement glitches
    //keyCode's could be configurable in the future
    document.onKeyDown.listen((KeyboardEvent k) {
      if ((k.keyCode == keys["UpBindingPrimary"] || k.keyCode == keys["UpBindingAlt"]) && !ignoreKeys) //up arrow or w and not typing
      upKey = true;
      if ((k.keyCode == keys["DownBindingPrimary"] || k.keyCode == keys["DownBindingAlt"]) && !ignoreKeys) //down arrow or s and not typing
      downKey = true;
      if ((k.keyCode == keys["LeftBindingPrimary"] || k.keyCode == keys["LeftBindingAlt"]) && !ignoreKeys) //left arrow or a and not typing
      leftKey = true;
      if ((k.keyCode == keys["RightBindingPrimary"] || k.keyCode == keys["RightBindingAlt"]) && !ignoreKeys) //right arrow or d and not typing
      rightKey = true;
      if ((k.keyCode == keys["JumpBindingPrimary"] || k.keyCode == keys["JumpBindingAlt"]) && !ignoreKeys) //spacebar and not typing
      jumpKey = true;
    });

    document.onKeyUp.listen((KeyboardEvent k) {
      if ((k.keyCode == keys["UpBindingPrimary"] || k.keyCode == keys["UpBindingAlt"]) && !ignoreKeys) //up arrow or w and not typing
      upKey = false;
      if ((k.keyCode == keys["DownBindingPrimary"] || k.keyCode == keys["DownBindingAlt"]) && !ignoreKeys) //down arrow or s and not typing
      downKey = false;
      if ((k.keyCode == keys["LeftBindingPrimary"] || k.keyCode == keys["LeftBindingAlt"]) && !ignoreKeys) //left arrow or a and not typing
      leftKey = false;
      if ((k.keyCode == keys["RightBindingPrimary"] || k.keyCode == keys["RightBindingAlt"]) && !ignoreKeys) //right arrow or d and not typing
      rightKey = false;
      if ((k.keyCode == keys["JumpBindingPrimary"] || k.keyCode == keys["JumpBindingAlt"]) && !ignoreKeys) //spacebar and not typing
      jumpKey = false;
    });
  }


  setupKeyBindings() {
    //this prevents 2 keys from being set at once
    if (keyPressSub != null) keyPressSub.cancel();
    if (keyDownSub != null) keyDownSub.cancel();

    //set up key bindings
    keys.forEach((String action, int keyCode) {
      List<String> storedValue = null;
      if (app.local[action] != null) {
        storedValue = app.local[action].split(".");
        keys[action] = int.parse(storedValue[0]);
      } else app.local[action] = keys[action].toString();

      String key = fromKeyCode(keys[action]);
      if (key == "") {
        if (storedValue != null && storedValue.length > 1) querySelector("#$action").text = new String.fromCharCode(int.parse(storedValue[1])).toUpperCase(); else querySelector("#$action").text = new String.fromCharCode((keys[action]));
      } else querySelector("#$action").text = key;
    });
  }
}





String fromKeyCode(int keyCode) {
  String keyPressed = "";
  if (keyCode == 8) keyPressed = "backspace"; //  backspace
  if (keyCode == 9) keyPressed = "tab"; //  tab
  if (keyCode == 13) keyPressed = "enter"; //  enter
  if (keyCode == 16) keyPressed = "shift"; //  shift
  if (keyCode == 17) keyPressed = "ctrl"; //  ctrl
  if (keyCode == 18) keyPressed = "alt"; //  alt
  if (keyCode == 19) keyPressed = "pause/break"; //  pause/break
  if (keyCode == 20) keyPressed = "caps lock"; //  caps lock
  if (keyCode == 27) keyPressed = "escape"; //  escape
  if (keyCode == 32) keyPressed = "space"; // space;
  if (keyCode == 33) keyPressed = "page up"; // page up, to avoid displaying alternate character and confusing people
  if (keyCode == 34) keyPressed = "page down"; // page down
  if (keyCode == 35) keyPressed = "end"; // end
  if (keyCode == 36) keyPressed = "home"; // home
  if (keyCode == 37) keyPressed = "left arrow"; // left arrow
  if (keyCode == 38) keyPressed = "up arrow"; // up arrow
  if (keyCode == 39) keyPressed = "right arrow"; // right arrow
  if (keyCode == 40) keyPressed = "down arrow"; // down arrow
  if (keyCode == 45) keyPressed = "insert"; // insert
  if (keyCode == 46) keyPressed = "delete"; // delete
  if (keyCode == 91) keyPressed = "left window"; // left window
  if (keyCode == 92) keyPressed = "right window"; // right window
  if (keyCode == 93) keyPressed = "select key"; // select key
  if (keyCode == 96) keyPressed = "numpad 0"; // numpad 0
  if (keyCode == 97) keyPressed = "numpad 1"; // numpad 1
  if (keyCode == 98) keyPressed = "numpad 2"; // numpad 2
  if (keyCode == 99) keyPressed = "numpad 3"; // numpad 3
  if (keyCode == 100) keyPressed = "numpad 4"; // numpad 4
  if (keyCode == 101) keyPressed = "numpad 5"; // numpad 5
  if (keyCode == 102) keyPressed = "numpad 6"; // numpad 6
  if (keyCode == 103) keyPressed = "numpad 7"; // numpad 7
  if (keyCode == 104) keyPressed = "numpad 8"; // numpad 8
  if (keyCode == 105) keyPressed = "numpad 9"; // numpad 9
  if (keyCode == 106) keyPressed = "multiply"; // multiply
  if (keyCode == 107) keyPressed = "add"; // add
  if (keyCode == 109) keyPressed = "subtract"; // subtract
  if (keyCode == 110) keyPressed = "decimal point"; // decimal point
  if (keyCode == 111) keyPressed = "divide"; // divide
  if (keyCode == 112) keyPressed = "F1"; // F1
  if (keyCode == 113) keyPressed = "F2"; // F2
  if (keyCode == 114) keyPressed = "F3"; // F3
  if (keyCode == 115) keyPressed = "F4"; // F4
  if (keyCode == 116) keyPressed = "F5"; // F5
  if (keyCode == 117) keyPressed = "F6"; // F6
  if (keyCode == 118) keyPressed = "F7"; // F7
  if (keyCode == 119) keyPressed = "F8"; // F8
  if (keyCode == 120) keyPressed = "F9"; // F9
  if (keyCode == 121) keyPressed = "F10"; // F10
  if (keyCode == 122) keyPressed = "F11"; // F11
  if (keyCode == 123) keyPressed = "F12"; // F12
  if (keyCode == 144) keyPressed = "num lock"; // num lock
  if (keyCode == 145) keyPressed = "scroll lock"; // scroll lock
  if (keyCode == 225) keyPressed = "alt"; //right alt

  return keyPressed;
}



