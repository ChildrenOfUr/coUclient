library dialog;

import 'dart:html';
import 'dart:async';

class Dialog {
	Element actionDialog;
	Element _dialogTitle, _dialogBody;
	List<Element> buttons;
	List<StreamSubscription> buttonListeners = [];
	StreamController _buttonController;

	void set dialogTitle(String val) {
		_dialogTitle.text = val;
	}

	void set dialogBody(String val) {
		_dialogBody.text = val;
	}

	Dialog(this.actionDialog) {
		_buttonController = new StreamController.broadcast();

		_dialogTitle = actionDialog.querySelector('.dialogTitle');
		if(_dialogTitle == null) {
			throw 'Dialog must have a child element with a class of dialogTitle';
		}
		_dialogBody = actionDialog.querySelector('.dialogBody');
		if(_dialogBody == null) {
			throw 'Dialog must have a child element with a class of dialogBody';
		}

		buttons = actionDialog.querySelector('.buttons').children;
		buttons.forEach((Element button) {
			StreamSubscription listener = button.onClick.listen((_) {
				if(button.attributes['affirmative'] != null) {
					_buttonController.add(ButtonEvent.Affirmative);
				} else if (button.attributes['negative'] != null) {
					_buttonController.add(ButtonEvent.Negative);
				}
			});
			buttonListeners.add(listener);
		});
	}

	open() {
		actionDialog.hidden = false;
	}

	close() {
		actionDialog.hidden = true;
	}

	Stream<ButtonEvent> get onButtonClick => _buttonController.stream;
}

enum ButtonEvent {Affirmative, Negative}