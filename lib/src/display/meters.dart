part of couclient;

class Meters {
	int runCount;

	NumberFormat commaFormatter = new NumberFormat("#,###");

	Element greenDisk = querySelector('#energyDisks .green');
	Element redDisk = querySelector('#energyDisks .red');
	Element hurtDisk = querySelector('#leftDisk .hurt');
	Element deadDisk = querySelector('#leftDisk .dead');
	Element avatarDisplay = querySelector("#moodAvatar");

	Element currantElement = querySelector('#currCurrants');
	Element currantLabel = querySelector("#currantLabel");

	AnchorElement playerNameDisplay = querySelector("#playerName");
	Element energyDisplay = querySelector("#currEnergy");
	Element maxEnergyDisplay = querySelector("#maxEnergy");
	Element moodDisplay = querySelector("#moodMeter .curr");
	Element maxMoodDisplay = querySelector("#moodMeter .max");
	Element moodPercentDisplay = querySelector("#moodMeter .number");
	Element imgDisplay = querySelector("#currImagination");

	Meters() {
		runCount = 0;
	}

	void updateAvatarDisplay() {
		if (runCount < 5 || runCount % 5 == 0) {
			// run on load, and once every 5 refreshes afterward to avoid overloading the server
			HttpRequest.requestCrossOrigin('${Configs.http}//${Configs.utilServerAddress}/trimImage?username=${game.username}')
				.then((String response) => avatarDisplay.style.backgroundImage = "url(data:image/png;base64,$response)");

			// update username links
			(querySelector("#openProfilePageFromChatPanel") as AnchorElement).href =
				"https://childrenofur.com/profile?username=${game.username}";
		}
	}

	void update() {
		// update number displays
		updateAll();

		// update energy disk angles and opacities
		greenDisk.style.transform = 'rotate(${120 - (metabolics.energy / metabolics.maxEnergy) * 120}deg)';
		redDisk.style.transform = 'rotate(${120 - (metabolics.energy / metabolics.maxEnergy) * 120}deg)';
		redDisk.style.opacity = (1 - metabolics.energy / metabolics.maxEnergy).toString();
		hurtDisk.style.backfaceVisibility = 'visible';
		hurtDisk.style.opacity = (0.7 - (metabolics.mood / metabolics.maxMood)).toString();
		deadDisk.style.opacity = (metabolics.mood <= 0 ? 1 : 0).toString();

		// updates portrait
		updateAvatarDisplay();
		runCount++;
	}

	void updateImgDisplay() {
		imgDisplay.text = commaFormatter.format(metabolics.img);
	}

	void updateEnergyDisplay() {
		energyDisplay.text = metabolics.energy.toString();
		maxEnergyDisplay.text = metabolics.maxEnergy.toString();
	}

	void updateMoodDisplay() {
		moodDisplay.text = metabolics.mood.toString();
		maxMoodDisplay.text = metabolics.maxMood.toString();
		moodPercentDisplay.text = (metabolics.mood / metabolics.maxMood * 100).toInt().toString();
	}

	void updateCurrantsDisplay() {
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

	void updateNameDisplay() {
		playerNameDisplay
			..text = game.username
			..href = "https://childrenofur.com/profile?username=" + game.username;
	}

	void updateAll() {
		updateCurrantsDisplay();
		updateEnergyDisplay();
		updateImgDisplay();
		updateMoodDisplay();
	}
}
