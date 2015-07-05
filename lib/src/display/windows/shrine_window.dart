part of couclient;

class ShrineWindow extends Modal {
	static ShrineWindow shrineWindow;
	String id = 'shrineWindow', giantName;
	int favor, maxFavor;
	String shrineId;
	Element buttonHolder, confirmButton, cancelButton, dropTarget, favorProgress;
	Map item;

	factory ShrineWindow(String giantName, int favor, int maxFavor, String shrineId) {
		if(shrineWindow == null) {
			shrineWindow = new ShrineWindow._(giantName,favor,maxFavor, shrineId);
		} else {
			shrineWindow
				..giantName = giantName
				..favor = favor
				..maxFavor = maxFavor
				..shrineId = shrineId;
		}

		return shrineWindow;
	}

	@override
	open() {
		resetShrineWindow();
		populateShrineWindow();
		super.open();
	}

	void resetShrineWindow() {
		buttonHolder.style.visibility = 'hidden';
		dropTarget.style.backgroundImage = 'none';
		item.clear();
	}

	void populateShrineWindow() {
		List<Element> insertGiantName = querySelectorAll(".insert-giantname").toList();
		insertGiantName.forEach((placeholder) => placeholder.text = giantName);

		int percent = favor ~/ maxFavor;
		_setFavorProgress(percent);
	}

	void _setFavorProgress(int percent) {
		Map<String, String> progressAttributes = {
			'id': 'shrine-window-favor',
			"percent": percent.toString(),
			"status": favor.toString() + " of " + maxFavor.toString() + " favor towards a currant reward"
		};
		favorProgress.attributes = progressAttributes;
	}

	ShrineWindow._(this.giantName,this.favor,this.maxFavor,this.shrineId) {
		prepare();

		buttonHolder = querySelector('#shrine-window-buttons');
		confirmButton = querySelector('#shrine-window-confirm');
		cancelButton = querySelector('#shrine-window-cancel');
		dropTarget = querySelector("#DonateDropTarget");
		favorProgress = querySelector("#shrine-window-favor");
		item = new Map();

		populateShrineWindow();

		new Service(['metabolicsUpdated'],(metabolics) => _setFavorProgress(metabolics.favor ~/ metabolics.maxFavor));

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