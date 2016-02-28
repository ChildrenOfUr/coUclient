part of couclient;

class ItemChooser {
	StreamSubscription keyboardListener;
	Function callback;

	ItemChooser(String title, this.callback, {String filter: 'name=*'}) {
		DivElement dialog = new DivElement()
			..id = 'itemChooser';

		DivElement titleE = new DivElement()
			..className = 'title'
			..text = title;

		dialog.append(titleE);

		DivElement itemHolder = new DivElement()
			..className = 'itemHolder';

		_addItems(playerInventory.slots, filter, itemHolder);

		dialog.append(itemHolder);

		keyboardListener = document.onKeyUp.listen((KeyboardEvent e) {
			if(e.keyCode == 27) {
				destroy();
			}
		});

		//append it to the game so that we get centered within it
		querySelector('#game').append(dialog);
	}

	_addItems(List<Slot> slots, filter, Element itemHolder) {
		List<String> addedTypes = [];
		List<String> filterData = filter.split('=');
		RegExp filterMatch = new RegExp(filterData[1], caseSensitive: false);

		for(Slot slot in slots) {
			ItemDef item = slot.item;
			if(item == null) {
				continue;
			}
			if(item.isContainer) {
				String slotsString = JSON.encode(item.metadata['slots']);
				List<Slot> bagSlots = decode(slotsString, type: new TypeHelper<List<Slot>>().type);
				_addItems(bagSlots, filter, itemHolder);
			}
			if(!filterMatch.hasMatch(JSON.decode(encode(item))[filterData[0]])) {
				continue;
			}

			addedTypes.add(item.itemType);

			DivElement itemE = new DivElement()
				..className = 'itemChoice'
				..style.backgroundImage = "url('${item.iconUrl}')";

			itemE.onClick.listen((MouseEvent e) {
				Function action = ({int howMany: 1}) {
					_doAction(item.itemType, howMany: howMany);
				};
				HowManyMenu.create(e,'',getNumItems(item.itemType), action, itemName: item.name);
			});

			itemHolder.append(itemE);
		}
	}

	_doAction(String itemType, {int howMany: 1}) {
		destroy();
		callback(itemType: itemType, count: howMany);
	}

	destroy() {
		keyboardListener?.cancel();
		querySelector('#itemChooser')?.remove();
	}
}