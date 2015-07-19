part of couclient;

class GpsIndicator {
	Element containerE = querySelector("#gps-container");
	Element closeButtonE = querySelector("#gps-cancel");
	Element nextStreetE = querySelector("#gps-next");
	Element destinationE = querySelector("#gps-destination");
	Element arrowE = querySelector("#gps-direction");
	bool loadingNew;

	GpsIndicator() {
		closeButtonE.onClick.listen((_) => this.cancel());
	}

	update() {
		if (!loadingNew) {
			if (GPS.active) {
				containerE.hidden = false;
				nextStreetE.text = GPS.nextStreetName;
				destinationE.text = GPS.destinationName;
				if (GPS.nextStreetName == "You're off the path") {
					GPS.getRoute(currentStreet.label, GPS.destinationName);
				} else {
					arrowE.style.transform = "rotate(${calculateArrowDirection()}rad)";
				}
			} else {
				cancel();
			}
		} else {
			containerE.hidden = true;
		}
	}

	cancel() {
		GPS.active = false;
		containerE.hidden = true;
		nextStreetE.text = destinationE.text = null;
		arrowE.style.transform = null;
	}

	num calculateArrowDirection() {
		num radians;
		num exitX, exitY;
		num playerX = CurrentPlayer.posX;
		num playerY = CurrentPlayer.posY;

		for(Map exit in minimap.currentStreetExits) {
			if (exit["streets"].contains(GPS.nextStreetName)) {
				if (exit["streets"].length > 1) { // signs on both sides
					exitX = exit["x"] + 100;
				} else {
					exitX = exit["x"];
				}
				exitY = exit["y"] + 115; // center of the height
				break; // no point in wasting time, we found the signpost
			}
		};

		if (exitX == null || exitY == null) {
			return 0; // error
		}

		Rectangle box;

		if (playerY < exitY) {
			// player is above the signpost

			if (playerX < exitX) {
				// player is above and to the left of the signpost
				box = new Rectangle(playerX, playerY, exitX - playerX, exitY - playerY);
			} else if (playerX > exitX) {
				// player is above and to the right of the signpost
				box = new Rectangle(exitX, playerY, playerX - exitX, exitY - playerY);
			}

			radians = (PI / 2) - atan2(box.width, box.height);

		} else if (playerY > exitY) {
			// player is below the signpost

			if (playerX < exitX) {
				// player is below and to the left of the signpost
				box = new Rectangle(playerX, exitY, exitX - playerX, exitY - playerY);
			} else if (playerX > exitX) {
				// player is below and to the right of the signpost
				box = new Rectangle(exitX, exitY, playerX - exitX, playerY - exitY);
			}

			radians = atan2(box.width, box.height);

			if (box.width > box.height) {
				radians -= (PI / 2);
			}

			radians = -atan2(box.height, box.width);
		}

		return radians;
	}
}