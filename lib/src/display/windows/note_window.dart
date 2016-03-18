part of couclient;

class NoteWindow extends Modal {
	String id;
	int noteId;
	bool writeMode, isWriter;
	Element displayElement;
	Map<String, String> note;
	StreamSubscription enterEditMode, exitEditMode;

	static final NodeValidatorBuilder HtmlValidator = new NodeValidatorBuilder.common()
		..allowElement("a", attributes: ["href"]);

	NoteWindow(this.noteId, [this.writeMode = false]) {
		// Get the note
		note = getNote();

		// Set up the window
		id = "notewindow-${WindowManager.randomId}";
		isWriter = (note["writer"] == game.username);
		displayElement = querySelector(".notewindow-template").clone(true);
		displayElement
			..classes.remove("notewindow-template")
			..id = id;

		if (writeMode) {
			EditMode_Enter();
		} else {
			EditMode_Exit();
		}

		// Show the window
		querySelector("#windowHolder").append(displayElement);
		prepare();
		displayElement.hidden = false;
	}

	EditMode_Enter() {
		if (isWriter) {
			// Show the editor
			displayElement
				..querySelector(".notewindow-read").hidden = true
				..querySelector(".notewindow-write").hidden = false;
			exitEditMode = displayElement
				.querySelector(".notewindow-write-btn")
				.onClick
				.listen((_) {
				EditMode_Exit();
				exitEditMode.cancel();
			});
			// Insert preexisting values
			(displayElement.querySelector(".notewindow-write-title") as TextInputElement).value = note["title"];
			(displayElement.querySelector(".notewindow-write-body") as TextAreaElement).value = note["body"];
		} else {
			new Toast("You cannot edit someone else's note");
		}
	}

	EditMode_Exit() {
		// Hide the editor
		displayElement
			..querySelector(".notewindow-read").hidden = false
			..querySelector(".notewindow-write").hidden = true;
		// Display values
		displayElement
			..querySelector(".notewindow-read-title").text = note["title"]
			..querySelector(".notewindow-read-body").setInnerHtml(
				note["body"].replaceAll("\n", "<br>"), validator: HtmlValidator)
			..querySelector(".notewindow-read-footer-date").text = note["date"];
		// Handle user-specific content
		if (isWriter) {
			displayElement
				..querySelector(".notewindow-read-editbtn").hidden = false
				..querySelector(".notewindow-read-footer-username").text = "You";
			enterEditMode = displayElement
				.querySelector(".notewindow-read-editbtn")
				.onClick
				.listen((_) {
				EditMode_Enter();
				enterEditMode.cancel();
			});
		} else {
			displayElement
				..querySelector(".notewindow-read-editbtn").hidden = true
				..querySelector(".notewindow-read-footer-username").setInnerHtml(
					'<a title="Open Profile" href="http://childrenofur.com/profile/?username=${note["writer"]}" target="_blank">${note["writer"]}</a>',
					validator: HtmlValidator);
		}
	}

	Map getNote() {
		//TODO: get from server

		Map<String, String> tempNote1 = {
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

		Map<String, String> tempNote2 = {
			"title": "Hey guys!",
			"body":
			"Just testing this note window thing.\n"
				"\n"
				"Notice how there's no icon? The icon I want is in FontAwesome 4.4, which the CDN hasn't updated to yet.",
			"writer": "Klikini",
			"date": "10:10AM, 19 August 2015"
		};

		return tempNote1;
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
	}
}