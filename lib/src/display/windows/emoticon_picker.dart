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

    new Asset("packages/coUemoticons/emoticons.json").load().then((Asset asset) {
      EMOTICONS = asset.get()["names"];

      EMOTICONS.forEach((String emoticon) {
        Element emoticonImage = new Element.tag("i")
          ..classes.addAll(["emoticon", "emoticon-md", emoticon])
          ..draggable = true;

        SpanElement emoticonButton = new SpanElement()
          ..classes.add("ep-emoticonButton")
          ..title = emoticon
          ..append(emoticonImage);
        grid.append(emoticonButton);

        emoticonButton.onDragStart.listen((e) {
          e.stopPropagation();
          e.dataTransfer.effectAllowed = "copy";
          e.dataTransfer.setData("text/plain", ":$emoticon:");
          e.dataTransfer.setDragImage(emoticonImage, emoticonImage.clientWidth ~/ 2, -10);
        });

        emoticonButton.onClick.listen((_) {
          target.value +=
            "${(
              target.value == "" || target.value.substring(target.value.length - 1) == " "
              ? ""
              : " "
            )}::$emoticon::";
        });
      });
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
