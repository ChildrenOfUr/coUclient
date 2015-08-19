part of couclient;

class NoteWindow extends Modal {
	String id;
	int noteId;
	bool writeMode, newNote, isWriter;
	Element displayElement;
	Map<String, String> note;

	NoteWindow(this.noteId, [this.writeMode = false, this.newNote = false]) {
		// Get the note
		getNote().then((Map noteMap) {
			note = noteMap;

			// Set up window settings
			new Service(["gameLoaded"], (_) {
				id = "notewindow-${WindowManager.randomId}";
				isWriter = (note["writer"] == game.username);

				// Get the elements
				displayElement = querySelector(".notewindow-template").clone(true);

				// Set the content
				displayElement
					..classes.remove("notewindow-template")
					..id = id
					..querySelectorAll(".notewindow-save").onClick.listen((_) => EditMode_Exit())
					..querySelector(".notewindow-read-title").text = note["title"]
					..querySelector(".notewindow-read-body").setInnerHtml(note["body"].replaceAll("\n", "<br>"))
					..querySelector(".notewindow-read-footer-date").text = note["date"];

				// Handle user-specific content
				if (isWriter) {
					displayElement
						..querySelector(".notewindow-openeditorbtn").hidden = false
						..querySelector(".notewindow-read-footer-username").text = "You";
				} else {
					displayElement
						..querySelector(".notewindow-read-editbtn").hidden = false
						..querySelector(".notewindow-read-footer-username").text = note["writer"];
				}

				// Show the window
				querySelector("#windowHolder").append(displayElement);
				EditMode_Exit();
				prepare();
				displayElement.hidden = false;
			});
		});
	}

	EditMode_Enter() {
		if (isWriter) {
			displayElement.querySelector(".notewindow-read").hidden = true;
			if (newNote) {
				displayElement.querySelector(".notewindow-write").hidden = false;
			} else {
				displayElement.querySelector(".notewindow-edit").hidden = false;
			}
		}
	}

	EditMode_Exit() {
		displayElement
			..querySelector(".notewindow-read").hidden = false
			..querySelector(".notewindow-edit").hidden = true
			..querySelector(".notewindow-write").hidden = true;
	}

	Future<Map> getNote() async {
		//TODO: get from server

		Map<String, String> tempNote = {
			"title": "Urgent Message!",
			"body":
				"Dear Fellow Glitches,\n"
				"\n"
				"This is an urgent notice pertaining to a\n"
				"natrual gas leak from the gas plants\n"
				"that has been recently detected. Please calmly\n"
				"evacuate the street and beware of large\n"
				"concentrations of Heavy Gas. If you feel light headed,\n"
				"heavy, or have uncontrollable fits of laughter, please\n"
				"visit the nearest poision control center.\n"
				"\n"
				"We are doing our best to assess the situation. Until\n"
				"then, please do not inhale too deeply.\n"
				"\n"
				"-- Sandbox Gas and Electric",
			"writer": "RedDyeNo.5",
			"date": "1:16AM, 26 October 2011"
		};

		return tempNote;
	}

	Future<bool> writeNote(String title, String body) async {
		//TODO: send to server

		if (newNote) {

		}

		// Mark that the server knows this note exists
		newNote = false;
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

		// Delete the element
		displayElement.remove();
	}
}