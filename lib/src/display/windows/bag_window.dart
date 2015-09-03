part of couclient;

class BagWindow extends Modal {

	static List<BagWindow> openWindows = [];

	static closeId(String id) {
		openWindows.where((BagWindow w) => w.id == id).first.close();
		openWindows.removeWhere((BagWindow w) => w.id == id);
	}

	String id = 'bagWindow' + random.nextInt(9999999).toString();
	String bagId;
	int numSlots;
	int sourceSlotNum;

	BagWindow(this.sourceSlotNum, Map sourceItem) {
		DivElement windowElement = load(sourceItem);
		querySelector("#windowHolder").append(windowElement);
		prepare();
		open();
		openWindows.add(this);
	}

	DivElement load(Map sourceItem) {

		// Header

		Element closeButton = new Element.tag("i")
			..classes.add("fa-li")
			..classes.add("fa")
			..classes.add("fa-times")
			..classes.add("close");

		Element icon = new Element.tag("i")
			..classes.add("fa-li")
			..classes.add("fa")
			..classes.add("fa-info-circle");

		SpanElement titleSpan = new SpanElement()
			..classes.add("iw-title")
			..text = sourceItem["name"];

		if (sourceItem["name"].length >= 24) {
			titleSpan.style.fontSize = "24px";
		}

		Element header = new Element.header()
			..append(icon)
			..append(titleSpan);

		// Content

		Element well = new Element.tag("ur-well");

		int numSlots = sourceItem["subSlots"];
		List<Map> subSlots;

		if (sourceItem["metadata"]["slots"] == null) {
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
			subSlots = JSON.decode(sourceItem["metadata"]["slots"]);
		}

		if (subSlots.length != sourceItem["subSlots"]) {
			throw new StateError("Number of slots in bag does not match bag size");
		} else {
			subSlots.forEach((Map itemInBag) {
				print(itemInBag);
				// Item
				DivElement itemInSlot = new DivElement();
				if (itemInBag["itemType"] != "") {
					// Item in slot
						itemInSlot
						..classes.addAll(["item-${itemInBag["itemType"]}", "inventoryItem", "bagInventoryItem"])
						..attributes["name"] = itemInBag["name"]
						..attributes["count"] = itemInBag["count"].toString()
						..attributes["itemmap"] = JSON.encode(itemInBag);
				} else {
					// Empty slot
					itemInSlot.classes.add("empty-bag-slot");
				}
				// Slot
				DivElement slot = new DivElement()
					..classes.addAll(["box", "bagwindow-box"])
					..append(itemInSlot);

				well.append(slot);
			});
		}

		// Window

		DivElement window = new DivElement()
			..id = id
			..classes.add("window")
			..classes.add("itemWindow")
			..append(header)
			..append(closeButton)
			..append(well);

		return window;
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
	}
}