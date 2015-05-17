part of couclient;

class MapWindow extends Modal {
	String id = 'mapWindow';

	MapWindow() {

		prepare();
		// MAPWINDOW LISTENERS //
		view.mapButton.onClick.listen((_) {
			this.open();
			worldMap = new WorldMap(currentStreet.hub_id);
		});

		document.onKeyDown.listen((KeyboardEvent k) {
			if(k.keyCode == inputManager.keys["MapBindingPrimary"]
			   || k.keyCode == inputManager.keys["MapBindingAlt"]
			      && !inputManager.ignoreKeys) {
				if(this.window.hidden) {
					this.open();
					worldMap = new WorldMap(currentStreet.hub_id);
				} else {
					this.close();
				}
			}
		});
	}
}
