part of couclient;

abstract class InformationDisplay {
	Element displayElement;
	bool elementOpen = false;
	bool ignoreShortcuts = false;

	setupKeyBinding(String keyName, {Function openCallback, Function closeCallback}) {
		document.onKeyDown.listen((KeyboardEvent k) {
			if(inputManager == null || ignoreShortcuts)
				return;

			if((k.keyCode == inputManager.keys["${keyName}BindingPrimary"]
			    || k.keyCode == inputManager.keys["${keyName}BindingAlt"])
			   && (elementOpen || !inputManager.ignoreKeys)) {
				if(displayElement.hidden) {
					open();
					if(openCallback != null) {
						openCallback();
					}
				} else {
					close();
					if(closeCallback != null) {
						closeCallback();
					}
				}
			}
		});
	}

	setupUiButton(Element uiOpenCloseElement, {Function openCallback, Function closeCallback}) {
		uiOpenCloseElement.onClick.listen((_) {
			if(displayElement.hidden) {
				open();
				if(openCallback != null) {
					openCallback();
				}
			} else {
				close();
				if(closeCallback != null) {
					closeCallback();
				}
			}
		});
	}

	open();

	close();
}