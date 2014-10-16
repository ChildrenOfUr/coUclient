part of couclient;

class InputManager {
  bool leftKey, rightKey, upKey, downKey, jumpKey, actionKey;
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
    "ActionBindingPrimary": 13,
    "ActionBindingAlt": 13
  };
  bool ignoreKeys = false,
      touched = false,
      clickUsed = false;
  StreamSubscription keyPressSub, keyDownSub, menuKeyListener;
  DateTime lastSelect = new DateTime.now();

  InputManager() {
    leftKey = false;
    rightKey = false;
    upKey = false;
    downKey = false;
    jumpKey = false;
    actionKey = false;

    setupKeyBindings();

    document.onClick.listen((MouseEvent event) => clickOrTouch(event,null));
    document.onTouchStart.listen((TouchEvent event) => clickOrTouch(null,event));

  }

  clickOrTouch(MouseEvent mouseEvent, TouchEvent touchEvent) {
    // TODO: for now mobile touch targets are not included
    //don't handle too many touch events too fast
    if (touched) return;
    touched = true;
    new Timer.periodic(new Duration(milliseconds: 200), (Timer timer) {
      timer.cancel();
      touched = false;
    });
    Element target;

    if (mouseEvent != null) target = mouseEvent.target; else target = touchEvent.target;

    //handle key re-binds
    if (target.classes.contains("KeyBindingOption")) {
      if (!clickUsed) setupKeyBindings();

      target.text = "(press key to change)";

      //we need to use .listen instead of .first.then so that if the user does not press a key
      //we can cancel the listener at a later time
      keyDownSub = document.body.onKeyDown.listen((KeyboardEvent event) {
        keyDownSub.cancel();
        String key = fromKeyCode(event.keyCode);
        int keyCode = event.keyCode;
        if (key == "") //it was not a special key
        {
          keyPressSub = document.body.onKeyPress.listen((KeyboardEvent event) {
            keyPressSub.cancel();
            KeyEvent keyEvent = new KeyEvent.wrap(event);
            target.text = new String.fromCharCode(keyEvent.charCode).toUpperCase();
            keys[target.id] = keyCode;
            //store keycode and charcode
            local[target.id] = keyCode.toString() + "." + keyEvent.charCode.toString();
          });
        } else {
          target.text = key;
          keys[target.id] = event.keyCode;
          local[target.id] = event.keyCode.toString();
        }
      });
    }

    //handle changing streets via exit signs
    if (target.className == "ExitLabel") {
      //make sure loading screen is visible during load
      ui.mapLoadingScreen.className = "MapLoadingScreenIn";
      ui.mapLoadingScreen.style.opacity = "1.0";
      ScriptElement loadStreet = new ScriptElement();
      loadStreet.src = target.attributes['url'];
      playerTeleFrom = target.attributes['from'];
      document.body.append(loadStreet);
    }

    if(target.classes.contains("chatSpawn"))
    {
    	new Chat(target.text);
    }
  }


  setupKeyBindings() {
    //this prevents 2 keys from being set at once
    if (keyPressSub != null) keyPressSub.cancel();
    if (keyDownSub != null) keyDownSub.cancel();

    //set up key bindings
    keys.forEach((String action, int keyCode) {
      List<String> storedValue = null;
      if (local[action] != null) {
        storedValue = local[action].split(".");
        keys[action] = int.parse(storedValue[0]);
      } else local[action] = keys[action].toString();

      String key = fromKeyCode(keys[action]);
      if (key == "") {
        if (storedValue != null && storedValue.length > 1) querySelector("#$action").text = new String.fromCharCode(int.parse(storedValue[1])).toUpperCase(); else querySelector("#$action").text = new String.fromCharCode((keys[action]));
      } else querySelector("#$action").text = key;
    });

    
    CheckboxInputElement graphicsBlur = querySelector("#GraphicsBlur") as CheckboxInputElement;
    graphicsBlur.onChange.listen((_) {
      local["GraphicsBlur"] = graphicsBlur.checked.toString();
    });
    

    //Handle player input
    //KeyUp and KeyDown are neccesary for preventing weird movement glitches
    //keyCode's could be configurable in the future
    document.onKeyDown.listen((KeyboardEvent k) {
      if (ignoreKeys || menuKeyListener != null || querySelector(".fill") != null) return;

      if ((k.keyCode == keys["UpBindingPrimary"] || k.keyCode == keys["UpBindingAlt"])) //up arrow or w
      upKey = true;
      if ((k.keyCode == keys["DownBindingPrimary"] || k.keyCode == keys["DownBindingAlt"])) //down arrow or s
      downKey = true;
      if ((k.keyCode == keys["LeftBindingPrimary"] || k.keyCode == keys["LeftBindingAlt"])) //left arrow or a
      leftKey = true;
      if ((k.keyCode == keys["RightBindingPrimary"] || k.keyCode == keys["RightBindingAlt"])) //right arrow or d
      rightKey = true;
      if ((k.keyCode == keys["JumpBindingPrimary"] || k.keyCode == keys["JumpBindingAlt"])) //spacebar
      jumpKey = true;
      if ((k.keyCode == keys["ActionBindingPrimary"] || k.keyCode == keys["ActionBindingAlt"])) //enter
      {
        doObjectInteraction();
      }
    });

    document.onKeyUp.listen((KeyboardEvent k) {
      if (ignoreKeys) return;

      if ((k.keyCode == keys["UpBindingPrimary"] || k.keyCode == keys["UpBindingAlt"])) //up arrow or w
      upKey = false;
      if ((k.keyCode == keys["DownBindingPrimary"] || k.keyCode == keys["DownBindingAlt"])) //down arrow or s
      downKey = false;
      if ((k.keyCode == keys["LeftBindingPrimary"] || k.keyCode == keys["LeftBindingAlt"])) //left arrow or a
      leftKey = false;
      if ((k.keyCode == keys["RightBindingPrimary"] || k.keyCode == keys["RightBindingAlt"])) //right arrow or d
      rightKey = false;
      if ((k.keyCode == keys["JumpBindingPrimary"] || k.keyCode == keys["JumpBindingAlt"])) //spacebar
      jumpKey = false;
      if ((k.keyCode == keys["ActionBindingPrimary"] || k.keyCode == keys["ActionBindingAlt"])) //enter
      actionKey = false;
    });

//listen for right-clicks on entities that we're close to
		document.body.onContextMenu.listen((MouseEvent e)
		{
			Element element = e.target as Element;
			int groundY = 0, xOffset = 0, yOffset = 0;
			if(element.attributes['ground_y'] != null)
				groundY = int.parse(element.attributes['ground_y']);
			else
			{
				xOffset = camera.getX();
				yOffset = camera.getY();
			}
			num x = e.offset.x+xOffset, y = e.offset.y-groundY+yOffset;
			List<String> ids =[];
			CurrentPlayer.intersectingObjects.forEach((String id, Rectangle rect)
			{
				if(x > rect.left && x < rect.right && y > rect.top && y < rect.bottom)
					ids.add(id);
			});

			if(ids.length > 0)
				doObjectInteraction(e,ids);
		});

  }

  void doObjectInteraction([MouseEvent e, List<String> ids])
  	{
  		if(CurrentPlayer.intersectingObjects.length > 0 && querySelector('#RightClickMenu') == null && querySelector(".fill") == null)
  		{
  			if(CurrentPlayer.intersectingObjects.length == 1)
  				CurrentPlayer.intersectingObjects.forEach(
  						(String id, Rectangle rect) => interactWithObject(id));
  			else
  				createMultiEntityWindow();
  		}
  	}

  	void createMultiEntityWindow()
  	{
  		Element oldWindow = querySelector("#InteractionWindow");
  		if(oldWindow != null)
  			oldWindow.remove();

  		document.body.append(InteractionWindow.create());
  	}

  	void interactWithObject(String id)
  	{
  		Element element = querySelector("#$id");
  		List<List> actions = [];
  		bool allDisabled = true;
  		if(element.attributes['actions'] != null)
  		{
  			List<Map> actionsList = JSON.decode(element.attributes['actions']);
  			actionsList.forEach((Map actionMap)
  			{
  				bool enabled = actionMap['enabled'];
  				if(enabled)
  					allDisabled = false;
  				String error = "";
  				if(actionMap['requires'] != null)
  				{
  					enabled = hasRequirements(actionMap['requires']);
  					error = getRequirementString(actionMap['requires']);
  				}
  				actions.add([capitalizeFirstLetter(actionMap['action'])+"|"+actionMap['actionWord']+"|${actionMap['timeRequired']}|$enabled|$error",element.id,"sendAction ${actionMap['action']} ${element.id}"]);
  			});
  		}
  		if(!allDisabled)
  			showClickMenu(null,element.attributes['type'],"Desc",actions);
  	}

// Right-click menu functions
	hideClickMenu(Element window)
	{
		if(window != null)
			window.remove();
	}

	showClickMenu(MouseEvent Click, String title, String description, List<List> options)
	{
		hideClickMenu(querySelector('#RightClickMenu'));
		document.body.append(RightClickMenu.create(Click,title,description,options));

		Element clickMenu = querySelector('#RightClickMenu');
     Element list = querySelector('#RCActionList');

		menuKeyListener = document.onKeyDown.listen((KeyboardEvent k)
		{
			if((k.keyCode == keys["UpBindingPrimary"] || k.keyCode == keys["UpBindingAlt"]) && !ignoreKeys) //up arrow or w and not typing
				selectUp(list,"RCItemSelected");
			if((k.keyCode == keys["DownBindingPrimary"] || k.keyCode == keys["DownBindingAlt"]) && !ignoreKeys) //down arrow or s and not typing
				selectDown(list,"RCItemSelected");
			if((k.keyCode == keys["LeftBindingPrimary"] || k.keyCode == keys["LeftBindingAlt"]) && !ignoreKeys) //left arrow or a and not typing
				stopMenu(clickMenu);
			if((k.keyCode == keys["RightBindingPrimary"] || k.keyCode == keys["RightBindingAlt"]) && !ignoreKeys) //right arrow or d and not typing
				stopMenu(clickMenu);
			if((k.keyCode == keys["JumpBindingPrimary"] || k.keyCode == keys["JumpBindingAlt"]) && !ignoreKeys) //spacebar and not typing
				stopMenu(clickMenu);
			if((k.keyCode == keys["ActionBindingPrimary"] || k.keyCode == keys["ActionBindingAlt"]) && !ignoreKeys) //spacebar and not typing
				doAction(list,clickMenu,"RCItemSelected");
		});
		document.onClick.listen((_)
		{
			stopMenu(clickMenu);
		});
	}

	void selectUp(Element menu, String className)
	{
		List<Element> options = menu.children;
		int removed = 0;
		for(int i=0; i<options.length; i++)
		{
			if(options[i].classes.remove(className))
				removed = i;
		}
		if(removed == 0)
			options[options.length-1].classes.add(className);
		else
			options[removed-1].classes.add(className);

		lastSelect = new DateTime.now();
	}

	void selectDown(Element menu, String className)
	{
		List<Element> options = menu.children;
		int removed = options.length-1;
		for(int i=0; i<options.length; i++)
		{
			if(options[i].classes.remove(className))
				removed = i;
		}
		if(removed == options.length-1)
			options[0].classes.add(className);
		else
			options[removed+1].classes.add(className);

		lastSelect = new DateTime.now();
	}

	void stopMenu(Element window)
	{
		if(menuKeyListener != null)
		{
			menuKeyListener.cancel();
			menuKeyListener = null;
		}
     hideClickMenu(window);
	}

	void doAction(Element list, Element window, String className)
	{
		for(Element element in list.children)
		{
			if(element.classes.contains(className))
			{
				element.click();
				break;
			}
		}
		stopMenu(window);
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

}
