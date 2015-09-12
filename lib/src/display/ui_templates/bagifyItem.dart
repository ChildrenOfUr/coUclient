part of couclient;

class BagifyMenu {
	/// The item div (inside the .box)
	Element itemInInventory;

	/// Create and display the menu
	BagifyMenu(int itemIndex) {
		// Get the item specified
		itemInInventory = inventory.children[itemIndex].querySelector(".inventoryItem");
		// Prevent item changing until completion
		setInvLock(true);
		// Build and display the menu
		querySelector("#windowHolder").append(assemble());
	}

	/// Create a menu element
	DivElement assemble() {
		// Get available bags
		List<Map> bags = getBags();
		DivElement bagList = new DivElement()
			..classes.add("bagify-menu-list");
		// For every bag...
		bags.forEach((Map bag) {
			DivElement bagListItem = new DivElement()
				..classes.addAll(["bagify-menu-item", "bagify-menu-bag"])
				..style.backgroundImage = "url(${bag["icon"]})"
				..title = "${bag["name"]} in inventory slot #${(bag["slot"] + 1).toString()}"
				..dataset["slot"] = bag["slot"].toString();
			bagList.append(bagListItem);
		});
		// Assemble display
		// Find the item's name
		String itemName = JSON.decode(itemInInventory.attributes["itemMap"])["name"];
		// Cancel button
		DivElement cancelButton = new DivElement()
			..classes.add("bagify-cancel-btn")
			..text = "Cancel"
			..onClick.first.then((_) => cancel());
		// Display a title
		ParagraphElement title = new ParagraphElement()
			..text = "Send this ${itemName} to which bag? (Or "
			..append(cancelButton)
			..appendText(")");
		// Put it all together
		DivElement container = new DivElement()
			..classes.add("bagify-menu-container")
			..append(title)
			..append(bagList);
		return container;
	}

	/// Enable/disable the inventory to prevent changes until completion
	void setInvLock(bool locked) {
		if (locked && !itemInInventory.classes.contains("disabled")) {
			itemInInventory.classes.add("inv-item-disabled");
		} else {
			itemInInventory.classes.remove("inv-item-disabled");
		}
	}

	/// Cancel the menu (close it) and clean up changes
	void cancel() {
		querySelector("#windowHolder .bagify-menu-container").remove();
		setInvLock(false);
	}

	// Static /////////////////////////////////////////////////////////////////////////////////////

	static Element inventory = querySelector("#inventory");
	static StreamSubscription trigger;

	/// Run when a context menu opens, checks for "Move to Bag" items
	static void listen() {
		// Clean up old listeners
		if (trigger != null) {
			trigger.cancel();
			trigger = null;
		}
		// Open the menu when an item is clicked
		trigger = inventory.querySelector(".move-item-to-bag").onClick.listen((Event e) {
			Element el = e.target;
			int slotIndex = int.parse(el.parent.dataset["slot-num"]);
			new BagifyMenu(slotIndex);
		});
	}

	/// Get a List<Map> representing all bags in the inventory
	static List<Map> getBags() {
		List<Map> bags = [];
		inventory.querySelectorAll(".box > .inventoryItem").forEach((DivElement item) {
			Map itemMap = JSON.decode(item.attributes["itemmap"]);
			if (itemMap["isContainer"] != null && itemMap["isContainer"] == true) {
				Map bag = {
					"slot": int.parse(item.parent.dataset["slot-num"]),
					"name": itemMap["name"],
					"icon": itemMap["iconUrl"]
				};
				bags.add(bag);
			}
		});
		return bags;
	}
}