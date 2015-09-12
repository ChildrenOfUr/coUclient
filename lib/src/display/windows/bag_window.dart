part of couclient;

class BagWindow extends Modal {

	static List<BagWindow> openWindows = [];

	static closeId(String id) {
		openWindows.where((BagWindow w) => w.id == id).first.close();
		openWindows.removeWhere((BagWindow w) => w.id == id);
	}

	static bool get isOpen {
		return (querySelectorAll("#windowHolder > .bagWindow").length > 0);
	}

	String id = 'bagWindow' + WindowManager.randomId.toString();
	String bagId;
	int numSlots;
	int sourceSlotNum;

	BagWindow(this.sourceSlotNum, ItemDef sourceItem) {
		DivElement windowElement = load(sourceItem);
		querySelector("#windowHolder").append(windowElement);
		prepare();
		open();
		openWindows.add(this);
	}

	DivElement load(ItemDef sourceItem) {

		// Header

		Element closeButton = new Element.tag("i")
			..classes.add("fa-li")
			..classes.add("fa")
			..classes.add("fa-times")
			..classes.add("close");

		Element icon = new ImageElement()
			..classes.add("fa-li")
			..src = "files/system/icons/bag.svg";

		SpanElement titleSpan = new SpanElement()
			..classes.add("iw-title")
			..text = sourceItem.name;

		if (sourceItem.name.length >= 24) {
			titleSpan.style.fontSize = "24px";
		}

		Element header = new Element.header()
			..append(icon)
			..append(titleSpan);

		// Content

		Element well = new Element.tag("ur-well");

		int numSlots = sourceItem.subSlots;
		List<Map> subSlots;

		if (sourceItem.metadata["slots"] == null) {
			// Empty bag
			subSlots = [];
			while (subSlots.length < numSlots) {
				subSlots.add(({
					"itemType": "",
					"count": 0,
					"metadata": {}
				}));
			}
		} else {
			// Bag has contents
			subSlots = sourceItem.metadata["slots"];
		}

		if (subSlots.length != sourceItem.subSlots) {
			throw new StateError("Number of slots in bag does not match bag size");
		} else {
			int slotNum = 0;
			subSlots.forEach((Map bagSlot) {
				DivElement slot = new DivElement();
				// Item
				DivElement itemInSlot = new DivElement();
				if (!bagSlot["itemType"].isEmpty) {
					ItemDef item = decode(JSON.encode(bagSlot['item']),type:ItemDef);
					_sizeItem(slot,itemInSlot,item,bagSlot['count'],slotNum);
				} else {
					// Empty slot
					itemInSlot.classes.add("empty-bag-slot");
				}
				// Slot
				slot
					..classes.addAll(["box", "bagwindow-box"])
					..append(itemInSlot);

				well.append(slot);
				slotNum++;
			});
		}

		// Window

		DivElement window = new DivElement()
			..id = id
			..classes.add("window")
			..classes.add("bagWindow")
			..append(header)
			..append(closeButton)
			..append(well);

		return window;
	}

	Future _sizeItem(Element slot, Element item, ItemDef i, int count, int bagSlotIndex) async {
		ImageElement img = new ImageElement(src: i.spriteUrl);
		await img.onLoad;

		num scale = 1;
		if (img.height > img.width / i.iconNum) {
			scale = (slot.contentEdge.height - 10) / img.height;
		} else {
			scale = (slot.contentEdge.width - 10) / (img.width / i.iconNum);
		}

		item
			..classes.addAll(["item-${i.itemType}", "inventoryItem", "bagInventoryItem"])
			..attributes["name"] = i.name
			..attributes["count"] = count.toString()
			..attributes["itemmap"] = encode(i)
			..style.width = (slot.contentEdge.width - 10).toString() + "px"
			..style.height = (slot.contentEdge.height - 10).toString() + "px"
			..style.backgroundImage = 'url(${i.spriteUrl})'
			..style.backgroundRepeat = 'no-repeat'
			..style.backgroundSize = "${img.width * scale}px ${img.height * scale}px"
			..style.margin = "auto";

		int offset = count;
		if (i.iconNum != null && i.iconNum < count) {
			offset = i.iconNum;
		}

		item.style.backgroundPosition = "calc(100% / ${i.iconNum - 1} * ${offset - 1}";

		SpanElement itemCount = new SpanElement()
			..text = count.toString()
			..className = "itemCount";

		String slotString = '$sourceSlotNum.$bagSlotIndex';
		item.onContextMenu.listen((MouseEvent event) => itemContextMenu(i,slotString,event));
		item.parent.append(itemCount);
	}

	@override
	close() {
		// Handle window closing
		_destroyEscListener();
		displayElement.hidden = true;
		elementOpen = false;

		//see if there's another window that we want to focus
		for (Element modal in querySelectorAll('.window')) {
			if (!modal.hidden) {
				modals[modal.id].focus();
			}
		}

		// Delete the window
		if (querySelector("#${id.toString()}") != null) {
			querySelector("#${id.toString()}").remove();
		}

		// Update the source inventory icon
		Element sourceBox = view.inventory.children.where((Element box) => box.dataset["slot-num"] == sourceSlotNum.toString()).first;
		sourceBox.querySelector(".item-container-toggle").click();
	}

	// Update the inventory icons (used by the inventory)

	static updateTriggerBtn(bool open, Element item) {
		Element btn = item.parent.querySelector(".item-container-toggle");
		if (!open) {
			// Closed, opening the bag
			btn.classes
				..remove("item-container-closed")
				..remove("fa-plus")
				..add("item-container-open")
				..add("fa-times");
			item.classes.add("inv-item-disabled");
		} else {
			// Opened, closing the bag
			btn.classes
				..remove("item-container-open")
				..remove("fa-times")
				..add("item-container-closed")
				..add("fa-plus");
			item.classes.remove("inv-item-disabled");
		}

		// Enable/disable inventory dragging
		InvDragging.init();
	}
}