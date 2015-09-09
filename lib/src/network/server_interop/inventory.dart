part of couclient;

Inventory playerInventory = new Inventory();

class Slot {
	//a new instance of a Slot is empty by default
	String itemType = "";
	ItemDef item;
	int count = 0;
	Map metadata = {};
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