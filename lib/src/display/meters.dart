part of couclient;

class Meters {
	Element meter = querySelector('ur-meters');
	Element currantElement = querySelector('#currCurrants');
	Element currantLabel = querySelector("#currantLabel");

	updateImgDisplay() {
		meter.attributes['imagination'] = metabolics.img.toString();
	}

	updateEnergyDisplay() {
		meter.attributes['energy'] = metabolics.energy.toString();
		meter.attributes['maxenergy'] = metabolics.maxEnergy.toString();
	}

	updateMoodDisplay() {
		meter.attributes['mood'] = metabolics.mood.toString();
		meter.attributes['maxmood'] = metabolics.maxMood.toString();
	}

	updateCurrantsDisplay() {
		int oldCurrants;

		try {
			oldCurrants = int.parse(currantElement.text.replaceAll(",", ""));
		} catch (_) {
			oldCurrants = 0;
		}

		currantElement.text = commaFormatter.format(metabolics.currants);
		currantLabel.text = (metabolics.currants != 1 ? "Currants" : "Currant");

		if (oldCurrants != metabolics.currants) {
			// Animate if the number changed
			animateText(currantElement.parent, currantElement.text, "currant-anim");
		}
	}

	updateNameDisplay() {
		meter.attributes['playername'] = game.username;
	}

	updateAll() {
		updateCurrantsDisplay();
		updateEnergyDisplay();
		updateImgDisplay();
		updateMoodDisplay();
	}
}
