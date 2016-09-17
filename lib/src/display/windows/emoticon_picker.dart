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

		emoji.main().then((_) {
			displayEmoticons(emoji.emoticons);
		});

		new Service(["insertEmoji"], (Map<String, dynamic> args) {
			target = args["input"];
			if ((args["title"] as String).toLowerCase().contains("chat")) {
				querySelector("#ep-channelname").text = args["title"];
			} else {
				querySelector("#ep-channelname").text = "chat with ${args["title"]}";
			}
			this.open();
		});

		search.onInput.listen((_) {
			displayEmoticons(emoji.search(search.value));
		});
	}

	void displayEmoticons(List<emoji.Emoticon> emoticons) {
		grid.children.clear();

		emoticons.forEach((emoji.Emoticon emoticon) {
			ImageElement emoticonImage = new ImageElement()
				..src = emoticon.imageUrl
				..classes.addAll(["emoticon"])
				..draggable = true;

			SpanElement emoticonButton = new SpanElement()
				..classes.add("ep-emoticonButton")
				..title = emoticon.name
				..dataset['emoticon-name'] = emoticon.name
				..append(emoticonImage);
			grid.append(emoticonButton);

			emoticonButton.onDragStart.listen((e) {
				e.stopPropagation();
				e.dataTransfer.effectAllowed = "copy";
				e.dataTransfer.setData("text/plain", ":${emoticon.shortname}:");
				e.dataTransfer.setDragImage(emoticonImage, emoticonImage.clientWidth ~/ 2, -10);
			});

			emoticonButton.onClick.listen((_) {
				target.value +=
				"${(
					target.value == "" || target.value.substring(target.value.length - 1) == " "
						? ""
						: " "
				)}:${emoticon.shortname}:";
			});
		});
	}

	@override
	open({bool ignoreKeys: false}) {
		displayElement.hidden = false;
		search.focus();
		elementOpen = true;
	}
}
