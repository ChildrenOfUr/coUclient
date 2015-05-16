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
    	if (k.keyCode == inputManager.keys["MapBinding"] && !inputManager.ignoreKeys) {
    		this.open();
    		worldMap = new WorldMap(currentStreet.hub_id);
    	}
    });

  }

}
