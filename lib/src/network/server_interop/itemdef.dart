library itemdef;

class ItemDef {
	String category, iconUrl, spriteUrl, brokenUrl, toolAnimation, name, description, itemType,
		item_id;
	int price,
		stacksTo,
		iconNum = 4,
		durability,
		subSlots = 0;
	num x, y;
	bool onGround = false,
		isContainer = false;
	List<String> subSlotFilter;
	List<Action> actions = [];
	Map<String, int> consumeValues = {};
	Map<String, String> metadata = {};
}

class Action {
	String _name, _action;
	bool enabled, multiEnabled;
	String description, associatedSkill, actionWord;
	int timeRequired;
	ItemRequirements itemRequirements = new ItemRequirements();
	SkillRequirements skillRequirements = new SkillRequirements();

	Action();

	Action.withName(this._name);

	///we did a stupid on the server. The items' actions are defined to have a 'name'
	///but the entities' actions have an 'action' parameter which means the same thing.
	///this kludge solves that problem. Better would be to go through all the server files
	///and rename one to the other though.
	void set name(String newName) {
		_name = newName;
	}
	void set action(String newAction) {
		_action = newAction;
	}
	String get name => _name ?? _action;
	String get action => _action ?? _name;

	@override
	String toString() {
		String returnString = "$action requires any of ${itemRequirements.any}, all of ${itemRequirements
			.all} and at least ";
		skillRequirements.requiredSkillLevels.forEach((String skill, int level) {
			returnString += "$level level of $skill, ";
		});
		returnString = returnString.substring(0, returnString.length - 1);

		return returnString;
	}
}

class SkillRequirements {
	Map<String, int> requiredSkillLevels = {};
}

class ItemRequirements {
	List<String> any = [];
	Map<String, int> all = {};
}