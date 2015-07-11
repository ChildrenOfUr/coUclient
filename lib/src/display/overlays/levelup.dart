part of couclient;

class LevelUpOverlay extends Overlay {
	Element dropper;
	LevelUpOverlay(String id):super(id) {
		dropper = querySelector("#lu-dropper");
		new Service(['levelUp', 'levelUpFake'], (event) {
			dropper.text = metabolics.level.toString();
			open();
		});
	}

	open() {
		overlay.hidden = false;
		audio.playSound('levelUp');
		new Timer(new Duration (milliseconds: 100), () {
		});
		inputManager.ignoreKeys = true;
		overlay.querySelector("#lu-button").onClick.first.then((_) => close());
	}
}

LevelUpOverlay levelUp;