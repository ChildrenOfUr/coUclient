part of couclient;

class InvDragging {
	static List<String> disablers = [];
	static Service refresh = new Service(["inventoryUpdated"], (_) => init());

	/// Draggable items
	static Draggable draggables;
	/// Drop targets
	static Dropzone dropzones;

	/**
	 * Map used to store *how* the item was moved.
	 * Keys:
	 * - General:
	 * - - item_number: element: span element containing the count label
	 * - - bag_btn: element: the toggle button for containers
	 * - On Pickup:
	 * - - from_bag: boolean: whether the item used to be in a bag
	 * - - from_bag_index: int: which slot the to_bag is in  (only set if from_bag is true)
	 * - - from_index: int: which slot the item used to be in
	 * - On Drop:
	 * - - to_bag: boolean: whether the item is going into a bag
	 * - - to_bag_index: int: which slot the to_bag is in (only set if to_bag is true)
	 * - - to_index: int: which slot the item is going to
	 */
	static Map<String, dynamic> move = {};

	/// Returns an element list of boxes without items
	static ElementList<Element> getEmptySlots() {
		return querySelectorAll("#inventory .box:empty");
		/// Bag windows manage their own acceptors
	}

	/// Returns an element list of items inside boxes
	static ElementList<Element> getItems() {
		return querySelectorAll(
			"#inventory > .box > .inventoryItem, "
			".bagwindow-box > .inventoryItem"
		);
	}

	/// Checks if the specified slot is empty
	static bool slotIsEmpty({int index, Element box, int bagWindow}) {
		if (index != null) {
			if (bagWindow == null) {
				box = querySelectorAll("#inventory .box").toList()[index];
			} else {
				box = querySelectorAll("#bagWindow$bagWindow").toList()[index];
			}
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

		if (disablers.length == 0) {
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
	}

	/// Runs when an item is picked up (drag start)
	static void handlePickup(DraggableEvent e) {
		Element origBox = e.draggableElement.parent;
		e.draggableElement.dataset["original-slot-num"] = origBox.dataset["slot-num"];

		move = {};

		move["from_bag"] = querySelector("#windowHolder").contains(origBox);
		if (move["from_bag"]) {
			move["from_bag_index"] = origBox.parent.parent.dataset["source-bag"];
		}
		move["from_index"] = origBox.dataset["slot-num"];

		// Remove item count/bag button and save it for later
		if (origBox.querySelector(".itemCount") != null) {
			move["item_count"] = origBox.querySelector(".itemCount").clone(true);
			origBox.querySelector(".itemCount").remove();
		}

		if (origBox.querySelector(".item-container-toggle") != null) {
			move["bag_btn"] = origBox.querySelector(".item-container-toggle").clone(true);
			origBox.querySelector(".item-container-toggle").remove();
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
		move["to_bag"] = querySelector("#windowHolder").contains(e.dropzoneElement);
		if (move["to_bag"]) {
			move["to_bag_index"] = int.parse(e.dropzoneElement.parent.parent.dataset["source-bag"]);
		}
		move["to_index"] = e.dropzoneElement.dataset["slot-num"];

		Map sendData = move;
		if (sendData.containsKey("item_count")) {
			sendData.remove("item_count");
		}
		if (sendData.containsKey("bag_btn")) {
			sendData.remove("bag_btn");
		}
		sendAction("moveItem", "global_action_monster", move);

		// Reapply item count & bag button
		if (move["item_count"] != null) {
			e.dropzoneElement.append(move["item_count"]);
		}
		if (move["bag_btn"] != null) {
			e.dropzoneElement.append(move["bag_btn"]);
		}

		// Refresh data after DOM changes finish
		new Timer(new Duration(milliseconds: 50), () => init());
	}
}

class BagFilterAcceptor extends Acceptor {
	BagFilterAcceptor(this.allowedItemTypes);

	List<String> allowedItemTypes;

	@override
	bool accepts(Element item, int draggable_id, Element box) {
		if (allowedItemTypes.length == 0) {
			// Those that accept nothing learn to accept everything
			return true;
		} else {
			// Those that are at least somewhat accepting are fine, though
			String itemType = JSON.decode(item.attributes["itemmap"])["itemType"];
			return allowedItemTypes.contains(itemType);
		}
	}
}