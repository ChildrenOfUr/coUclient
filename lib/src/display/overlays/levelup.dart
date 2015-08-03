part of couclient;

class LevelUpOverlay extends Overlay {
	Element dropper;
	LevelUpOverlay(String id):super(id) {
		dropper = querySelector("#lu-dropper");
	}

	open() {
		dropper.text = metabolics.level.toString();
		displayElement.hidden = false;
		audio.playSound('levelUp');
		inputManager.ignoreKeys = true;
		displayElement.querySelector("#lu-button").onClick.first.then((_) => close());
	}
}

LevelUpOverlay levelUp;