part of couclient;

class Bool {
	bool value = false;

	Bool([this.value]);

	bool operator ==(other)
	{
		if(other is bool)
			return this.value == other;
		if(other is Bool)
			return this.value == other.value;
		else
			return this == other;
	}

	@override
	int get hashCode => value.hashCode;
}

class InputManager {
	Bool rightKey = new Bool(), leftKey = new Bool(), upKey = new Bool(),
	downKey = new Bool(), jumpKey = new Bool(), actionKey = new Bool();
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
		"ActionBindingAlt": 13,
		"MapBindingPrimary": 77,
		"MapBindingAlt":77,
		"ChatFocusBindingPrimary": 9,
		"ChatFocusBindingAlt": 9
	};
	bool ignoreKeys = false,
	touched = false,
	clickUsed = false;
	StreamSubscription keyPressSub, keyDownSub, menuKeyListener;
	DateTime lastSelect = new DateTime.now();
	Map<String, Map<String, dynamic>> controlCounts = {};

	InputManager() {
		controlCounts = {'leftKey':{'signals':{}, 'keyBool':leftKey},
			'rightKey':{'signals':{}, 'keyBool':rightKey},
			'upKey':{'signals':{}, 'keyBool':upKey},
			'downKey':{'signals':{}, 'keyBool':downKey},
			'jumpKey':{'signals':{}, 'keyBool':jumpKey},
			'actionKey':{'signals':{}, 'keyBool':actionKey}
		};

		setupKeyBindings();

		document.onClick.listen((MouseEvent event) => clickOrTouch(event, null));
		document.onTouchStart.listen((TouchEvent event) => clickOrTouch(null, event));
	}

	activateControl(String control, bool active, String sourceName) {
		Map<String, Map> signalsList = controlCounts[control]['signals'];
		if(active && !signalsList.containsKey(sourceName + '-' + control))
			signalsList[sourceName + '-' + control] = {'sourceName':sourceName, 'active':active};
		else if(!active)
			signalsList.remove(sourceName + '-' + control);

		if(signalsList.length <= 0)
			controlCounts[control]['keyBool'].value = false;
		else
			controlCounts[control]['keyBool'].value = true;
	}

	updateGamepad() {
		//get any gamepads
		List<Gamepad> gamepads = window.navigator.getGamepads();

		for(Gamepad gamepad in gamepads) {
			//the list of gamepads the browser returns can include nulls
			if (gamepad == null)
				continue;

			//don't do anything in certain situations
			if (ignoreKeys || querySelector(".fill") != null) return;

			//interact with the menu
			Element clickMenu = querySelector("#RightClickMenu");
			if (clickMenu != null) {
				Element list = querySelector('#RCActionList');
				//only select a new option once every 300ms
				bool selectAgain = lastSelect.add(new Duration(milliseconds:300)).isBefore(new DateTime.now());
				if (controlCounts['upKey']['keyBool'] == true && selectAgain) {
					selectUp(list, "RCItemSelected");
				}

				if (controlCounts['downKey']['keyBool'] == true && selectAgain) {
					selectDown(list, "RCItemSelected");
				}
				if (
					controlCounts['leftKey']['keyBool'] == true ||
					controlCounts['rightKey']['keyBool'] == true ||
					controlCounts['jumpKey']['keyBool'] == true) {
					stopMenu(clickMenu);
				}
			}

			if (gamepad.axes[0] > .2 || gamepad.axes[2] > .2) {
				activateControl('rightKey', true, 'gamepad');
			} else {
				activateControl('rightKey', false, 'gamepad');
			}

			if (gamepad.axes[0] < -.2 || gamepad.axes[2] < -.2) {
				activateControl('leftKey', true, 'gamepad');
			} else {
				activateControl('leftKey', false, 'gamepad');
			}

			if(gamepad.axes[1] > .2 || gamepad.axes[3] > .2) {
				activateControl('upKey', true, 'gamepad');
			} else {
				activateControl('upKey', false, 'gamepad');
			}

			if(gamepad.axes[1] < -.2 || gamepad.axes[3] < -.2) {
				activateControl('downKey', true, 'gamepad');
			} else {
				activateControl('downKey', false, 'gamepad');
			}

			bool button0 = context['navigator'].callMethod('getGamepads')[gamepad.index]['buttons'][0]['pressed'];
			bool button1 = context['navigator'].callMethod('getGamepads')[gamepad.index]['buttons'][1]['pressed'];

			if(button0)
				activateControl('jumpKey', true, 'gamepad');
			else
				activateControl('jumpKey', false, 'gamepad');

			if(button1) {
				if(controlCounts['actionKey']['keyBool'] == false) {
					activateControl('actionKey', true, 'gamepad');
					doObjectInteraction();
				}
			}
			else
				activateControl('actionKey', false, 'gamepad');
		}
	}

	clickOrTouch(MouseEvent mouseEvent, TouchEvent touchEvent) {
		// TODO: for now mobile touch targets are not included
		//don't handle too many touch events too fast
		if(touched) return;
		touched = true;
		new Timer.periodic(new Duration(milliseconds: 200), (Timer timer) {
			timer.cancel();
			touched = false;
		});
		Element target;

		if(mouseEvent != null) target = mouseEvent.target;
		else target = touchEvent.target;

		activatePresetBindings(String preset) {
			// check which preset movement keys to set & apply them
			switch(preset) {
				case "qwerty":
				// set WASD
					localStorage["LeftBindingPrimary"] = "65.97";
					localStorage["RightBindingPrimary"] = "68.100";
					localStorage["UpBindingPrimary"] = "87.119";
					localStorage["DownBindingPrimary"] = "83.115";
					break;

				case "dvorak":
				// set ,AOE
					localStorage["LeftBindingPrimary"] = "65.97";
					localStorage["RightBindingPrimary"] = "69.101";
					localStorage["UpBindingPrimary"] = "188.44";
					localStorage["DownBindingPrimary"] = "79.111";
					break;
			}
			// reset all other keys
			localStorage["LeftBindingAlt"] = "37";
			localStorage["RightBindingAlt"] = "39";
			localStorage["UpBindingAlt"] = "38";
			localStorage["DownBindingAlt"] = "40";
			localStorage["JumpBindingPrimary"] = localStorage["JumpBindingAlt"] = "32";
			localStorage["ActionBindingPrimary"] = localStorage["ActionBindingAlt"] = "13";
			// update game vars
			setupKeyBindings();
		}

		// listen for clicks on preset buttons and run above function
		var keyboardPresetQwerty = querySelector("#keyboard-preset-qwerty");
		var keyboardPresetDvorak = querySelector("#keyboard-preset-dvorak");
		keyboardPresetQwerty.onMouseUp.first.then((event) => activatePresetBindings("qwerty"));
		keyboardPresetDvorak.onMouseUp.first.then((event) => activatePresetBindings("dvorak"));

		//handle key re-binds
		if(target.classes.contains("KeyBindingOption")) {
			if(!clickUsed) {
				setupKeyBindings();
			}

			target.text = "(press key to change)";

			//we need to use .listen instead of .first.then so that if the user does not press a key
			//we can cancel the listener at a later time
			keyDownSub = document.body.onKeyDown.listen((KeyboardEvent event) {
				keyDownSub.cancel();
				String key = fromKeyCode(event.keyCode);
				int keyCode = event.keyCode;
				if(key == "") { //it was not a special key
					keyPressSub = document.body.onKeyPress.listen((KeyboardEvent event) {
						keyPressSub.cancel();
						KeyEvent keyEvent = new KeyEvent.wrap(event);
						target.text = new String.fromCharCode(keyEvent.charCode).toUpperCase();
						keys[target.id] = keyCode;
						//store keycode and charcode
						localStorage[target.id] = keyCode.toString() + "." + keyEvent.charCode.toString();
					});
				}
				else {
					target.text = key;
					keys[target.id] = event.keyCode;
					localStorage[target.id] = event.keyCode.toString();
				}
			});
		}

		//handle changing streets via exit signs
		if(target.className.contains("ExitLabel")) {
			//make sure loading screen is visible during load
			view.mapLoadingScreen.className = "MapLoadingScreenIn";
			view.mapLoadingScreen.style.opacity = "1.0";
      minimap.containerE.hidden = true;
			playerTeleFrom = target.attributes['from'];
			streetService.requestStreet(target.attributes['tsid']);
		}

		if(target.classes.contains("chatSpawn")) {
			new Chat(target.text);
		}
	}


	setupKeyBindings() {
		//this prevents 2 keys from being set at once
		if(keyPressSub != null) keyPressSub.cancel();
		if(keyDownSub != null) keyDownSub.cancel();

		//set up key bindings
		keys.forEach((String action, int keyCode) {
			List<String> storedValue = null;
			if(localStorage[action] != null) {
				storedValue = localStorage[action].split(".");
				keys[action] = int.parse(storedValue[0]);
			}
			else localStorage[action] = keys[action].toString();

			String key = fromKeyCode(keys[action]);
			if(key == "") {
				if(storedValue != null && storedValue.length > 1) querySelector("#$action").text = new String.fromCharCode(int.parse(storedValue[1])).toUpperCase();
				else querySelector("#$action").text = new String.fromCharCode((keys[action]));
			}
			else querySelector("#$action").text = key;
		});


		CheckboxInputElement graphicsBlur = querySelector("#GraphicsBlur") as CheckboxInputElement;
		graphicsBlur.onChange.listen((_) {
			localStorage["GraphicsBlur"] = graphicsBlur.checked.toString();
		});


		//Handle player input
		//KeyUp and KeyDown are neccesary for preventing weird movement glitches
		document.onKeyDown.listen((KeyboardEvent k) {
			if(menuKeyListener != null) {
				return;
			}

			//check for chat focus stuff before deciding on ignore keys
			if (k.keyCode == keys["ChatFocusBindingPrimary"] || k.keyCode == keys["ChatFocusBindingAlt"]) {
				advanceChatFocus(k);
			}

			if(ignoreKeys || querySelector(".fill") != null) return;

			if((k.keyCode == keys["UpBindingPrimary"] || k.keyCode == keys["UpBindingAlt"])) //up arrow or w
				activateControl('upKey', true, 'keyboard');
			if((k.keyCode == keys["DownBindingPrimary"] || k.keyCode == keys["DownBindingAlt"])) //down arrow or s
				activateControl('downKey', true, 'keyboard');
			if((k.keyCode == keys["LeftBindingPrimary"] || k.keyCode == keys["LeftBindingAlt"])) //left arrow or a
				activateControl('leftKey', true, 'keyboard');
			if((k.keyCode == keys["RightBindingPrimary"] || k.keyCode == keys["RightBindingAlt"])) //right arrow or d
				activateControl('rightKey', true, 'keyboard');
			if((k.keyCode == keys["JumpBindingPrimary"] || k.keyCode == keys["JumpBindingAlt"])) //spacebar
				activateControl('jumpKey', true, 'keyboard');
			if((k.keyCode == keys["ActionBindingPrimary"] || k.keyCode == keys["ActionBindingAlt"])) //enter
				doObjectInteraction();
		});

		document.onKeyUp.listen((KeyboardEvent k) {
			if(ignoreKeys) {
				return;
			}

			if((k.keyCode == keys["UpBindingPrimary"] || k.keyCode == keys["UpBindingAlt"])) //up arrow or w
				activateControl('upKey', false, 'keyboard');
			if((k.keyCode == keys["DownBindingPrimary"] || k.keyCode == keys["DownBindingAlt"])) //down arrow or s
				activateControl('downKey', false, 'keyboard');
			if((k.keyCode == keys["LeftBindingPrimary"] || k.keyCode == keys["LeftBindingAlt"])) //left arrow or a
				activateControl('leftKey', false, 'keyboard');
			if((k.keyCode == keys["RightBindingPrimary"] || k.keyCode == keys["RightBindingAlt"])) //right arrow or d
				activateControl('rightKey', false, 'keyboard');
			if((k.keyCode == keys["JumpBindingPrimary"] || k.keyCode == keys["JumpBindingAlt"])) //spacebar
				activateControl('jumpKey', false, 'keyboard');
			if((k.keyCode == keys["ActionBindingPrimary"] || k.keyCode == keys["ActionBindingAlt"])) //enter
				activateControl('actionKey', false, 'keyboard');
		});

		//listen for right-clicks on entities that we're close to
		document.body.onContextMenu.listen((MouseEvent e) {
			Element element = e.target as Element;
			int groundY = 0, xOffset = 0, yOffset = 0;
			if(element.attributes['ground_y'] != null)
				groundY = int.parse(element.attributes['ground_y']);
			else {
				xOffset = camera.getX();
				yOffset = camera.getY();
			}
			num x = e.offset.x + xOffset;
			num y = e.offset.y - groundY + yOffset;
			List<String> ids = [];
			CurrentPlayer.intersectingObjects.forEach((String id, Rectangle rect) {
				if(x > rect.left && x < rect.right && y > rect.top && y < rect.bottom)
					ids.add(id);
			});

			if(ids.length > 0)
				doObjectInteraction(e, ids);
		});

		//only for mobile version
		Joystick joystick = new Joystick(querySelector('#Joystick'), querySelector('#Knob'), deadzoneInPercent:.2);
		joystick.onMove.listen((_) {
			//don't move during harvesting, etc.
			if(querySelector(".fill") == null) {
				if(joystick.UP) activateControl('upKey', true, 'joystick');
				else activateControl('upKey', false, 'joystick');
				if(joystick.DOWN) activateControl('downKey', true, 'joystick');
				else activateControl('downKey', false, 'joystick');
				if(joystick.LEFT) activateControl('leftKey', true, 'joystick');
				else activateControl('leftKey', false, 'joystick');
				if(joystick.RIGHT) activateControl('rightKey', true, 'joystick');
				else activateControl('rightKey', false, 'joystick');
			}

			Element clickMenu = querySelector("#RightClickMenu");
			if(clickMenu != null) {
				Element list = querySelector('#RCActionList');
				//only select a new option once every 300ms
				bool selectAgain = lastSelect.add(new Duration(milliseconds:300)).isBefore(new DateTime.now());
				if(joystick.UP && selectAgain)
					selectUp(list, "RCItemSelected");
				if(joystick.DOWN && selectAgain)
					selectDown(list, "RCItemSelected");
				if(joystick.LEFT || joystick.RIGHT)
					stopMenu(clickMenu);
			}
		});
		joystick.onRelease.listen((_) {
			activateControl('upKey', false, 'joystick');
			activateControl('downKey', false, 'joystick');
			activateControl('rightKey', false, 'joystick');
			activateControl('leftKey', false, 'joystick');
		});
		document.onTouchStart.listen((TouchEvent event) {
			Element target = event.target;

			if(target.id == "AButton") {
				event.preventDefault(); //to disable long press calling the context menu
				activateControl('jumpKey', true, 'keyboard');
			}

			if(target.id == "BButton") {
				event.preventDefault(); //to disable long press calling the context menu
				doObjectInteraction();
			}
		});
		document.onTouchEnd.listen((TouchEvent event) {
			Element target = event.target;

			if(target.id == "AButton") {
				activateControl('jumpKey', false, 'keyboard');
			}
		});

		document.onClick.listen((MouseEvent event) => clickOrTouch(event, null));
		document.onTouchStart.listen((TouchEvent event) => clickOrTouch(null, event));

		new TouchScroller(querySelector('#inventory'), TouchScroller.HORIZONTAL);
		//end mobile specific stuff
	}

	void doObjectInteraction([MouseEvent e, List<String> ids]) {
		if(querySelector("#RightClickMenu") != null) {
			doAction(querySelector('#RCActionList'), querySelector("#RightClickMenu"), "RCItemSelected");
			return;
		}

		if(CurrentPlayer.intersectingObjects.length > 0 && querySelector('#RightClickMenu') == null && querySelector(".fill") == null) {
			if(CurrentPlayer.intersectingObjects.length == 1)
				CurrentPlayer.intersectingObjects.forEach(
						(String id, Rectangle rect) => entities[id].interact(id));
			else
				createMultiEntityWindow();
		}
	}

	void createMultiEntityWindow() {
		Element oldWindow = querySelector("#InteractionWindow");
		if(oldWindow != null)
			oldWindow.remove();

		document.body.append(InteractionWindow.create());
	}

	// Right-click menu functions
	hideClickMenu(Element window) {
		if(window != null)
			window.remove();
	}

	showClickMenu(MouseEvent Click, String title, String description, List<List> options) {
		hideClickMenu(querySelector('#RightClickMenu'));
		document.body.append(RightClickMenu.create(Click, title, description, options));

		Element clickMenu = querySelector('#RightClickMenu');
		Element list = querySelector('#RCActionList');


		menuKeyListener = document.onKeyDown.listen((KeyboardEvent k) {
			if((k.keyCode == keys["UpBindingPrimary"] || k.keyCode == keys["UpBindingAlt"]) && !ignoreKeys) //up arrow or w and not typing
				selectUp(list, "RCItemSelected");
			if((k.keyCode == keys["DownBindingPrimary"] || k.keyCode == keys["DownBindingAlt"]) && !ignoreKeys) //down arrow or s and not typing
				selectDown(list, "RCItemSelected");
			if((k.keyCode == keys["LeftBindingPrimary"] || k.keyCode == keys["LeftBindingAlt"]) && !ignoreKeys) //left arrow or a and not typing
				stopMenu(clickMenu);
			if((k.keyCode == keys["RightBindingPrimary"] || k.keyCode == keys["RightBindingAlt"]) && !ignoreKeys) //right arrow or d and not typing
				stopMenu(clickMenu);
			if((k.keyCode == keys["JumpBindingPrimary"] || k.keyCode == keys["JumpBindingAlt"]) && !ignoreKeys) //spacebar and not typing
				stopMenu(clickMenu);
			if((k.keyCode == keys["ActionBindingPrimary"] || k.keyCode == keys["ActionBindingAlt"]) && !ignoreKeys) //spacebar and not typing
				doAction(list, clickMenu, "RCItemSelected");
		});


		document.onClick.listen((_) {
			stopMenu(clickMenu);
		});
	}

	void selectUp(Element menu, String className) {
		List<Element> options = menu.children;
		int removed = 0;
		for(int i = 0; i < options.length; i++) {
			if(options[i].classes.remove(className))
				removed = i;
		}
		if(removed == 0)
			options[options.length - 1].classes.add(className);
		else
			options[removed - 1].classes.add(className);

		lastSelect = new DateTime.now();
	}

	void selectDown(Element menu, String className) {
		List<Element> options = menu.children;
		int removed = options.length - 1;
		for(int i = 0; i < options.length; i++) {
			if(options[i].classes.remove(className))
				removed = i;
		}
		if(removed == options.length - 1)
			options[0].classes.add(className);
		else
			options[removed + 1].classes.add(className);

		lastSelect = new DateTime.now();
	}

	void stopMenu(Element window) {
		if(menuKeyListener != null) {
			menuKeyListener.cancel();
			menuKeyListener = null;
		}
		hideClickMenu(window);
	}

	void doAction(Element list, Element window, String className) {
		for(Element element in list.children) {
			if(element.classes.contains(className)) {
				element.click();
				break;
			}
		}
		stopMenu(window);
	}

	String fromKeyCode(int keyCode) {
		String keyPressed = "";
		if(keyCode == 8) keyPressed = "backspace";
		//  backspace
		if(keyCode == 9) keyPressed = "tab";
		//  tab
		if(keyCode == 13) keyPressed = "enter";
		//  enter
		if(keyCode == 16) keyPressed = "shift";
		//  shift
		if(keyCode == 17) keyPressed = "ctrl";
		//  ctrl
		if(keyCode == 18) keyPressed = "alt";
		//  alt
		if(keyCode == 19) keyPressed = "pause/break";
		//  pause/break
		if(keyCode == 20) keyPressed = "caps lock";
		//  caps lock
		if(keyCode == 27) keyPressed = "escape";
		//  escape
		if(keyCode == 32) keyPressed = "space";
		// space;
		if(keyCode == 33) keyPressed = "page up";
		// page up, to avoid displaying alternate character and confusing people
		if(keyCode == 34) keyPressed = "page down";
		// page down
		if(keyCode == 35) keyPressed = "end";
		// end
		if(keyCode == 36) keyPressed = "home";
		// home
		if(keyCode == 37) keyPressed = "left arrow";
		// left arrow
		if(keyCode == 38) keyPressed = "up arrow";
		// up arrow
		if(keyCode == 39) keyPressed = "right arrow";
		// right arrow
		if(keyCode == 40) keyPressed = "down arrow";
		// down arrow
		if(keyCode == 45) keyPressed = "insert";
		// insert
		if(keyCode == 46) keyPressed = "delete";
		// delete
		if(keyCode == 91) keyPressed = "left window";
		// left window
		if(keyCode == 92) keyPressed = "right window";
		// right window
		if(keyCode == 93) keyPressed = "select key";
		// select key
		if(keyCode == 96) keyPressed = "numpad 0";
		// numpad 0
		if(keyCode == 97) keyPressed = "numpad 1";
		// numpad 1
		if(keyCode == 98) keyPressed = "numpad 2";
		// numpad 2
		if(keyCode == 99) keyPressed = "numpad 3";
		// numpad 3
		if(keyCode == 100) keyPressed = "numpad 4";
		// numpad 4
		if(keyCode == 101) keyPressed = "numpad 5";
		// numpad 5
		if(keyCode == 102) keyPressed = "numpad 6";
		// numpad 6
		if(keyCode == 103) keyPressed = "numpad 7";
		// numpad 7
		if(keyCode == 104) keyPressed = "numpad 8";
		// numpad 8
		if(keyCode == 105) keyPressed = "numpad 9";
		// numpad 9
		if(keyCode == 106) keyPressed = "multiply";
		// multiply
		if(keyCode == 107) keyPressed = "add";
		// add
		if(keyCode == 109) keyPressed = "subtract";
		// subtract
		if(keyCode == 110) keyPressed = "decimal point";
		// decimal point
		if(keyCode == 111) keyPressed = "divide";
		// divide
		if(keyCode == 112) keyPressed = "F1";
		// F1
		if(keyCode == 113) keyPressed = "F2";
		// F2
		if(keyCode == 114) keyPressed = "F3";
		// F3
		if(keyCode == 115) keyPressed = "F4";
		// F4
		if(keyCode == 116) keyPressed = "F5";
		// F5
		if(keyCode == 117) keyPressed = "F6";
		// F6
		if(keyCode == 118) keyPressed = "F7";
		// F7
		if(keyCode == 119) keyPressed = "F8";
		// F8
		if(keyCode == 120) keyPressed = "F9";
		// F9
		if(keyCode == 121) keyPressed = "F10";
		// F10
		if(keyCode == 122) keyPressed = "F11";
		// F11
		if(keyCode == 123) keyPressed = "F12";
		// F12
		if(keyCode == 144) keyPressed = "num lock";
		// num lock
		if(keyCode == 145) keyPressed = "scroll lock";
		// scroll lock
		if(keyCode == 225) keyPressed = "alt";
		//right alt

		return keyPressed;
	}

}
