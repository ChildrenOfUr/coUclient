part of couclient;

///slot should be in the format 'barSlot.bagSlot' indexed from 0
///if bagSlot is not relevant, please use 'barSlot.-1'
void itemContextMenu(ItemDef i, String slot, MouseEvent event) {
	if(ActionBubble.occuring) {
		return;
	}

	event.preventDefault();
	event.stopPropagation();

	int barSlot = int.parse(slot.split('.').elementAt(0));
	int bagSlot = int.parse(slot.split('.').elementAt(1));
	List<Action> actions = [];

	if (i.actions != null) {
		List<Action> actionsList = i.actions;
		bool enabled = false;
		actionsList.forEach((Action action) {
			enabled = action.enabled;
			action.actionName = capitalizeFirstLetter(action.actionName);
			String error = "";
			if(enabled) {
				enabled = hasRequirements(action);
				if(enabled) {
					error = action.description;
				} else {
					error = getRequirementString(action);
				}
			} else {
				error = action.error;
			}
			Action menuAction = new Action.clone(action)
				..enabled = enabled
				..error = error;
			menuAction.dropMap = getDropMap(1, barSlot, bagSlot);
			actions.add(menuAction);
		});
	}
	Function onInfo = (_){new ItemWindow(i.name).displayItem();};
	Element menu = RightClickMenu.create3(event, i.metadata['title'] ?? i.name, i.itemType, description: i.description, actions: actions, item: i, onInfo: onInfo);
	document.body.append(menu);
}

Future findNewSlot(Slot slot, int index, {bool update: false}) async {
	ItemDef item = slot.item;
	int count = slot.count;

	//decide what image to used based on durability state
	String url = item.spriteUrl;
	int used = int.parse(item.metadata['durabilityUsed'] ?? "0");
	if(item.durability != null && used >= item.durability) {
		//print('item.brokenUrl: ${item.brokenUrl}');
		url = item.brokenUrl;
	}
	//create an image for this item and wait for it to load before sizing/positioning it
	ImageElement img = new ImageElement(src: url);
	Element barSlot = view.inventory.children.elementAt(index);
	barSlot.children.clear();
	Element itemDiv = new DivElement();

	await sizeItem(img,itemDiv,barSlot,item,count, int.parse(barSlot.dataset["slot-num"]));

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
					new BagWindow(index, item, id:bagWindowId);
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

Future sizeItem(ImageElement img, Element itemDiv, Element slot, ItemDef item, int count, int barSlotNum, {String cssClass, int bagSlotNum: -1}) async {
	await img.onLoad.first;
	Function onUpdateMetadata;

	//determine what we need to scale the sprite image to in order to fit
	num scale = 1;
	if (img.height > img.width / item.iconNum) {
		scale = (slot.contentEdge.height - 10) / img.height;
	} else {
		scale = (slot.contentEdge.width - 10) / (img.width / item.iconNum);
	}

	if (cssClass == null) {
		cssClass = 'item-${item.itemType} inventoryItem';
	}
	String url = item.spriteUrl;
	int used = int.parse(item.metadata['durabilityUsed'] ?? '0');
	if(item.durability != null && used >= item.durability) {
		url = item.brokenUrl;
	}

	if (url.endsWith('.svg')) {
		itemDiv.style.width = '${img.width * scale}px';
		itemDiv.style.height = '${img.height * scale}px';
	} else {
		itemDiv.style.width = (slot.contentEdge.width - 10).toString() + "px";
		itemDiv.style.height = (slot.contentEdge.height - 10).toString() + "px";
	}

	itemDiv.style.backgroundImage = 'url($url)';
	itemDiv.style.backgroundRepeat = 'no-repeat';
	itemDiv.style.backgroundSize = "${img.width * scale}px ${img.height * scale}px";
	itemDiv.style.backgroundPosition = "0 50%";
	itemDiv.style.margin = "auto";
	itemDiv.className = cssClass;

	itemDiv.attributes['name'] = item.name.replaceAll(' ', '');
	itemDiv.attributes['count'] = "1";
	itemDiv.attributes['itemMap'] = encode(item);
	slot.title = item.name;

	String slotNum = '$barSlotNum.$bagSlotNum';
	itemDiv.onContextMenu.listen((MouseEvent event) => itemContextMenu(item, slotNum, event));
	slot.append(itemDiv);

	if (item.metadata.containsKey('fireflies')) {
		count = int.parse(item.metadata['fireflies']);
		onUpdateMetadata = (Map indexToItem){
			ItemDef item = indexToItem['item'];
			slot.querySelector('.itemCount')..text = item.metadata['fireflies'];
		};
	}
	SpanElement itemCount = new SpanElement()
		..text = count.toString()
		..className = "itemCount";
	slot.append(itemCount);
	if (count <= 1 && !item.metadata.containsKey('fireflies')) {
		itemCount.text = "";
	}

	if(item.durability != null) {
		int durabilityUsed = int.parse(item.metadata['durabilityUsed'] ?? '0');
		int durabilityPercent = (((item.durability - durabilityUsed) / item.durability) * 100).round().clamp(0, 100);

		DivElement durabilityBackground = new DivElement()
			..className = 'durabilityBackground'
			..title = "$durabilityPercent% durability remaining";
		DivElement durabilityForeground = new DivElement()
			..className = 'durabilityForeground'
			..style.width = '$durabilityPercent%';

		if (durabilityPercent < 10) {
			durabilityForeground.classes.add("durabilityWarning");
		}

		durabilityBackground.append(durabilityForeground);
		slot.append(durabilityBackground);

		onUpdateMetadata = (Map indexToItem) {
			Element durabilityBar = slot.querySelector('.durabilityForeground');
			Element durabilityBarBack = slot.querySelector('.durabilityBackground');
			if(durabilityBar == null) {
				return;
			}

			ItemDef item = indexToItem['item'];
			int durabilityUsed = int.parse(item.metadata['durabilityUsed'] ?? '0');
			num percent = ((item.durability-durabilityUsed)/item.durability)*100;
			durabilityBar.style.width = '$percent%';
			int durabilityPercent = percent.round();
			durabilityBarBack.title = '$durabilityPercent% durability remaining';
			if(percent == 0) {
				itemDiv.style.backgroundImage = 'url(${item.brokenUrl})';
			} else {
				itemDiv.style.backgroundImage = 'url(${item.spriteUrl})';
			}
		};
	}

	int offset = count;
	if (item.iconNum != null && item.iconNum < count) {
		offset = item.iconNum;
	}
	itemDiv.style.backgroundPosition = "calc(100% / ${item.iconNum - 1} * ${offset - 1})";

	if (onUpdateMetadata != null) {
		_onUpdateMetadata(onUpdateMetadata, barSlotNum: barSlotNum, bagSlotNum: bagSlotNum);
	}
}

void _onUpdateMetadata(Function doAction, {int bagSlotNum: -1, int barSlotNum: -1}) {
	new Service('updateMetadata', (Map indexToItem) {
		if (bagSlotNum != -1) {
			//stuff in bags will update itself each time the bag is changed
			return;
		}
		if (indexToItem['index'] == barSlotNum) {
			doAction(indexToItem);
		}
	});
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
		..['streetName'] = currentStreet.label
		..['tsid'] = currentStreet.streetData['tsid'];

	return dropMap;
}
