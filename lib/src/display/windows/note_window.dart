part of couclient;

class NoteWindow extends Modal {
	String id;
	int noteId;
	bool writeMode, isWriter;
	Element displayElement;
	Map<String, String> note;
	StreamSubscription enterEditMode, exitEditMode;

	NoteWindow(this.noteId, [this.writeMode = false]) {
		// Get the note
		getNote().then((Map note) {
			if (note == null) {
				// Exit
				new Toast("That note doesn't exist");
			} else {
				this.note = note;

				// Set up the window
				id = "notewindow-${WindowManager.randomId}";
				isWriter = (note["username"] == game.username);
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
		});
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
		DateTime date = DateTime.parse(note["date"]).toLocal();
		String dateString = "${date.hour}:${date.minute}, ${date.day}/${date.month}/${date.year}";
		displayElement
			..querySelector(".notewindow-read-title").text = note["title"]
			..querySelector(".notewindow-read-body").setInnerHtml(note["body"].replaceAll("\n", "<br>"), validator: Chat.VALIDATOR)
			..querySelector(".notewindow-read-footer-date").text = dateString;
		// Handle user-specific content
		if (isWriter) {
			displayElement
				..querySelector(".notewindow-read-editbtn").hidden = false
				..querySelector(".notewindow-read-footer-username").text = "You";
			enterEditMode = displayElement.querySelector(".notewindow-read-editbtn").onClick.listen((_) {
					EditMode_Enter();
					enterEditMode.cancel();
			});
		} else {
			displayElement
				..querySelector(".notewindow-read-editbtn").hidden = true
				..querySelector(".notewindow-read-footer-username").setInnerHtml(
					'<a title="Open Profile" href="http://childrenofur.com/profile/?username=${note["writer"]}" target="_blank">${note["writer"]}</a>',
					validator: Chat.VALIDATOR);
		}
		setNote();
	}

	Future<Map> getNote() async {
		String json = await HttpRequest.getString("http://${Configs.utilServerAddress}/note/find/$id");
		try {
			return JSON.decode(json);
		} catch (_) {
			return null;
		}
	}

	Future<Map> setNote() async {
		// TODO: send to server (not like this, probably)
		/*String json = (await HttpRequest.request("http://${Configs.utilServerAddress}/note/add",
			method: "POST",
			requestHeaders: {"Content-Type": "application/json"},
			sendData: {
				"username": game.username,
				"title": (displayElement.querySelector(".notewindow-write-title") as TextInputElement).value,
				"body": (displayElement.querySelector(".notewindow-write-body") as TextInputElement).value
			}
		)).responseText;*/
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
