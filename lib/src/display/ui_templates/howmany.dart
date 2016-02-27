part of couclient;

class HowManyMenu {
	static StreamSubscription keyListener;

	static Element create(MouseEvent Click, String action, int max, Function callback, {String itemName: ''}) {
		destroy();

		action = action.substring(0, 1).toUpperCase() + action.substring(1);

		int numItems = 1;

		DivElement menu = new DivElement()
			..id = 'HowManyMenu';
		SpanElement title = new SpanElement()
			..id = 'hm-title'
			..text = action + ' how many ' + itemName + 's?';
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
		InputElement number = new InputElement()
			..id = 'hm-num'
			..value = numItems.toString();
		ButtonElement enter = new ButtonElement()
			..id = 'hm-enter'
			..classes.add('hm-btn')
			..text = action + ' ' + numItems.toString();

		inputManager.ignoreKeys = true;

		// do stuff
		plus.onClick.listen((_) {
			int value = int.parse(number.value) + 1;
			if(value > max) {
				value = max;
			}
			number.value = value.toString();
			enter.text = '$action $value';
		});
		minus.onClick.listen((_) {
			int value = int.parse(number.value) - 1;
			if(value < 0) {
				value = 0;
			}
			number.value = value.toString();
			enter.text = '$action $value';
		});

		enter.onClick.first.then((_) {
			_doVerb(int.parse(number.value),callback);
		});

		//wait a little so that an [enter] used to prompt this window doesn't count for it too
		new Timer(new Duration(milliseconds: 100), () {
			keyListener = document.onKeyPress.listen((KeyboardEvent e) {
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

		int x, y;
		x = Click.client.x;
		y = Click.client.y;

		menu.style
			..opacity = '1.0'
			..position = 'absolute'
			..top = y.toString() + ' px'
			..left = x.toString() + ' px';

		return menu;
	}

	static void _doVerb(int count, Function callback) {
		destroy();
		callback(howMany: count);
	}

	static void destroy() {
		inputManager.ignoreKeys = false;
		keyListener?.cancel();
		querySelector('#HowManyMenu')?.remove();
	}
}