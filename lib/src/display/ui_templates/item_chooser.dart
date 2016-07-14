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

	_addItems(List<Slot> slots, filter, Element itemHolder, [int superSlotIndex]) {
		List<String> addedTypes = [];

		for(int slotIndex = 0; slotIndex < slots.length; slotIndex++) {
			Slot slot = slots[slotIndex];
			ItemDef item = slot.item;
			if(item == null) {
				continue;
			}
			if(item.isContainer) {
				String slotsString = item.metadata['slots'];
				List<Slot> bagSlots = decode(slotsString, type: new TypeHelper<List<Slot>>().type);
				_addItems(bagSlots, filter, itemHolder, slotIndex);
			}

			bool noMatch = false;
			for (String filter in filter.split('|||')) {
				List<String> filterData = filter.split('=');
				RegExp filterMatch = new RegExp(filterData[1], caseSensitive: false);
				if(!filterMatch.hasMatch(JSON.decode(encode(item))[filterData[0]].toString())) {
					noMatch = true;
					break;
				}
			}
			if(noMatch) {
				continue;
			}

			addedTypes.add(item.itemType);

			DivElement itemE = new DivElement()
				..className = 'itemChoice'
				..style.backgroundImage = "url('${item.iconUrl}')"
				..title = item.metadata["title"] ?? item.name;

			itemE.onClick.listen((MouseEvent e) {
				Function action = ({int howMany: 1}) {
					int realSlotIndex = superSlotIndex ?? slotIndex;
					int realSubSlotIndex = (superSlotIndex != null ? slotIndex : -1);
					_doAction(item.itemType, realSlotIndex, realSubSlotIndex, howMany: howMany);
				};
				HowManyMenu.create(e,'',_getNumItems(item.itemType), action, itemName: item.name);
			});

			itemHolder.append(itemE);
		}
	}

	_doAction(String itemType, int slot, int subSlot, {int howMany: 1}) {
		destroy();
		//print("slot $slot, subslot $subSlot");
		callback(itemType: itemType, count: howMany, slot: slot, subSlot: subSlot);
	}

	destroy() {
		keyboardListener?.cancel();
		querySelector('#itemChooser')?.remove();
	}
}
