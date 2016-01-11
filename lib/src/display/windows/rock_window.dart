part of couclient;

class RockWindow extends Modal {
	String id = 'rockWindow';
	Element rescueButton = querySelector("#rock-rescue");
	StreamSubscription rescueClick;
	bool ready = false;

	/**
	 * Prepares a conversation for use. `convo` should not include rwc-,
	 * and userTriggered should be false if there is no UI button.
	 */
	void initConvo(String convo, {bool userTriggered: true}) {
		// Set up the menu button listener
		if (userTriggered) {
			querySelector("#go-" + convo).onClick.listen((_) {
				switchContent("rwc-" + convo);
			});
		}

		// Hide all but the first screen
		querySelectorAll("#rwc-" + convo + " > div").forEach((Element el) => el.hidden = true);
		querySelector("#rwc-" + convo + "-1").hidden = false;

		// Handle screen navigation
		querySelectorAll("#rwc-" + convo + " .rwc-button").onClick.listen((e) {
			String id = e.target.dataset["goto"];
			if (id == querySelector("#rwc-" + convo).dataset["endphrase"]) {
				// Last screen, close and return to the menu
				super.close();
				switchContent("rwc");
				querySelectorAll("#rwc-" + convo + " > div").forEach((Element el) => el.hidden = true);
				querySelector("#rwc-" + convo + "-1").hidden = false;
			} else {
				// Go to the next screen
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
	 * Set up the Services that trigger conversations...
	 */
	void setConvoTriggers() {
		/// On death
		new Service(["dead"], (bool dying) {
			// Prevent the screen appearing on every Hell street
			bool deathConvoDone = false, reviveConvoDone = false;
			new Service(["streetLoaded"], (_) {
				if (dying && !deathConvoDone) {
					// Start death talk
					switchContent("rwc-dead");
					open();
					// Disable inventory
					querySelector("#inventory /deep/ #disableinventory").hidden = false;
					// Save state
					deathConvoDone = true;
				}
				if (!dying && !reviveConvoDone){
					// Start revival talk
					switchContent("rwc-revive");
					open();
					// Enable inventory
					querySelector("#inventory /deep/ #disableinventory").hidden = true;
					// Save state
					reviveConvoDone = true;
				}
			});
		});

		/// When entering a broken street
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

		// Triggered by incoming message from server
		initConvo("dead", userTriggered: false);
		initConvo("revive", userTriggered: false);

		// Triggered by going to a known problematic street
		initConvo("badstreet", userTriggered: false);
	}

	/**
	 * Use this method to create a conversation dynamically
	 * After calling this method the conversation html will be added to the page
	 * and you should call switchContent(id) followed by open() on the rockwindow
	 * to display the conversation
	 */
	void createConvo(Conversation convo) {
		DivElement conversation = new DivElement()
			..className = 'rockWindowContent convo'
			..id = 'rwc-${convo.id}'
			..dataset['endphrase'] = (convo.screens.length + 1).toString()
			..hidden = true;

		for (int i=1; i<=convo.screens.length; i++) {
			ConvoScreen screen = convo.screens.elementAt(i-1);
			DivElement screenE = new DivElement()..id = 'rwc-${convo.id}-$i';

			for (String paragraph in screen.paragraphs) {
				ParagraphElement paragraphE = new ParagraphElement()..text = paragraph;
				screenE.append(paragraphE);
			}

			//up to 2 choices per row
			List<ConvoChoice> choices = new List.from(screen.choices);
			while (choices.isNotEmpty) {
				DivElement choiceRow = new DivElement()..className = 'flex-row rwc-exit';

				choiceRow.append(_createChoice(choices.removeAt(0), convo.id.split('-')[0]));

				if(choices.isNotEmpty) {
					choiceRow.append(_createChoice(choices.removeAt(0), convo.id.split('-')[0]));
				}

				screenE.append(choiceRow);
			}

			conversation.append(screenE);
		}

		querySelector('#rwc-holder').append(conversation);
		initConvo(convo.id, userTriggered: false);
	}

	AnchorElement _createChoice(ConvoChoice choice, String questId) {
		AnchorElement choiceE = new AnchorElement()
			..className = 'rwc-button'
			..dataset['goto'] = '${choice.gotoScreen}'
			..text = choice.text;

		if(choice.isQuestAccept) {
			_createChoiceListener(choiceE, 'acceptQuest', questId);
		}
		if(choice.isQuestReject) {
			_createChoiceListener(choiceE, 'rejectQuest', questId);
		}

		return choiceE;
	}

	_createChoiceListener(Element choiceE, String type, String questId) {
		choiceE.onClick.first.then((_) {
			Map map = {
				type: 'true',
				'email': game.email,
				'id': questId
			};
			QuestManager.socket.send(JSON.encode(map));
		});
	}

	RockWindow() {
		prepare();

		// Lock/unlock inventory on game load
		new Service(["gameLoaded"], (_) {
			if (metabolics.energy == 0) {
				querySelector("#inventory /deep/ #disableinventory").hidden = false;
			} else {
				querySelector("#inventory /deep/ #disableinventory").hidden = true;
			}
		});

		// Toggle window by clicking rock
		setupUiButton(querySelector("#petrock"));

		try {
			// Define conversations
			initConvos();
			// Trigger conversations
			setConvoTriggers();
		} catch(e) {
			logmessage("[UI] Could not load rock convos");
		}

		ready = true;
		transmit("rockwindowready", ready);
	}
}

class Conversation {
	String id, title;
	List<ConvoScreen> screens;
}

class ConvoScreen {
	List<String> paragraphs;
	List<ConvoChoice> choices;
}

class ConvoChoice {
	String text;
	int gotoScreen;
	bool isQuestAccept = false, isQuestReject = false;
}