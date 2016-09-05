part of couclient;

class Overlay extends InformationDisplay {
	Overlay(String id, [bool modal = false]) {
		displayElement = querySelector("#" + id);

		if (!modal) {
			// Close button
			displayElement.querySelector(".close")?.onClick?.listen((_) {
				this.close();
			});

			// Escape key
			document.onKeyUp.listen((KeyboardEvent e) {
				if (!displayElement.hidden && e.keyCode == 27) {
					this.close();
				}
			});
		}
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
		transmit("worldFocus", true);
	}
}

void setUpOverlays() {
	newDay = new NewDayOverlay("newday");
	imgMenu = new ImgOverlay("pauseMenu");
	levelUp = new LevelUpOverlay("levelup");
}
