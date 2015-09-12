part of couclient;

class InvDragging {
	static Draggable draggables;
	static Dropzone dropzones;

	static Element origSibling;

	/// Returns an element list of boxes without items
	static ElementList<Element> getEmptySlots() {
		return querySelectorAll("#inventory .box:empty");
	}

	/// Returns an element list of items inside boxes
	static ElementList<Element> getItems() {
		return querySelectorAll("#inventory > .box > .inventoryItem");
	}

	/// Checks if the specified slot is empty
	static bool slotIsEmpty({int index, Element box}) {
		if (index != null) {
			box = querySelectorAll("#inventory .box").toList()[index];
		}

		return (box.children.length == 0);
	}

	/// Set up event listeners based on the current inventory
	static void init() {
		// Remove old data
		if (draggables != null) {
			draggables.destroy();
		}
		if (dropzones != null) {
			dropzones.destroy();
		}

		// Set up draggable elements
		draggables = new Draggable(
			// List of item elements in boxes
			getItems(),
			// Display the item on the cursor
			avatarHandler: new AvatarHandler.clone(),
			// If a bag is open, allow free dragging.
			// If not, only allow horizontal dragging across the inventory bar
			horizontalOnly: !BagWindow.isOpen,
			// Disable item interaction while dragging it
			draggingClass: "item-flying"
		)
			..onDragStart.listen((DraggableEvent e) => handlePickup(e));

		// Set up empty acceptor slots
		dropzones = new Dropzone(getEmptySlots())
			..onDragEnter.listen((DropzoneEvent e) => handleZoneEntry(e))
			..onDrop.listen((DropzoneEvent e) => handleDrop(e));
	}

	/// Runs when an item is picked up (drag start)
	static void handlePickup(DraggableEvent e) {
		Element origBox = e.draggableElement.parent;
		e.draggableElement.dataset["original-slot-num"] = origBox.dataset["slot-num"];

		// Remove item count/bag button and save it for later
		if (origBox.querySelector(".itemCount") != null) {
			origSibling = origBox.querySelector(".itemCount").clone(true);
			origBox.querySelector(".itemCount").remove();
		} else if (origBox.querySelector(".item-container-toggle") != null) {
			origSibling = origBox.querySelector(".item-container-toggle").clone(true);
			origBox.querySelector(".item-container-toggle").remove();
		} else {
			origSibling = null;
		}
	}

	/// Runs when an item enters a dropzone (drag enter)
	static void handleZoneEntry(DropzoneEvent e) {
		if (slotIsEmpty(box: e.dropzoneElement)) {
			e.dropzoneElement.children.add(e.draggableElement);
		}
	}

	/// Runs when an item is dropped (drop)
	static void handleDrop(DropzoneEvent e) {
		int oldSlotNum = int.parse(e.draggableElement.dataset["original-slot-num"]);
		int newSlotNum = int.parse(e.dropzoneElement.dataset["slot-num"]);

		print("${oldSlotNum.toString()} -> ${newSlotNum.toString()}");
		//TODO: send action to server

		// Reapply item count/bag button
		if (origSibling != null) {
			e.dropzoneElement.append(origSibling);
		}

		// Refresh data after DOM changes finish
		new Timer(new Duration(milliseconds: 50), () => init());
	}
}