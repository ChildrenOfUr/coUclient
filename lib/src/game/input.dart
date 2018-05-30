part of couclient;

/// Needed for passing objects by reference
class Bool {
	bool value = false;

	Bool([this.value]);

	bool operator ==(other) {
		if (other is bool) {
			return this.value == other;
		} else if (other is Bool) {
			return this.value == other.value;
		} else {
			return this == other;
		}
	}

	@override
	int get hashCode => value.hashCode;
}

class InputManager {
	bool windowFocused = true;
	Bool rightKey = new Bool(false);
	Bool leftKey = new Bool(false);
	Bool upKey = new Bool(false);
	Bool downKey = new Bool(false);
	Bool jumpKey = new Bool(false);
	Bool actionKey = new Bool(false);

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
		"ActionBindingAlt": 69,
		"MapBindingPrimary": 77,
		"MapBindingAlt": 77,
		"CalendarBindingPrimary": 67,
		"CalendarBindingAlt": 67,
		"SettingsBindingPrimary": 80,
		"SettingsBindingAlt": 80,
		"ChatFocusBindingPrimary": 9,
		"ChatFocusBindingAlt": 9,
		"ImgMenuBindingPrimary": 73,
		"ImgMenuBindingAlt": 73,
		"QuestLogBindingPrimary": 81,
		"QuestLogBindingAlt": 81,
		"AchievementsBindingPrimary": 89,
		"AchievementsBindingAlt": 89
	};

	int _ignoreCount = 0;

	bool get ignoreKeys => _ignoreCount != 0;

	void set ignoreKeys(bool value) {
		if (value) {
			_ignoreCount++;
		} else if (--_ignoreCount < 0) {
			_ignoreCount = 0;
		}
	}

	bool ignoreChatFocus = false;
	bool touched = false;
	bool clickUsed = false;
	StreamSubscription keyPressSub;
	StreamSubscription keyDownSub;
	StreamSubscription menuKeyListener;
	DateTime lastSelect = new DateTime.now();
	Map<String, Map<String, dynamic>> controlCounts = {};

	InputManager() {
		controlCounts = {
			'leftKey': {'signals': {}, 'keyBool': leftKey},
			'rightKey': {'signals': {}, 'keyBool': rightKey},
			'upKey': {'signals': {}, 'keyBool': upKey},
			'downKey': {'signals': {}, 'keyBool': downKey},
			'jumpKey': {'signals': {}, 'keyBool': jumpKey},
			'actionKey': {'signals': {}, 'keyBool': actionKey},
		};

		setupKeyBindings();

		new Service(['disableInputKeys'], (bool value) => ignoreKeys = value);
		new Service(['disableChatFocus'], (bool value) => ignoreChatFocus = value);

		document.onClick.listen((MouseEvent event) => clickOrTouch(event, null));
		document.onTouchStart.listen((TouchEvent event) => clickOrTouch(null, event));

		initKonami();

		// Track window focus
		window.onFocus.listen((_) => windowFocused = true);
		window.onBlur.listen((_) => windowFocused = false);
	}

	void activateControl(String control, bool active, String sourceName) {
		Map<String, Map> signalsList = controlCounts[control]['signals'];
		if (active && !signalsList.containsKey(sourceName + '-' + control)) {
			signalsList[sourceName + '-' + control] = {'sourceName': sourceName, 'active': active};
		} else if (!active) {
			signalsList.remove(sourceName + '-' + control);
		}

		if (signalsList.length <= 0) {
			controlCounts[control]['keyBool'].value = false;
		} else {
			controlCounts[control]['keyBool'].value = true;
		}

		//stop following any player that you might be following
		CurrentPlayer.followPlayer();

		new Service(["worldFocus"], (bool focused) {
			if (!focused) {
				controlCounts.forEach((String control, Map data) {
					data["keyBool"].value = false;
				});
			}
		});
	}

	void updateGamepad() {
		//get any gamepads
		List<Gamepad> gamepads = window.navigator.getGamepads();

		for (Gamepad gamepad in gamepads) {
			//the list of gamepads the browser returns can include nulls
			if (gamepad == null) {
				continue;
			}

			//don't do anything in certain situations
			if (ignoreKeys || ActionBubble.occuring) {
				return;
			}

			//interact with the menu
			Element clickMenu = querySelector("#RightClickMenu");
			if (clickMenu != null) {
				Element list = querySelector('#RCActionList');
				//only select a new option once every 300ms
				bool selectAgain = lastSelect.add(new Duration(milliseconds:300)).isBefore(new DateTime.now());
				if (controlCounts['upKey']['keyBool'] == true && selectAgain) {
					selectUp(list.querySelectorAll('.RCItem'), "RCItemSelected");
				}

				if (controlCounts['downKey']['keyBool'] == true && selectAgain) {
					selectDown(list.querySelectorAll('.RCItem'), "RCItemSelected");
				}
				if (controlCounts['leftKey']['keyBool'] == true ||
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

			if (gamepad.axes[1] > .2 || gamepad.axes[3] > .2) {
				activateControl('upKey', true, 'gamepad');
			} else {
				activateControl('upKey', false, 'gamepad');
			}

			if (gamepad.axes[1] < -.2 || gamepad.axes[3] < -.2) {
				activateControl('downKey', true, 'gamepad');
			} else {
				activateControl('downKey', false, 'gamepad');
			}

			bool button0 = context['navigator'].callMethod('getGamepads')[gamepad.index]['buttons'][0]['pressed'];
			bool button1 = context['navigator'].callMethod('getGamepads')[gamepad.index]['buttons'][1]['pressed'];

			if (button0) {
				activateControl('jumpKey', true, 'gamepad');
			} else {
				activateControl('jumpKey', false, 'gamepad');
			}

			if (button1) {
				if (controlCounts['actionKey']['keyBool'] == false) {
					activateControl('actionKey', true, 'gamepad');
					doObjectInteraction();
				}
			} else {
				activateControl('actionKey', false, 'gamepad');
			}
		}
	}

	void clickOrTouch(MouseEvent mouseEvent, TouchEvent touchEvent) {
		// TODO: for now mobile touch targets are not included
		//don't handle too many touch events too fast
		if (touched) {
			return;
		}

		touched = true;
		new Timer.periodic(new Duration(milliseconds: 200), (Timer timer) {
			timer.cancel();
			touched = false;
		});

		Element target = (mouseEvent != null) ? mouseEvent.target : touchEvent.target;

		void activatePresetBindings(String preset) {
			// check which preset movement keys to set & apply them
			switch (preset) {
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
		if (target.classes.contains("KeyBindingOption")) {
			if (!clickUsed) {
				setupKeyBindings();
			}

			target.text = "(press key to change)";

			//we need to use .listen instead of .first.then so that if the user does not press a key
			//we can cancel the listener at a later time
			keyDownSub = document.body.onKeyDown.listen((KeyboardEvent event) {
				keyDownSub.cancel();
				String key = fromKeyCode(event.keyCode);
				int keyCode = event.keyCode;
				if (key == "") {
					//it was not a special key
					keyPressSub = document.body.onKeyPress.listen((KeyboardEvent event) {
						keyPressSub.cancel();
						KeyEvent keyEvent = new KeyEvent.wrap(event);
						target.text = new String.fromCharCode(keyEvent.charCode).toUpperCase();
						keys[target.id] = keyCode;
						//store keycode and charcode
						localStorage[target.id] = keyCode.toString() + "." + keyEvent.charCode.toString();

						windowManager.settings.checkDuplicateKeyAssignments();
					});
				} else {
					target.text = key;
					keys[target.id] = event.keyCode;
					localStorage[target.id] = event.keyCode.toString();
				}

				windowManager.settings.checkDuplicateKeyAssignments();
			});
		}

		//handle changing streets via exit signs
		if (target.className.contains("ExitLabel")) {
			playerTeleFrom = target.attributes['from'];
			streetService.requestStreet(target.attributes['tsid']);
		}

		if (target.classes.contains("chatSpawn")) {
			new Chat(target.text);
			target.classes.remove("unread");
		}
	}

	void setupKeyBindings() {
		//this prevents 2 keys from being set at once
		keyPressSub?.cancel();
		keyDownSub?.cancel();

		//set up key bindings
		keys.forEach((String action, int keyCode) {
			List<String> storedValue = null;
			if (localStorage[action] != null) {
				storedValue = localStorage[action].split(".");
				keys[action] = int.parse(storedValue[0]);
			} else {
				localStorage[action] = keys[action].toString();
			}

			String key = fromKeyCode(keys[action]);
			if (key == "") {
				if (storedValue != null && storedValue.length > 1) {
					querySelector("#$action").text = new String.fromCharCode(int.parse(storedValue[1])).toUpperCase();
				} else {
					querySelector("#$action").text = new String.fromCharCode((keys[action]));
				}
			} else {
				querySelector("#$action").text = key;
			}
		});

		CheckboxInputElement graphicsBlur = querySelector("#GraphicsBlur") as CheckboxInputElement;
		graphicsBlur.onChange.listen((_) {
			localStorage["GraphicsBlur"] = graphicsBlur.checked.toString();
		});

		//Handle player input
		//KeyUp and KeyDown are neccesary for preventing weird movement glitches
		document.onKeyDown.listen((KeyboardEvent k) {
			if (menuKeyListener != null || ignoreChatFocus) {
				return;
			}

			//check for chat focus stuff before deciding on ignore keys
			if (k.keyCode == keys["ChatFocusBindingPrimary"] || k.keyCode == keys["ChatFocusBindingAlt"]) {
				advanceChatFocus(k);
			}

			if (ActionBubble.occuring) {
				return;
			}

			updateKeys(true, k.keyCode);
		});

		document.onKeyUp.listen((KeyboardEvent k) => updateKeys(false, k.keyCode));

		//listen for right-clicks on entities that we're close to
		document.body.onContextMenu.listen((MouseEvent e) {
			if (ignoreKeys) {
				return;
			}
			//just like pressing a key for 10ms
			doObjectInteraction();
			new Timer(new Duration(milliseconds: 10), () {
				activateControl('actionKey', false, 'mouse');
			});
		});

		//only for mobile version
		Joystick joystick = new Joystick(querySelector('#Joystick'), querySelector('#Knob'), deadzoneInPercent: .2);

		joystick.onMove.listen((_) {
			//don't move during harvesting, etc.
			if (!ActionBubble.occuring) {
				activateControl('upKey', joystick.UP, 'joystick');
				activateControl('downKey', joystick.DOWN, 'joystick');
				activateControl('leftKey', joystick.LEFT, 'joystick');
				activateControl('rightKey', joystick.RIGHT, 'joystick');
			}

			Element clickMenu = querySelector("#RightClickMenu");
			if (clickMenu != null) {
				Element list = querySelector('#RCActionList');
				//only select a new option once every 300ms
				if (lastSelect.add(new Duration(milliseconds: 300)).isBefore(new DateTime.now())) {
					if (joystick.UP) {
						selectUp(list.querySelectorAll('.RCItem'), "RCItemSelected");
					}

					if (joystick.DOWN) {
						selectDown(list.querySelectorAll('.RCItem'), "RCItemSelected");
					}
				}

				if (joystick.LEFT || joystick.RIGHT) {
					stopMenu(clickMenu);
				}
			}
		});

		joystick.onRelease.listen((_) {
			for (String key in ['up', 'down', 'right', 'left']) {
				activateControl(key + 'Key', false, 'joystick');
			}
		});

		document.onTouchStart.listen((TouchEvent event) {
			Element target = event.target;

			if (target.id == "AButton") {
				event.preventDefault(); //to disable long press calling the context menu
				activateControl('jumpKey', true, 'keyboard');
			}

			if (target.id == "BButton") {
				event.preventDefault(); //to disable long press calling the context menu
				doObjectInteraction();
			}
		});

		document.onTouchEnd.listen((TouchEvent event) {
			Element target = event.target;

			if (target.id == "AButton") {
				activateControl('jumpKey', false, 'keyboard');
			}
		});

		document.onClick.listen((MouseEvent event) => clickOrTouch(event, null));
		document.onTouchStart.listen((TouchEvent event) => clickOrTouch(null, event));

		new TouchScroller(querySelector('#inventory'), TouchScroller.HORIZONTAL);
		//end mobile specific stuff
	}

	void updateKeys(bool newState, int keyCode) {
		bool _checkControl(String control) =>
			keyCode == keys[control + 'BindingPrimary'] || keyCode == keys[control + 'BindingAlt'];

		if (ignoreKeys) {
			return;
		}

		for (String key in ['Up', 'Down', 'Left', 'Right', 'Jump', 'Action']) {
			if (!_checkControl(key)) {
				continue;
			}

			if (newState && key == 'Action') {
				doObjectInteraction();
			} else {
				activateControl(key.toLowerCase() + 'Key', newState, 'keyboard');
			}
		}
	}

	void doObjectInteraction([MouseEvent e, List<String> ids]) {
		if (querySelector("#RightClickMenu") != null) {
			doAction(querySelector('#RCActionList'), querySelector("#RightClickMenu"), "RCItemSelected");
			return;
		}

		if (CurrentPlayer.intersectingObjects.length > 0
			&& querySelector('#RightClickMenu') == null
			&& !ActionBubble.occuring
		) {
			if (CurrentPlayer.intersectingObjects.length == 1) {
				CurrentPlayer.intersectingObjects.forEach((String id, Rectangle rect) =>
					(entities[id] ?? otherPlayers[id]).interact(id));
			} else {
				createMultiEntityWindow();
			}
		}
	}

	void createMultiEntityWindow() {
		querySelector("#InteractionWindow")?.remove();
		document.body.append(InteractionWindow.create());
	}

	// Right-click menu functions
	void hideClickMenu(Element window) => window?.remove();

	void showClickMenu({
		MouseEvent click,
		String title: 'Interact',
		String description: 'Desc',
		String id,
		List<Action> actions: const [],
		String itemName,
		String serverClass
	}) {
		assert (id != null);

		hideClickMenu(querySelector('#RightClickMenu'));
		RightClickMenu.create3(click, title, id, description: description, actions: actions, itemName: itemName, serverClass: serverClass);

		Element clickMenu = querySelector('#RightClickMenu');
		Element list = querySelector('#RCActionList');

		menuKeyListener = document.onKeyDown.listen((KeyboardEvent k) {
			if ((k.keyCode == keys["UpBindingPrimary"] || k.keyCode == keys["UpBindingAlt"]) && !ignoreKeys) //up arrow or w and not typing
				selectUp(list.querySelectorAll('.RCItem'), "RCItemSelected");
			if ((k.keyCode == keys["DownBindingPrimary"] || k.keyCode == keys["DownBindingAlt"]) && !ignoreKeys) //down arrow or s and not typing
				selectDown(list.querySelectorAll('.RCItem'), "RCItemSelected");
			if ((k.keyCode == keys["LeftBindingPrimary"] || k.keyCode == keys["LeftBindingAlt"]) && !ignoreKeys) //left arrow or a and not typing
				stopMenu(clickMenu);
			if ((k.keyCode == keys["RightBindingPrimary"] || k.keyCode == keys["RightBindingAlt"]) && !ignoreKeys) //right arrow or d and not typing
				stopMenu(clickMenu);
			if ((k.keyCode == keys["JumpBindingPrimary"] || k.keyCode == keys["JumpBindingAlt"]) && !ignoreKeys) //spacebar and not typing
				stopMenu(clickMenu);
			if ((k.keyCode == keys["ActionBindingPrimary"] || k.keyCode == keys["ActionBindingAlt"]) && !ignoreKeys) //spacebar and not typing
				doAction(list, clickMenu, "RCItemSelected");
			//esc key
			if (k.keyCode == 27) {
				stopMenu(clickMenu);
			}
		});

		document.onClick.listen((_) => stopMenu(clickMenu));
	}

	void selectUp(List<Element> options, String className) {
		int removed = 0;
		for (int i = 0; i < options.length; i++) {
			options[i].classes.remove('action_hover');
			if (options[i].classes.remove(className)) {
				removed = i;
			}
		}
		if (removed == 0) {
			options[options.length - 1].classes.add(className);
			options[options.length - 1].classes.add('action_hover');
		} else {
			options[removed - 1].classes.add(className);
			options[removed - 1].classes.add('action_hover');
		}

		lastSelect = new DateTime.now();
	}

	void selectDown(List<Element> options, String className) {
		int removed = options.length - 1;
		for (int i = 0; i < options.length; i++) {
			options[i].classes.remove('action_hover');
			if (options[i].classes.remove(className)) {
				removed = i;
			}
		}
		if (removed == options.length - 1) {
			options[0].classes.add(className);
			options[0].classes.add('action_hover');
		} else {
			options[removed + 1].classes.add(className);
			options[removed + 1].classes.add('action_hover');
		}

		lastSelect = new DateTime.now();
	}

	void stopMenu(Element window) {
		transmit('menuStopping', window);
		menuKeyListener?.cancel();
		menuKeyListener = null;
		MenuKeys.clearListeners();
		hideClickMenu(window);
	}

	void doAction(Element list, Element window, String className) {
		for (Element element in list.querySelectorAll('.RCItem')) {
			if (element.classes.contains(className)) {
				//click the hard way so that we have coordinates to go with it
				Rectangle rect = element.getBoundingClientRect();
				element.dispatchEvent(new MouseEvent('click', clientX: (rect.left + rect.width ~/ 2) ~/ 1, clientY: rect.top ~/ 1));
				break;
			}
		}
		stopMenu(window);
	}

	String fromKeyCode(int keyCode) =>
		const {
			8: "backspace",
			9: "tab",
			13: "enter",
			16: "shift",
			17: "ctrl",
			18: "left alt",
			19: "pause/break",
			20: "caps lock",
			27: "escape",
			32: "space",
			33: "page up",
			34: "page down",
			35: "end",
			36: "home",
			37: "left arrow",
			38: "up arrow",
			39: "right arrow",
			40: "down arrow",
			45: "insert",
			46: "delete",
			91: "left window",
			92: "right window",
			93: "select key",
			96: "numpad 0",
			97: "numpad 1",
			98: "numpad 2",
			99: "numpad 3",
			100: "numpad 4",
			101: "numpad 5",
			102: "numpad 6",
			103: "numpad 7",
			104: "numpad 8",
			105: "numpad 9",
			106: "multiply",
			107: "add",
			109: "subtract",
			110: "decimal point",
			111: "divide",
			112: "F1",
			113: "F2",
			114: "F3",
			115: "F4",
			116: "F5",
			117: "F6",
			118: "F7",
			119: "F8",
			120: "F9",
			121: "F10",
			122: "F11",
			123: "F12",
			144: "num lock",
			145: "scroll lock",
			225: "right alt",
		}[keyCode] ?? "";

	bool konamiDone = false;
	bool freeTeleportUsed = false;

	void initKonami() {
		final List<int> konamiKeys = [38, 38, 40, 40, 37, 39, 37, 39, 66, 65];
		final String konami = konamiKeys.join(", ");
		List<int> keys = [];

		document.onKeyDown.listen((KeyboardEvent e) {
			if (!konamiDone && konamiKeys.contains(e.keyCode)) {
				keys.add(e.keyCode);

				if (keys.toString().indexOf(konami) >= 0) {
					new Toast("Your next teleport is free!");
					konamiDone = true;
				}
			}
		});
	}
}