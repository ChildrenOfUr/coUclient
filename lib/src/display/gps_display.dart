part of couclient;

class GpsIndicator {
	Element containerE = querySelector("#gps-container");
	Element closeButtonE = querySelector("#gps-cancel");
	Element nextStreetE = querySelector("#gps-next");
	Element destinationE = querySelector("#gps-destination");
	Element arrowE = querySelector("#gps-direction");
	bool loadingNew,
		arriveFade = false;

	GpsIndicator() {
		closeButtonE.onClick.listen((_) => this.cancel());
	}

	void update() {
		if (!loadingNew) {
			if (GPS.active) {
				containerE.hidden = false;
				nextStreetE.text = GPS.nextStreetName;
				destinationE.text = GPS.destinationName;

				if (GPS.nextStreetName == "You're off the path") {
					GPS.getRoute(currentStreet.label, GPS.destinationName);
				} else if (GPS.nextStreetName == "You have arrived") {
					arrowE.querySelector(".fa").classes
						..removeAll(["fa-arrow-up", "fa-check"])
						..add("fa-check");
					arrowE.style.transform = "rotate(0rad)";

					if (arriveFade || !currentStreet.loaded) {
						return;
					}

					arriveFade = true;
					new Timer(new Duration(seconds: 3), () {
						arriveFade = false;
						cancel();
					});
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

	void cancel() {
		if (GPS.active) {
			GPS.currentRoute.clear();
			GPS.active = false;
			transmit('gpsCancel', null);
			containerE.hidden = true;
			nextStreetE.text = destinationE.text = null;
			arrowE.style.transform = "";
			localStorage.remove("gps_navigating");
			new Timer(new Duration(seconds: 5), () {
				arrowE.querySelector(".fa").classes
					..add("fa-arrow-up")
					..remove("fa-check");
			});
		}
	}

	num calculateArrowDirection() {
		num exitX, exitY;
		num playerX = CurrentPlayer.left;
		num playerY = CurrentPlayer.top + CurrentPlayer.height / 2;

		for (Map exit in minimap.currentStreetExits) {
			if (exit["streets"].contains(GPS.nextStreetName)) {
				if (exit["streets"].length > 1) {
					// signs on both sides
					exitX = exit["x"] + 100;
				} else {
					exitX = exit["x"];
				}

				exitY = exit["y"] + 115; // center of the height
				break;
				// no point in wasting time, we found the signpost
			}
		};

		if (exitX == null || exitY == null) {
			// error
			return 0;
		}

		num dy = exitY - playerY;
		num dx = exitX - playerX;
		num theta = atan2(dy, dx) - 3 * pi / 2;
		return theta;
	}
}
