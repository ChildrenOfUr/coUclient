part of couclient;

class Overlay extends InformationDisplay {
	Overlay(String id) {
		displayElement = querySelector("#" + id);

		// closing
		if (displayElement.querySelector(".close") != null) {
			displayElement.querySelector(".close").onClick.listen((_) {
				this.close();
			});
		}
		document.onKeyUp.listen((KeyboardEvent e) {
			if (!displayElement.hidden && e.keyCode == 27) {
				this.close();
			}
		});
	}

	open() {
		displayElement.hidden = false;
		elementOpen = true;
		inputManager.ignoreKeys = true;
		transmit("worldFocus", false);
	}

	close() {
		displayElement.hidden = true;
		elementOpen = false;
		inputManager.ignoreKeys = false;
		transmit("wordFocus", true);
	}
}

void setUpOverlays() {
	newDay = new NewDayOverlay("newday");
	imgMenu = new ImgOverlay("pauseMenu");
	levelUp = new LevelUpOverlay("levelup");
}