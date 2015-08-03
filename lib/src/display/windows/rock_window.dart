part of couclient;

class RockWindow extends Modal {
	String id = 'rockWindow';
	Element rescueButton;
	StreamSubscription rescueClick;

	RockWindow() {
		prepare();

		// Rescue function
		rescueButton = querySelector("#rock-rescue")
			..hidden = true;

		// Toggle window by clicking rock
		setupUiButton(querySelector("#petrock"));

		// Open given conversation ////////////////////////////////////////////////////////////////////

		switchContent(String id) {
			querySelectorAll("#rwc-holder .rockWindowContent").forEach((Element el) => el.hidden = true);
			querySelector("#" + id).hidden = false;
		}

		// Set up conversations ///////////////////////////////////////////////////////////////////////

		initConvo(String convo, {bool userTriggered: true}) {
			if (userTriggered) {
				querySelector("#go-" + convo).onClick.listen((_) {
					querySelectorAll("#rwc-" + convo + " > div").forEach((Element el) => el.hidden = true);
					querySelector("#rwc-" + convo + "-1").hidden = false;
					switchContent("rwc-" + convo);
				});
			}

			querySelectorAll("#rwc-" + convo + " .rwc-button").onClick.listen((e) {
				String id = e.target.dataset["goto"];
				if (id == querySelector("#rwc-" + convo).dataset["endphrase"]) {
					switchContent("rwc");
					super.close();
					querySelectorAll("#rwc-" + convo + " > div").forEach((Element el) => el.hidden = true);
					querySelector("#rwc-" + convo + "-1").hidden = false;
				} else {
					querySelectorAll("#rwc-" + convo + " > div").forEach((Element el) => el.hidden = true);
					querySelector("#rwc-" + convo + "-" + id).hidden = false;
				}
			});
		}

		// Define conversations ///////////////////////////////////////////////////////////////////////

		// Triggered by user clicking menu options
		initConvo("start");
		initConvo("motd");

		// Triggered by incoming message from server (user dying)
		initConvo("dead", userTriggered: false);

		// Triggered by going to a known problem street
		initConvo("badstreet", userTriggered: false);

		// Trigger conversations //////////////////////////////////////////////////////////////////////

		// On death
		new Service(["dead"], (String value) {
			if (value == "true") {
				// Start conversation
				switchContent("rwc-dead");
				open();
				// Disable inventory
				querySelector("#inventory /deep/ #disableinventory").hidden = false;
			}
		});

		// Rescue from bad street
		new Service(['streetLoaded'], (_) {
			if (streetMetadata[currentStreet.label] != null && streetMetadata[currentStreet.label]["broken"] == true) {
				switchContent("rwc-badstreet");
				open();
				rescueButton.hidden = false;
				rescueClick = rescueButton.onClick.listen((_) {
					streetService.requestStreet(/*Ilmenskie*/"LIF102FDNU11314");
					close();
				});
			} else {
				rescueButton.hidden = true;
				if (rescueClick != null) {
					rescueClick.cancel();
				}
			}
		});
	}
}