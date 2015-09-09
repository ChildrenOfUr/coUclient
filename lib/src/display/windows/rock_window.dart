part of couclient;

class RockWindow extends Modal {
	String id = 'rockWindow';
	Element rescueButton;
	StreamSubscription rescueClick;
	bool ready = false;

	/**
	 * Prepares a conversation for use. `convo` should not include rwc-,
	 * and userTriggered should be false if there is no UI button.
	 */
	void initConvo(String convo, {bool userTriggered: true}) {
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
				super.close();
				switchContent("rwc");
				querySelectorAll("#rwc-" + convo + " > div").forEach((Element el) => el.hidden = true);
				querySelector("#rwc-" + convo + "-1").hidden = false;
			} else {
				querySelectorAll("#rwc-" + convo + " > div").forEach((Element el) => el.hidden = true);
				querySelector("#rwc-" + convo + "-" + id).hidden = false;
			}
		});
	}

	/**
	 * Switches the window to the given id (should include rwc-),
	 * but does NOT open the rock window (use open(); afterward)
	 */
	void switchContent(String id) {
		if (!ready) {
			new Service(["rockwindowready"], (_) {
				querySelectorAll("#rwc-holder .rockWindowContent").forEach((Element el) => el.hidden = true);
				querySelector("#" + id).hidden = false;
			});
		} else {
			querySelectorAll("#rwc-holder .rockWindowContent").forEach((Element el) => el.hidden = true);
			querySelector("#" + id).hidden = false;
		}
	}

	/**
	 * Set up the Services that trigger conversations
	 */
	void setConvoTriggers() {
		// On death
		new Service(["dead"], (bool dying) {
			new Service(["streetLoaded"], (_) {
				if (dying) {
					// Start death talk
					switchContent("rwc-dead");
					open();
					// Disable inventory
					querySelector("#inventory /deep/ #disableinventory").hidden = false;
				} else {
					// Start revival talk
					switchContent("rwc-revive");
					open();
					// Enable inventory
					querySelector("#inventory /deep/ #disableinventory").hidden = true;
				}
			});
		});

		// Rescue from bad street
		new Service(['streetLoaded'], (_) {
			if (mapData.streetData[currentStreet.label] != null && mapData.streetData[currentStreet.label]["broken"] == true) {
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

	/**
	 * Set up the conversations
	 */
	void initConvos() {
		// Triggered by user clicking menu options
		initConvo("start");
		initConvo("motd");

		// Triggered by incoming message from server (user dying)
		initConvo("dead", userTriggered: false);
		initConvo("revive", userTriggered: false);

		// Triggered by going to a known problem street
		initConvo("badstreet", userTriggered: false);
	}

	RockWindow() {
		prepare();

		// Toggle window by clicking rock
		setupUiButton(querySelector("#petrock"));

		try {
			// Define conversations
			initConvos();
			// Trigger conversations
			setConvoTriggers();
		} catch(e) {
			logmessage("[UI] Could not load rock convos!");
		}

		ready = true;
		transmit("rockwindowready", ready);
	}
}