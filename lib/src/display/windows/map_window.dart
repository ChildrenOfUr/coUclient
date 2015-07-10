part of couclient;

class MapWindow extends Modal {
	String id = 'mapWindow';

	MapWindow() {

		prepare();
		// MAPWINDOW LISTENERS //
		view.mapButton.onClick.listen((_) {
			if(this.window.hidden) {
				this.open();
				worldMap = new WorldMap(currentStreet.hub_id);
				worldMap = new WorldMap(currentStreet.hub_id);
			} else {
				this.close();
			}
		});

		document.onKeyDown.listen((KeyboardEvent k) {
			if(inputManager == null)
				return;

			if((k.keyCode == inputManager.keys["MapBindingPrimary"]
			   || k.keyCode == inputManager.keys["MapBindingAlt"])
			      && !inputManager.ignoreKeys) {
				if(this.window.hidden) {
					this.open();
					worldMap = new WorldMap(currentStreet.hub_id);
				} else {
					this.close();
				}
			}
		});

    new Service(['teleportByMapWindow'], (event) {
      this.close();
    });
	}
}
