part of couclient;

class NoteWindow extends Modal {
	static final DateFormat DATEFORMAT = new DateFormat("'at' h:mm a 'on' EEE, MMM d, yyyy '(local time)'");

	static NoteWindow editing;

	String id;
	int noteId;
	Map<String, String> note = new Map();
	bool writeMode, isWriter, sendingData;

	Element displayElement;

	// Reading mode
	Element readParent;
	Element readEditBtn;
	Element readTitle;
	Element readBody;
	Element readDate;
	Element readUser;

	// Writing mode
	Element writeParent;
	Element writeSaveBtn;
	InputElement writeTitle;
	TextAreaElement writeBody;

	NoteWindow(this.noteId, [this.writeMode = false]) {
		void _setUpWindow([bool newNote = false]) {
			// Set up the window
			id = "notewindow-${WindowManager.randomId}";
			if (!newNote) {
				isWriter = (note["username"] == game.username);
			} else {
				isWriter = true;
			}
			displayElement = querySelector(".notewindow-template").clone(true);
			displayElement
				..classes.remove("notewindow-template")
				..id = id;

			querySelector("#windowHolder").append(displayElement);

			readParent = displayElement.querySelector(".notewindow-read");
			readEditBtn = displayElement.querySelector(".notewindow-read-editbtn");
			readTitle = displayElement.querySelector(".notewindow-read-title");
			readBody = displayElement.querySelector(".notewindow-read-body");
			readDate = displayElement.querySelector(".notewindow-read-footer-date");
			readUser = displayElement.querySelector(".notewindow-read-footer-username");

			writeParent = displayElement.querySelector(".notewindow-write");
			writeSaveBtn = displayElement.querySelector(".notewindow-write-btn");
			writeTitle = displayElement.querySelector(".notewindow-write-title");
			writeBody = displayElement.querySelector(".notewindow-write-body");

			prepare();

			if (writeMode) {
				EditMode_Enter();
				editing = this;
			} else {
				EditMode_Exit();
			}

			// Show the window
			displayElement.hidden = false;
			focus();
		}

		if (editing != null) {
			// Already editing a note, go to that one
			editing.focus();
		} else {
			// Creating a brand new note
			if (noteId == -1) {
				_setUpWindow(true);
			} else {
				// Reading an existing (we hope) note
				getNote().then((Map note) {
					if (note == null) {
						// Exit
						new Toast("That note doesn't exist");
					} else {
						this.note = note;
						_setUpWindow();
					}
				});
			}

			// Listen for the server's response to edits
			new Service("note_response", (Map response) {
				if (response["error"] == null) {
					note["id"] = response["id"];
					note["title"] = response["title"];
					note["body"] = response["body"];
					note["timestamp"] = response["timestamp"];
					EditMode_Exit();
				} else {
					if (elementOpen) {
						close();
						new Toast(response["error"]);
					}
				}
			});
		}
	}

	EditMode_Enter() {
		if (isWriter) {
			// Show the editor
			readParent.hidden = true;
			writeParent.hidden = false;

			// Set up close button
			writeSaveBtn.onClick.first.then((_) => setNote());

			// Insert preexisting values
			writeTitle.value = note["title"] ?? "A note!";
			writeBody.value = note["body"] ?? "";
		} else {
			new Toast("You cannot edit someone else's note");
		}
	}

	EditMode_Exit() {
		// Hide the editor
		writeParent.hidden = true;
		readParent.hidden = false;

		// Display values

		readTitle.text = note["title"];
		readBody.setInnerHtml(note["body"].replaceAll("\n", "<br>"), validator: Chat.VALIDATOR);
		readDate.text = getDateString(note["timestamp"]);

		// Handle user-specific content
		if (isWriter) {
			// You can only edit notes with Perpersonship
			Map penSkill = Skills.getSkill("penpersonship");
			readEditBtn.hidden = !(penSkill != null && penSkill["player_level"] == 1);

			readUser.text = "You";
			readEditBtn.onClick.first.then((_) => EditMode_Enter());
		} else {
			readEditBtn.hidden = true;
			readUser.setInnerHtml(
				'<a title="Open Profile" href="http://childrenofur.com/profile/?username=${note["username"]}" target="_blank">${note["username"]}</a>',
				validator: Chat.VALIDATOR);
		}

		editing = null;
	}

	Future<Map> getNote() async {
		// Download from server
		String json = await HttpRequest.getString("http://${Configs.utilServerAddress}/note/find/${noteId}");
		try {
			return JSON.decode(json);
		} catch (_) {
			return null;
		}
	}

	void setNote() {
		// Send the message to the server
		sendAction("writeNote", "global_action_monster", {"noteData": {
			"id": note["id"] ?? -1, // the server knows that -1 means a new note
			"username": game.username,
			"title": writeTitle.value,
			"body": writeBody.value
		}});

		// Response handled by service in constructor
	}

	String getDateString(String standardFormat) {
		DateTime date = DateTime.parse(standardFormat).toLocal();
		return DATEFORMAT.format(date);
	}

	@override
	close() {
		// Update WindowManager
		_destroyEscListener();
		displayElement.hidden = true;
		elementOpen = false;

		// See if there's another window that we want to focus
		for (Element modal in querySelectorAll('.window')) {
			if (!modal.hidden) {
				modals[modal.id].focus();
			}
		}

		// Delete the window element
		displayElement.remove();
		editing = null;
	}
}
