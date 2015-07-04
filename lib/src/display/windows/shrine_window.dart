part of couclient;

class ShrineWindow extends Modal {
	static ShrineWindow shrineWindow;
	String id = 'shrineWindow', giantName;
	int favor, maxFavor;
	String shrineId;
	Element buttonHolder, confirmButton, cancelButton, dropTarget, favorProgress, numSelectorContainer, helpText;
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
    helpText.innerHtml = 'Drop an item here from your inventory to donate it to ' + giantName +' for favor.';
    numSelectorContainer.hidden = true;
		item.clear();
	}

	void populateShrineWindow() {
		List<Element> insertGiantName = querySelectorAll(".insert-giantname").toList();
		insertGiantName.forEach((placeholder) => placeholder.text = giantName);

		int percent = (favor ~/ maxFavor) * 100;
		Map<String, String> progressAttributes = {
			'id': 'shrine-window-favor',
			"percent": percent.toString(),
			"status": favor.toString() + " of " + maxFavor.toString() + " favor towards an Emblem of " + giantName
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
    numSelectorContainer = querySelector("#shrine-window-qty");
    helpText = querySelector("#DonateHelp");
		item = new Map();

		populateShrineWindow();

		Draggable draggable = new Draggable(querySelectorAll(".inventoryItem"), avatarHandler: new CustomAvatarHandler());
		Dropzone dropzone = new Dropzone(dropTarget, acceptor: new Acceptor.draggables([draggable]));
		dropzone.onDrop.listen((DropzoneEvent dropEvent) {
			buttonHolder.style.visibility = 'visible';
			item = JSON.decode(dropEvent.draggableElement.attributes['itemMap']);
			dropTarget.style.backgroundImage = 'url(' + item['iconUrl'] + ')';
      helpText.innerHtml = 'Donate how many?';
      numSelectorContainer.hidden = false;
		});

		confirmButton.onClick.listen((_) {
			Map actionMap = {"itemType": item['itemType'], "num": 1};
			sendAction("donate", shrineId, actionMap);
			resetShrineWindow();

      // TODO: I was trying to auto-update the favor bar
      /// The server is running this after donation:
      ///    Map addedFavorMap = {};
      ///    map['donateComplete'] = true;
      ///    map['addedFavor'] = favAmt;
      ///    userSocket.add(JSON.encode(addedFavorMap));
      StreamSubscription waitForNewFavor;
      waitForNewFavor = streetSocket.onMessage.listen((e) {
        if ((JSON.decode(e.data.toString()) as Map)['donateComplete'] == true) {
          print(e.data.toString());
          favorProgress.attributes['percent'] += JSON.decode(e.data.toString())[''];
          waitForNewFavor.cancel();
        }
      });
      /// end my broken code
		});

		cancelButton.onClick.listen((_) {
			resetShrineWindow();
		});
	}
}