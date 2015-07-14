part of couclient;

class MapWindow extends Modal {
  String id = 'mapWindow';
  Element trigger = querySelector("#mapButton");

  MapWindow() {
    prepare();
    // MAPWINDOW LISTENERS //
    view.mapButton.onClick.listen((_) {
      if (this.window.hidden) {
        this.open();
        worldMap = new WorldMap(currentStreet.hub_id);
        worldMap = new WorldMap(currentStreet.hub_id);
      } else {
        this.close();
      }
    });

    document.onKeyDown.listen((KeyboardEvent k) {
      if (inputManager == null) return;

      if ((k.keyCode == inputManager.keys["MapBindingPrimary"] ||
              k.keyCode == inputManager.keys["MapBindingAlt"]) &&
          !inputManager.ignoreKeys) {
        if (this.window.hidden) {
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

  open() {
	  super.window.hidden = false;
	  this.focus();
	  trigger.classes.remove('closed');
	  trigger.classes.add('open');
  }

  close() {
	  super.window.hidden = true;
	  trigger.classes.remove('open');
	  trigger.classes.add('closed');
  }
}
