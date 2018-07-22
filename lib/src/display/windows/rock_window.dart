part of couclient;

class RockWindow extends Modal {
	String id = 'rockWindow';
	Element rescueButton = querySelector("#rock-rescue");
	Element questsButton = querySelector("#open-quests")..onClick.listen((_) => windowManager.rockWindow.close());
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
			String id = (e.target as Element).dataset["goto"];
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
				querySelector("#rwc-" + convo).scrollTop = 0;
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
			bool deathConvoDone = false,
				reviveConvoDone = false;
			new Service(["streetLoaded"], (_) {
				if (dying && !deathConvoDone) {
					// Start death talk
					switchContent("rwc-dead");
					open();
					// Disable inventory
					_setInventoryEnabled(false);
					// Save state
					deathConvoDone = true;
				}
				if (!dying && !reviveConvoDone) {
					// Start revival talk
					switchContent("rwc-revive");
					open();
					// Enable inventory
					_setInventoryEnabled(true);
					// Save state
					reviveConvoDone = true;
				}
			});
		});

		/// When entering a broken street
		new Service(['streetLoaded'], (_) {
			if (
				// Check hub level
				(mapData.hubData[currentStreet.hub_id] != null &&
				mapData.hubData[currentStreet.hub_id]['broken'] == true)
				// Check street level
				|| (mapData.streetData[currentStreet.label] != null &&
			    mapData.streetData[currentStreet.label]['broken'] == true)
			) {
				switchContent("rwc-badstreet");
				open();
				rescueButton.hidden = false;
				rescueClick = rescueButton.onClick.listen((_) {
					if (currentStreet.hub_id == "40" /* Naraka */) {
						// Dead => Hell One
						streetService.requestStreet("LA5PPFP86NF2FOS");
					} else {
						// Not dead => Ilmenskie
						streetService.requestStreet("LIF102FDNU11314");
					}
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

	void _setInventoryEnabled(bool enabled) {
		querySelector("#inventory #disableinventory").hidden = enabled;
		if(!enabled) {
			//close all bag windows
			List<String> openIds = [];
			BagWindow.openWindows.forEach((BagWindow w) => openIds.add(w.id));
			openIds.forEach((String id) => BagWindow.closeId(id));
		}
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
	void createConvo(Conversation convo, {QuestRewards rewards}) {
		//remove the conversation if it already exists
		if (querySelector('#rwc-${convo.id}') != null) {
			querySelector('#rwc-${convo.id}').remove();
		}

		DivElement conversation = new DivElement()
			..className = 'rockWindowContent convo'
			..id = 'rwc-${convo.id}'
			..dataset['endphrase'] = (convo.screens.length + 1).toString()
			..hidden = true;

		for (int i = 1; i <= convo.screens.length; i++) {
			ConvoScreen screen = convo.screens.elementAt(i - 1);
			DivElement screenE = new DivElement()
				..id = 'rwc-${convo.id}-$i';

			for (String paragraph in screen.paragraphs) {
				ParagraphElement paragraphE = new ParagraphElement()
					..text = paragraph;
				screenE.append(paragraphE);
			}

			//up to 2 choices per row
			List<ConvoChoice> choices = new List.from(screen.choices);
			while (choices.isNotEmpty) {
				DivElement choiceRow = new DivElement()
					..className = 'flex-row rwc-exit';

				choiceRow.append(_createChoice(choices.removeAt(0), convo.id.split('-')[0]));

				if (choices.isNotEmpty) {
					choiceRow.append(_createChoice(choices.removeAt(0), convo.id.split('-')[0]));
				}

				screenE.append(choiceRow);
			}

			if (i == convo.screens.length && rewards != null) {
				screenE.append(_createRewards(rewards));
			}

			conversation.append(screenE);
		}

		querySelector('#rwc-holder').append(conversation);
		initConvo(convo.id, userTriggered: false);
	}

	DivElement _createRewards(QuestRewards rewards) {
		DivElement awardsE = new DivElement()
			..className = 'awarded';
		if (rewards.energy != 0) {
			SpanElement energyE = new SpanElement()
				..className = 'energy'
				..text = '+${rewards.energy}';
			awardsE.append(energyE);
		}
		if (rewards.mood != 0) {
			SpanElement moodE = new SpanElement()
				..className = 'mood'
				..text = '+${rewards.mood}';
			awardsE.append(moodE);
		}
		if (rewards.img != 0) {
			SpanElement imgE = new SpanElement()
				..className = 'img'
				..text = '+${rewards.img}';
			awardsE.append(imgE);
		}
		if (rewards.currants != 0) {
			SpanElement currantsE = new SpanElement()
				..className = 'currants'
				..text = '+${rewards.currants}';
			awardsE.append(currantsE);
		}

		DivElement cbContent = new DivElement()..className = 'cb-content';
		cbContent.append(awardsE);
		return cbContent;
	}

	AnchorElement _createChoice(ConvoChoice choice, String questId) {
		AnchorElement choiceE = new AnchorElement()
			..className = 'rwc-button'
			..dataset['goto'] = '${choice.gotoScreen}'
			..text = choice.text;

		if (choice.isQuestAccept) {
			_createChoiceListener(choiceE, 'acceptQuest', questId);
		}
		if (choice.isQuestReject) {
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
			transmit('questChoice', map);
		});
	}

	RockWindow() {
		prepare();

		// Lock/unlock inventory on game load
		new Service(["gameLoaded"], (_) => _setInventoryEnabled(metabolics.energy != 0));

		// Toggle window by clicking rock
		setupUiButton(querySelector("#petrock"));

		// hehehe
		querySelector("#petrock")
		    ..onMouseEnter.listen((MouseEvent event) {
				if (event.altKey) {
					querySelector("#petrock").classes.add("questlog");
				}
			})
			..onMouseLeave.listen((MouseEvent event) {
				querySelector("#petrock").classes.remove("questlog");
			})
		;

		try {
			// Define conversations
			initConvos();
			// Trigger conversations
			setConvoTriggers();
		} catch (e) {
			logmessage("[UI] Could not load rock convos");
		}

		ready = true;
		transmit("rockwindowready", ready);
	}
}

@JsonSerializable()
class Conversation {
	String id;
	List<ConvoScreen> screens;

	Conversation();
	factory Conversation.fromJson(Map<String, dynamic> json) => _$ConversationFromJson(json);
}

@JsonSerializable()
class ConvoScreen {
	List<String> paragraphs;
	List<ConvoChoice> choices;

	ConvoScreen();
	factory ConvoScreen.fromJson(Map<String, dynamic> json) => _$ConvoScreenFromJson(json);
}

@JsonSerializable()
class ConvoChoice {
	String text;
	int gotoScreen;
	bool isQuestAccept = false,
		isQuestReject = false;

	ConvoChoice();
	factory ConvoChoice.fromJson(Map<String, dynamic> json) => _$ConvoChoiceFromJson(json);
}
