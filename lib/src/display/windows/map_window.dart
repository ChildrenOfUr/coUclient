part of couclient;

class MapWindow extends Modal {
	String id = 'mapWindow';
	Element trigger = querySelector("#mapButton");

	MapWindow() {
		prepare();

		setupUiButton(view.mapButton,openCallback:_drawWorldMap);
		setupKeyBinding("Map",openCallback:_drawWorldMap);

		new Service(['teleportByMapWindow'], (event) {
			this.close();
		});
	}

	_drawWorldMap() {
		worldMap = new WorldMap(currentStreet.hub_id);
	}

	@override
	open() {
		super.open();
		trigger.classes.remove('closed');
		trigger.classes.add('open');
	}

	@override
	close() {
		super.close();
		trigger.classes.remove('open');
		trigger.classes.add('closed');
	}
}
