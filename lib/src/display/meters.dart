part of couclient;

class MetersView {
	Meters _meters = querySelector('ur-meters') as Meters;
	Element _currantElement = querySelector('#currCurrants');
	NumberFormat commaFormatter = new NumberFormat("#,###");

	void updateImgDisplay() {
		_meters.imagination = metabolics.img;
	}

	void updateEnergyDisplay() {
		_meters.energy = metabolics.energy;
		_meters.maxenergy = metabolics.maxEnergy;
	}

	void updateMoodDisplay() {
		_meters.mood = metabolics.mood;
		_meters.maxmood = metabolics.maxMood;
	}

	void updateCurrantsDisplay() {
		_currantElement.text = commaFormatter.format(metabolics.currants);
	}

	void updateNameDisplay() {
		_meters.playername = game.username;
	}

	void updateAll() {
		updateCurrantsDisplay();
		updateEnergyDisplay();
		updateImgDisplay();
		updateMoodDisplay();
		updateNameDisplay();
	}
}