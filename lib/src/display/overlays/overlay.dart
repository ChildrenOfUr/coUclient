part of couclient;

class Overlay {
	Overlay(String id) {
		overlay = querySelector("#" + id);

		// closing
		if (overlay.querySelector(".close") != null) {
			overlay.querySelector(".close").onClick.listen((_) {
				this.close();
			});
		}
		document.onKeyUp.listen((KeyboardEvent e) {
			if (!overlay.hidden && e.keyCode == 27) {
				this.close();
			}
		});
	}

	Element overlay;

	open() {
		overlay.hidden = false;
	}

	close() {
		overlay.hidden = true;
	}
}

void setUpOverlays() {
	newDay = new NewDayOverlay("newday");
	imgMenu = new ImgOverlay("pauseMenu");
}