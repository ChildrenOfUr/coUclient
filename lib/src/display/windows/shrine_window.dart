part of couclient;

class ShrineWindow extends Modal {
	static ShrineWindow shrineWindow;
	String id = 'shrineWindow', giantName;
	int favor, maxFavor;
	String shrineId;

	factory ShrineWindow(String giantName, int favor, int maxFavor, String shrineId) {
		if(shrineWindow == null) {
			shrineWindow = new ShrineWindow._(giantName,favor,maxFavor, shrineId);
		}

		return shrineWindow;
	}

	ShrineWindow._(this.giantName,this.favor,this.maxFavor,this.shrineId) {
		prepare();

		List<Element> insertGiantName = querySelectorAll(".insert-giantname").toList();
		insertGiantName.forEach((placeholder) => placeholder.text = giantName);
		Element buttonHolder = querySelector('#shrine-window-buttons');
		Element confirmButton = querySelector('#shrine-window-confirm');
		Element cancelButton = querySelector('#shrine-window-cancel');
		DivElement dropTarget = querySelector("#DonateDropTarget");
		Map item = new Map();

		resetShrineWindow() {
			buttonHolder.style.visibility = 'hidden';
			dropTarget.style.backgroundImage = 'none';
			item.clear();
		}

		int percent = favor ~/ maxFavor;
		Map<String, String> progressAttributes = {
			"percent": percent.toString(),
			"status": favor.toString() + " of " + maxFavor.toString() + " favor towards a currant reward"
		};
		querySelector("#shrine-window-favor").attributes = progressAttributes;

		Draggable draggable = new Draggable(querySelectorAll(".inventoryItem"), avatarHandler: new CustomAvatarHandler());
		Dropzone dropzone = new Dropzone(dropTarget, acceptor: new Acceptor.draggables([draggable]));
		dropzone.onDrop.listen((DropzoneEvent dropEvent) {
			buttonHolder.style.visibility = 'visible';
			item = JSON.decode(dropEvent.draggableElement.attributes['itemMap']);
			dropTarget.style.backgroundImage = 'url(' + item['iconUrl'] + ')';
		});

		confirmButton.onClick.listen((_) {
			Map actionMap = {"itemName": item['name'], "num": 1};
			sendAction("donate", shrineId, actionMap);
			resetShrineWindow();
		});

		cancelButton.onClick.listen((_) {
			resetShrineWindow();
		});
	}
}