part of couclient;

//file for self-contained, top level utility functions

//basically if you can copy and paste the function here and there are no errors
//in the code, then consider putting it here, especially if you think it could be used
//in more than one place

/**
 * Determine if Rectangle [a] intersects with [b]
 */
bool intersect(Rectangle a, Rectangle b) {
	return (a.left <= b.right &&
	        b.left <= a.right &&
	        a.top <= b.bottom &&
	        b.top <= a.bottom);
}

/**
 * Log an event to the bug report window.
 **/
logmessage(String message) {
	String text = message + ' ' + getUptime();
	transmit('debug', text);
	print('$text');
}

/**
 * Get how long the window has been open.
 **/
String getUptime() {
	if(startTime == null)
		return '--:--';

	String uptime = new DateTime.now().difference(startTime).toString().split('.')[0];
	return uptime;
}


/**
 *
 * Counts the number of items of type [item] that the player currently has in their pack.
 * If the items are spread across more than one inventory slot, this will return the sum
 * of all slots.
 *
 * For example, if the player has 50 Chunks of Beryl in 3 slots, then this will return 150
 *
 * If slot and subSlot are set > -1, this will count only items in that slot.
 *
 **/
class Util {
	static Map<String, int> _itemCountCache = {};
	static Util _instance;

	factory Util() {
		if(_instance == null) {
			_instance = new Util._();
		}

		return _instance;
	}

	Util._() {
		new Service('inventoryUpdated', (_) => _itemCountCache.clear());
	}

	int getNumItems(String item, {int slot: -1, int subSlot: -1, bool includeBroken: false}) {
		if(slot == -1 && subSlot == -1 && _itemCountCache.containsKey(item)) {
			return _itemCountCache[item];
		} else {
			int num = _getNumItems(item, slot: slot, subSlot: subSlot, includeBroken: includeBroken);
			_itemCountCache[item] = num;
			return num;
		}
	}

	int getStackRemainders(String itemType) {
		int remainder = 0;

		for(Slot s in playerInventory.slots) {
			if (s.item == null) {
				continue;
			}

			if(s.itemType == itemType) {
				remainder += s.item.stacksTo - s.count;
			}

			if (s.item.isContainer) {
				String slotsString = JSON.encode(s.item.metadata['slots']);
				List<Slot> bagSlots = decode(slotsString, type: new TypeHelper<List<Slot>>().type);
				if (bagSlots != null) {
					for(Slot s in bagSlots) {
						if (s.item == null) {
							continue;
						}

						if(s.itemType == itemType) {
							remainder += s.item.stacksTo - s.count;
						}
					}
				}
			}
		}

		return remainder;
	}

	int getBlankSlots(Map itemMap) {
		int count = 0;

		for(Slot s in playerInventory.slots) {
			if(s.item == null || s.itemType == null || s.itemType == '') {
				count++;
				continue;
			}

			//if the item is a container, it can only go the above slots
			//otherwise, we need to look in any slots and count those
			//if the item fits the filter
			if (!itemMap["isContainer"] && s.item.isContainer) {
				if(s.item.subSlotFilter.contains(itemMap['itemType']) ||
				   s.item.subSlotFilter.length == 0) {
					String slotsString = JSON.encode(s.item.metadata['slots']);
					List<Slot> bagSlots = decode(slotsString, type: new TypeHelper<List<Slot>>().type);
					if (bagSlots != null) {
						for(Slot s in bagSlots) {
							if(s.item == null || s.itemType == null || s.itemType == '') {
								count++;
							}
						}
					}
				}
			}
		}

		return count;
	}
}

Util util = new Util();

int _getNumItems(String item, {int slot: -1, int subSlot: -1, bool includeBroken: false}) {
	int count = 0;

	//count all the normal slots
	int i = 0;
	for(Slot s in playerInventory.slots) {
		i++;
		if(slot > -1 && (i-1) != slot) {
			continue;
		}
		if(s.itemType == item) {
			int durabilityUsed = int.parse(s.item.metadata['durabilityUsed'] ?? '0');
			if(s.item.durability != null && durabilityUsed >= s.item.durability && !includeBroken) {
				continue;
			}

			count += s.count;
		}
	}

	//add the bag contents
	playerInventory.slots.where((Slot s) => !s.itemType.isEmpty && s.item.isContainer && s.item.subSlots != null).forEach((Slot s) {
		String slotsString = s.item.metadata['slots'];
		List<Slot> bagSlots = decode(slotsString, type: new TypeHelper<List<Slot>>().type);
		if (bagSlots != null) {
			i=0;
			for(Slot bagSlot in bagSlots) {
				i++;
				if(subSlot > -1 && (i-1) != subSlot) {
					continue;
				}
				if (bagSlot.itemType == item) {
					int durabilityUsed = int.parse(s.item.metadata['durabilityUsed'] ?? '0');
					if(s.item.durability != null && durabilityUsed >= s.item.durability && !includeBroken) {
						continue;
					}

					count += bagSlot.count;
				}
			}
		}
	});

	return count;
}

/**
 *
 * A simple function to capitalize the first letter of a string.
 *
 **/
String capitalizeFirstLetter(String string) {
	return string[0].toUpperCase() + string.substring(1);
}

/**
 *
 * This function will determine if a user has the required items in order to perform an action.
 *
 * For example, if the user is trying to mine a rock, this will take in a List<Map> which looks like
 *
 * [{"num":1,"of":["Pick","Fancy Pick"]}]
 *
 * ...meaning that the player must have 1 of either a Pick or Fancy Pick in their bags in order
 * to perform the action.
 *
 * By default, this will not match items which have a remaining durability of 0
 *
 **/
bool hasRequirements(List<Map> requires, {bool includeBroken: false}) {
	//there may be one or more requirements
	//each requirement has a number associated with it and a list of 1 or more items that fullfill it
	//if the list is more than one, it is taken to mean that either one or the other is appropriate or a combination
	for(Map requirement in requires) {
		int have = 0;
		int num = requirement['num'];
		List<String> items = requirement['of'];
		items.forEach((String item) {
			if(item == 'energy') {
				have = metabolics.energy;
			} else {
				have += util.getNumItems(item, includeBroken: includeBroken);
			}
		});

		if(have < num)
			return false;
	}
	return true;
}

/**
 *
 * This function will generate a string that shows what the requirements are for a certain action.
 *
 **/
String getRequirementString(List<Map> requires) {
	String error = '';

	requires.forEach((Map requirement) {
		if (requirement["error"] == null) {
			requirement["error"] = "You can't do this right now";
		}
		if (requirement["of"].contains("energy")) {
			if (metabolics.energy < requirement["num"]) {
				error += "\n" + requirement["error"];
			}
		} else {
			error += "\n" + requirement["error"];
		}
	});

	return error;
}

/**
 *
 * Send a message to the server that you want to perform [methodName] on [entityId]
 * with optional [arguments]
 *
 **/
sendAction(String methodName, String entityId, [Map arguments]) {
	if(methodName == null || methodName.trim == "") {
		logmessage("[Server Communication] methodName must be provided, got: '$methodName'");
		return;
	}
	if(entityId == null || entityId.trim == "") {
		logmessage("[Server Communication] entityId must be provided, got: '$entityId'");
		return;
	}

	logmessage("[Server Communication] Sending $methodName to entity: $entityId (${entities[entityId].runtimeType}) with arguments: $arguments");
	Element entity = querySelector("#$entityId");
	Map map = {};
	map['callMethod'] = methodName;
	if (entityId == "global_action_monster") {
		map["id"] = entityId;
	} else if (entity != null) {
		map['id'] = entityId;
		map['type'] = entity.className;
	} else {
		map['type'] = entityId;
	}
	map['streetName'] = currentStreet.label;
	map['username'] = game.username;
	map['email'] = game.email;
	map['tsid'] = currentStreet.streetData['tsid'];
	map['arguments'] = arguments;
	streetSocket.send(JSON.encode(map));
	print("SEND: $map");
}

/**
 *
 * Send a message to the server that you want to perform [methodName]
 * that does not belong to a specific entity with optional [arguments]
 *
 **/
sendGlobalAction(String methodName, [Map arguments]) {
	if(methodName == null || methodName.trim == "") {
		logmessage("[Server Communication] methodName must be provided, got: '$methodName'");
		return;
	}

	Map map = {};
	map['callMethod'] = methodName;
	map['id'] = 'global_action_monster';
	map['streetName'] = currentStreet.label;
	map['username'] = game.username;
	map['email'] = game.email;
	map['tsid'] = currentStreet.streetData['tsid'];
	map['arguments'] = arguments;
	streetSocket.send(JSON.encode(map));
}

/**
 * Get a name that will work as a css selector by replacing all invalid characters with an underscore
 **/
String sanitizeName(String name) {
	List<String> badChars = "! @ \$ % ^ & * ( ) + = , . / ' ; : \" ? > < [ ] \\ { } | ` #".split(" ");
	for(String char in badChars)
		name = name.replaceAll(char, '_');

	return name;
}

String getTimestampString() => new DateTime.now().toString().substring(11, 16);

/// Log base function using the change of base formula

double logb (num number, {num base: 10}) {
	return log(number) / log(base);
}