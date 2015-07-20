part of couclient;

class EmoticonPicker extends Modal {
	String id = 'emoticonPicker';
	Element window;
	String lastFocusedChannel;

	EmoticonPicker() {
		window = querySelector("#$id");
		Element well = window.querySelector("#emoticonPicker ur-well");
		InputElement search = well.querySelector("#ep-search");
		Element grid = well.querySelector("#ep-grid");

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
			});
		});

		new Service(["insertEmoji"], (_) => window.hidden = false);

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
}