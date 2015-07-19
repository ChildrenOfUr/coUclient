part of couclient;

abstract class InformationDisplay {
	Element displayElement;
	bool elementOpen = false;

	setupKeyBinding(String keyName, {Function openCallback, Function closeCallback}) {
		document.onKeyDown.listen((KeyboardEvent k) {
			if(inputManager == null)
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

	open();

	close();
}