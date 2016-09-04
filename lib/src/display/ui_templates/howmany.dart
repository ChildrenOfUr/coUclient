part of couclient;

class HowManyMenu {
	static StreamSubscription keyListener;
	static InputElement number;
	static Element enter;
	static int maxVal, value = 1;
	static String actionString, typedString = '';
	static bool boxFocused = false;

	static create(MouseEvent Click, String action, int max, Function callback, {String itemName: ''}) {
		destroy();

		if(action != null && action.length > 0) {
			action = action.substring(0, 1).toUpperCase() + action.substring(1);
		}

		int numItems = 1;
		maxVal = max;
		actionString = action;

		String pluralItemName = itemName;
		if (!pluralItemName.endsWith("s")) {
			pluralItemName += "s";
		}

		DivElement menu = new DivElement()
			..id = 'HowManyMenu';
		SpanElement title = new SpanElement()
			..id = 'hm-title'
			..text = action + ' how many ' + pluralItemName + '?';
		DivElement controls = new DivElement()
			..id = 'hm-controls';
		ButtonElement minus = new ButtonElement()
			..id = 'hm-minus'
			..classes.add('hm-btn')
			..text = '-';
		ButtonElement plus = new ButtonElement()
			..id = 'hm-plus'
			..classes.add('hm-btn')
			..text = '+';
		number = new InputElement()
			..id = 'hm-num'
			..value = numItems.toString();
		enter = new ButtonElement()
			..id = 'hm-enter'
			..classes.add('hm-btn')
			..text = action + ' ' + numItems.toString();

		inputManager.ignoreKeys = true;

		// do stuff
		plus.onClick.listen((_) => _setValue(value+1));
		minus.onClick.listen((_) => _setValue(value-1));

		enter.onClick.first.then((_) {
			_doVerb(int.parse(number.value),callback);
		});

		number.onFocus.listen((_) => boxFocused = true);
		number.onBlur.listen((_) => boxFocused = false);

		//1..9 in number row
		List<int> numCodes = [49,50,51,52,53,54,55,56,57];

		//wait a little so that an [enter] used to prompt this window doesn't count for it too
		new Timer(new Duration(milliseconds: 100), () {
			keyListener = document.onKeyDown.listen((KeyboardEvent e) {
				//27 == esc key
				if (e.keyCode == 27) {
					e.stopPropagation();
					destroy();

					//see if there's another window that we want to focus
					for (Element modal in querySelectorAll('.window')) {
						if (!modal.hidden) {
							modals[modal.id]?.focus();
						}
					}
				}
				//13 == enter key
				if (e.keyCode == 13) {
					e.stopPropagation();
					_doVerb(int.parse(number.value),callback);
				}
				//number row
				if (numCodes.contains(e.keyCode)) {
					if(boxFocused) {
						return;
					}
					e.stopPropagation();
					typedString = '$typedString${numCodes.indexOf(e.keyCode)+1}';
					_setValue(int.parse(typedString));
				}
				//backspace
				if (e.keyCode == 8) {
					e.stopPropagation();
					if(boxFocused) {
						return;
					}
					typedString = '$typedString'.substring(0,'$typedString'.length-1);
					if(typedString.length == 0) {
						_setValue(1);
					} else {
						_setValue(int.parse(typedString));
					}
				}
				//up arrow or w
				if((e.keyCode == inputManager.keys["UpBindingPrimary"] || e.keyCode == inputManager.keys["UpBindingAlt"])) {
					_setValue(value+1);
				}
				//down arrow or s
				if((e.keyCode == inputManager.keys["DownBindingPrimary"] || e.keyCode == inputManager.keys["DownBindingAlt"])) {
					_setValue(value-1);
				}
			});
		});

		controls
			..append(minus)
			..append(number)
			..append(plus);
		menu
			..append(title)
			..append(controls)
			..append(enter);

		querySelector("#windowHolder").append(menu);

		int x = Click.page.x;
		int y = Click.page.y;

		menu.style
			..position = 'absolute'
			..top = '${y}px'
			..left = '${x}px'
			..transform = 'translate(-50%, -100%)';

		if (x == 0 && y == 0) {
			//the click was probably fake so let's just center it
			menu.style
				..top = '50%'
				..left = '50%';
		}
	}

	static void _setValue(int newVal) {
		value = newVal.clamp(0, maxVal);
		number.value = value.toString();
		enter.text = '$actionString $value';
	}

	static void _doVerb(int count, Function callback) {
		destroy();
		count = count.clamp(0, maxVal);
		if (count > 0) {
			callback(howMany: count);
		}
	}

	static void destroy() {
		inputManager.ignoreKeys = false;
		keyListener?.cancel();
		typedString = '';
		querySelector('#HowManyMenu')?.remove();
		value = 1;
	}
}
