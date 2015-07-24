part of couclient;

class EmoticonPicker extends Modal {
	String id = 'emoticonPicker';
	Element window, well, grid;
	InputElement search;
	InputElement target;

	EmoticonPicker() {
		window = querySelector("#$id");
		well = window.querySelector("#emoticonPicker ur-well");
		search = well.querySelector("#ep-search");
		grid = well.querySelector("#ep-grid");

		prepare();

		new Asset("files/emoticons/emoticons.json").load().then((Asset asset) {
			EMOTICONS = asset.get()["names"];

			EMOTICONS.forEach((String emoticon) {
				SpanElement emoticonButton = new SpanElement()
					..classes.add("ep-emoticonButton")
					..title = emoticon
					..draggable = true
					..style.backgroundImage = "url(files/emoticons/$emoticon.svg)";
				grid.append(emoticonButton);

				emoticonButton.onDragStart.listen((e) {
					e.stopPropagation();
					e.dataTransfer.effectAllowed = "copy";
					e.dataTransfer.setData("text/plain", ":$emoticon:");
					e.dataTransfer.setDragImage(emoticonButton, emoticonButton.clientWidth ~/ 2, -10);
				});

				emoticonButton.onClick.listen((_) {
					if (target.value == "" || target.value.substring(target.value.length - 1) == " ") {
						target.value += ":$emoticon:";
					} else {
						target.value += " :$emoticon:";
					}
				});
			});
		});

		new Service(["insertEmoji"], (Map<String, dynamic> args) {
			target = args["input"];
			querySelector("#ep-channelname").text = args["title"];
			this.open();
		});

		search.onInput.listen((_) {
			grid.querySelectorAll(".ep-emoticonButton").forEach((Element button) {
				if (button.title.contains(search.value)) {
					button.hidden = false;
				} else {
					button.hidden = true;
				}
			});
		});
	}

	@override
	open() {
		displayElement.hidden = false;
		search.focus();
		elementOpen = true;
	}
}