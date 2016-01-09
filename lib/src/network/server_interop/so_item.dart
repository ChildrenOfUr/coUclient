part of couclient;

///slot should be in the format 'barSlot.bagSlot' indexed from 0
///if bagSlot is not relevant, please use 'barSlot.-1'
itemContextMenu(ItemDef i, String slot, MouseEvent event) {
	event.preventDefault();
	event.stopPropagation();

	int barSlot = int.parse(slot.split('.').elementAt(0));
	int bagSlot = int.parse(slot.split('.').elementAt(1));
	List<List> actions = [];

	if (i.actions != null) {
		List<Action> actionsList = i.actions;
		bool enabled = false;
		actionsList.forEach((Action action) {
			String error = "";
			List<Map> requires = [];
			action.itemRequirements.all.forEach((String item, int num) => requires.add({'num':num, 'of':[item]}));
			if (action.itemRequirements.any.length > 0) {
				requires.add({'num':1, 'of':action.itemRequirements.any});
			}
			enabled = hasRequirements(requires);
			if (enabled) {
				error = action.description;
			} else {
				error = getRequirementString(requires);
			}
			actions.add([
				            capitalizeFirstLetter(action.name) + '|' +
				            action.name + '|${action.timeRequired}|$enabled|$error',
				            i.itemType,
				            "sendAction ${action.name} ${i.item_id}",
				            getDropMap(1, barSlot, bagSlot)
			            ]);
		});
	}
	Element menu = RightClickMenu.create(event, i.name, i.description, actions, itemName: i.name);
	document.body.append(menu);
}

Future findNewSlot(Slot slot, int index, {bool update: false}) async {
	ItemDef item = slot.item;
	int count = slot.count;

	//create an image for this item and wait for it to load before sizing/positioning it
	ImageElement img = new ImageElement(src: item.spriteUrl);
	await img.onLoad.first;

	Element barSlot = view.inventory.children.elementAt(index);
	barSlot.children.clear();
	String cssName = item.itemType.replaceAll(" ", "_");
	Element itemDiv = new DivElement();

	//determine what we need to scale the sprite image to in order to fit
	num scale = 1;
	if (img.height > img.width / item.iconNum) {
		scale = (barSlot.contentEdge.height - 10) / img.height;
	} else {
		scale = (barSlot.contentEdge.width - 10) / (img.width / item.iconNum);
	}

	itemDiv.style.width = (barSlot.contentEdge.width - 10).toString() + "px";
	itemDiv.style.height = (barSlot.contentEdge.height - 10).toString() + "px";
	itemDiv.style.backgroundImage = 'url(${item.spriteUrl})';
	itemDiv.style.backgroundRepeat = 'no-repeat';
	itemDiv.style.backgroundSize = "${img.width * scale}px ${img.height * scale}px";
	itemDiv.style.backgroundPosition = "0 50%";
	itemDiv.style.margin = "auto";
	itemDiv.className = 'item-$cssName inventoryItem';

	itemDiv.attributes['name'] = item.name.replaceAll(' ', '');
	itemDiv.attributes['count'] = "1";
	itemDiv.attributes['itemMap'] = encode(item);

	String slotNum = '${barSlot.dataset["slot-num"]}.-1';
	itemDiv.onContextMenu.listen((MouseEvent event) => itemContextMenu(item, slotNum, event));
	barSlot.append(itemDiv);

	SpanElement itemCount = new SpanElement()
		..text = count.toString()
		..className = "itemCount";
	barSlot.append(itemCount);
	if (count <= 1) {
		itemCount.text = "";
	}

	int offset = count;
	if (item.iconNum != null && item.iconNum < count) {
		offset = item.iconNum;
	}
	itemDiv.style.backgroundPosition = "calc(100% / ${item.iconNum - 1} * ${offset - 1})";

	if (!update) {
		itemDiv.classes.add("bounce");
		//	remove the bounce class so that it's not still there for a drag and drop event
		new Timer(new Duration(seconds: 1), () {
			itemDiv.classes.remove("bounce");
		});
	}

	// Containers
	DivElement containerButton;
	String bagWindowId;
	if (item.isContainer == true) {
		bagWindowId = new BagWindow(index, item, open:false).id;
		containerButton = new DivElement()
			..classes.addAll(["fa", "fa-fw", "fa-plus", "item-container-toggle", "item-container-closed"])
			..onClick.listen((_) {
				if (containerButton.classes.contains("item-container-closed")) {
					// Container is closed, open it
					// Open the bag window
					new BagWindow(index, item, id:bagWindowId).id;
					// Update the slot display
					BagWindow.updateTriggerBtn(false, itemDiv);
				} else {
					// Container is open, close it
					// Close the bag window
					BagWindow.closeId(bagWindowId);
					// Update the slot display
					BagWindow.updateTriggerBtn(true, itemDiv);
				}
			});
		itemDiv.parent.append(containerButton);
	}
}

void takeItemFromInventory(String itemType, {int count: 1}) {
	String cssName = itemType.replaceAll(" ", "_");
	int remaining = count;
	for (Element item in view.inventory.querySelectorAll(".item-$cssName")) {
		if (remaining < 1) {
			break;
		}

		int uiCount = int.parse(item.attributes['count']);
		if (uiCount > count) {
			item.attributes['count'] = (uiCount - count).toString();
			item.parent
				.querySelector('.itemCount')
				.text = (uiCount - count).toString();
		} else {
			item.parent.children.clear();
		}

		remaining -= uiCount;
	}
	transmit("inventoryUpdated");
}

Map getDropMap(int count, int slotNum, int subSlotNum) {
	Map dropMap = new Map()
		..['slot'] = slotNum
		..['subSlot'] = subSlotNum
		..['count'] = count
		..['x'] = CurrentPlayer.posX
		..['y'] = CurrentPlayer.posY + CurrentPlayer.height / 2
		..['streetName'] = currentStreet.label
		..['tsid'] = currentStreet.streetData['tsid'];

	return dropMap;
}
