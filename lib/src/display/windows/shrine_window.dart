part of couclient;

class ShrineWindow extends Modal {
	static ShrineWindow shrineWindow;
	String id = 'shrineWindow',
		giantName;
	int favor, maxFavor;
	String shrineId;
	Element buttonHolder, confirmButton, cancelButton, dropTarget, favorProgress, numSelectorContainer, helpText;
	Map item;
	NumberInputElement numBox;
	Element QtyContainer, plusBtn, minusBtn, maxBtn;

	factory ShrineWindow(String giantName, int favor, int maxFavor, String shrineId) {
		if (shrineWindow == null) {
			shrineWindow = new ShrineWindow._(giantName, favor, maxFavor, shrineId);
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
	close() {
		sendAction("close", shrineId, {});
		super.close();
	}

	@override
	open() {
		resetShrineWindow();
		populateShrineWindow();
		makeDraggables();
		super.open();
	}

	void resetShrineWindow() {
		buttonHolder.style.visibility = 'hidden';
		dropTarget.style.backgroundImage = 'none';
		helpText.innerHtml = 'Drop an item here from your inventory to donate it to ' + giantName + ' for favor.';
		numSelectorContainer.hidden = true;
		item.clear();
	}

	void populateShrineWindow() {
		List<Element> insertGiantName = querySelectorAll(".insert-giantname").toList();
		insertGiantName.forEach((placeholder) => placeholder.text = giantName);

		int percent = 100 * favor ~/ maxFavor;
		_setFavorProgress(percent);
	}

	void populateQtySelector(String itemType) {
		numBox.attributes['max'] = getNumItems(itemType).toString();
		numBox.valueAsNumber = 1;
	}

	void makeDraggables() {
		Dropzone dropzone = new Dropzone(dropTarget);
		dropzone.onDrop.listen((DropzoneEvent dropEvent) {
			//verify it is a valid item before acting on it
			if (dropEvent.draggableElement.attributes['itemMap'] == null) {
				return;
			}

			buttonHolder.style.visibility = 'visible';
			item = JSON.decode(dropEvent.draggableElement.attributes['itemMap']);
			dropTarget.style.backgroundImage = 'url(' + item['iconUrl'] + ')';
			helpText.innerHtml = 'Donate how many?';

			numSelectorContainer.hidden = false;
			populateQtySelector(item['itemType']);
		});
	}

	void _setFavorProgress(int percent) {
		favorProgress..setAttribute('percent', percent.toString())..setAttribute(
			'status', "$favor of $maxFavor favor towards an Emblem of $giantName");
	}

	ShrineWindow._(this.giantName, this.favor, this.maxFavor, this.shrineId) {
		prepare();

		QtyContainer = displayElement.querySelector("#shrine-window-qty");
		plusBtn = displayElement.querySelector(".plus");
		minusBtn = displayElement.querySelector(".minus");
		maxBtn = displayElement.querySelector(".max");
		numBox = displayElement.querySelector(".NumToDonate");
		buttonHolder = querySelector('#shrine-window-buttons');
		confirmButton = querySelector('#shrine-window-confirm');
		cancelButton = querySelector('#shrine-window-cancel');
		dropTarget = querySelector("#DonateDropTarget");
		favorProgress = querySelector("#shrine-window-favor");
		numSelectorContainer = querySelector("#shrine-window-qty");
		helpText = querySelector("#DonateHelp");
		item = new Map();

		populateShrineWindow();

		new Service(['favorUpdate'], (favorMap) {
			favor = favorMap['favor'];
			maxFavor = favorMap['maxFavor'];
			int percent = 100 * favorMap['favor'] ~/ favorMap['maxFavor'];
			_setFavorProgress(percent);
		});

		confirmButton.onClick.listen((_) {
			Map actionMap = {"itemType": item['itemType'], "qty": numBox.valueAsNumber.toInt()};
			sendAction("donate", shrineId, actionMap);
			resetShrineWindow();
		});

		cancelButton.onClick.listen((_) {
			resetShrineWindow();
		});

		plusBtn.onClick.listen((_) {
			if (numBox.valueAsNumber + 1 > num.parse(numBox.max)) {
				numBox.valueAsNumber = num.parse(numBox.max);
			} else {
				numBox.valueAsNumber = numBox.valueAsNumber + 1;
			}
		});

		minusBtn.onClick.listen((_) {
			if (numBox.valueAsNumber - 1 < num.parse(numBox.min)) {
				numBox.valueAsNumber = num.parse(numBox.min);
			} else {
				numBox.valueAsNumber = numBox.valueAsNumber - 1;
			}
		});

		maxBtn.onClick.listen((_) {
			numBox.valueAsNumber = num.parse(numBox.max);
		});
	}
}