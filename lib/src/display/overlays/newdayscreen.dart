part of couclient;

class NewDayOverlay extends Overlay {
	NewDayOverlay(String id):super(id) {
		new Service(['newDay', 'newDayFake'], (event) {
			open();
		});
	}

	open() {
		String maxenergy = metabolics.maxEnergy.toString();
		displayElement.querySelector("#newday-date").text = clock.dayofweek + ", the " + clock.day + " of " + clock.month;
		displayElement.querySelector("#newday-refill-1").text = maxenergy;
		displayElement.querySelector("#newday-refill-2").text = maxenergy;
		displayElement.hidden = false;
		new Timer(new Duration (milliseconds: 100), () {
			displayElement.querySelector("#newday-sun").classes.add("up");
			displayElement.querySelector("#newday-refill-disc").classes.add("full");
		});
		inputManager.ignoreKeys = true;
		displayElement.querySelector("#newday-button").onClick.first.then((_) => close());
		// TODO: new day screen sound
	}

	close() {
		displayElement.hidden = true;
		inputManager.ignoreKeys = false;
		displayElement.querySelector("#newday-sun").classes.remove("up");
		displayElement.querySelector("#newday-refill-disc").classes.remove("full");
	}
}

NewDayOverlay newDay;