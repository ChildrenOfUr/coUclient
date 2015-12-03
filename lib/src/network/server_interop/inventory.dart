part of couclient;

Inventory playerInventory = new Inventory();

class Slot {
	//a new instance of a Slot is empty by default
	String itemType = "";
	ItemDef item = null;
	int count = 0;
}

class Inventory {
	// Sets how many slots each player has
	final int invSize = 10;
	List<Slot> slots = [];
}

class ItemDef {
	String category, iconUrl, spriteUrl, toolAnimation, name, description, itemType, item_id;
	int price, stacksTo, iconNum = 4, durability, durabilityUsed = 0, subSlots = 0;
	num x, y;
	bool onGround = false, isContainer = false;
	List<String> subSlotFilter;
	List<Action> actions = [];
	Map<String, dynamic> metadata = {};
}

Future updateInventory([Map map]) async {
	List<Map> dataSlots = [];

	if (map != null) {
		dataSlots = map["slots"];
	} else {
		print("Attempted inventory update: failed.");
		return;
	}

	List<Slot> currentSlots = playerInventory.slots;
	int slotNum = 0;
	List<Slot> slots = [];

	//couldn't get the structure to decode correctly so I hacked together this
	//it produces the right result, but looks terrible
	dataSlots.forEach((Map m) {
		Slot slot = new Slot();
		if (!m['itemType'].isEmpty) {
			ItemDef item;
			if (m['item']['metadata']['slots'] == null) {
				item = decode(JSON.encode(m['item']), type:ItemDef);
			} else {
				Map metadata = (m['item'] as Map).remove('metadata');
				item = decode(JSON.encode(m['item']), type:ItemDef);
				item.metadata = metadata;
			}
			slot.item = item;
			slot.itemType = item.itemType;
			slot.count = m['count'];
		}
		slots.add(slot);
		slotNum++;
	});

	playerInventory.slots = slots;

	//if the current inventory differs (count, type, metatdata) then clear it
	//and change it, else leave it alone
	List<Element> uiSlots = querySelectorAll(".box").toList();
	for (int i = 0; i < 10; i++) {
		Slot newSlot = slots.elementAt(i);

		bool updateNeeded = false, update = false;

		//if we've never received our inventory before, update all slots
		if (currentSlots.length == 0) {
			updateNeeded = true;
		} else {
			Slot currentSlot = currentSlots.elementAt(i);

			if (currentSlot.itemType != newSlot.itemType) {
				updateNeeded = true;
			} else if (currentSlot.count != newSlot.count) {
				updateNeeded = true;
				update = true;
			} else if (currentSlot.item != null && newSlot.item != null &&
			!_metadataEqual(currentSlot.item.metadata, newSlot.item.metadata)) {
				transmit('updateMetadata',newSlot.item);
				continue;
			}
		}

		if (updateNeeded) {
			if(newSlot.count == 0) {
				uiSlots.elementAt(i).children.clear();
			}
			uiSlots.elementAt(i).children.forEach((Element child) {
				if(child.attributes.containsKey('count')) {
					child.attributes['count'] = "0";
				}
			});
			for (int j = 0; j < newSlot.count; j++) {
				findNewSlot(newSlot,i,update:update);
//				addItemToInventory(newSlot.item, i, update:update);
			}
		}
	}

	transmit("inventoryUpdated", true);
}
