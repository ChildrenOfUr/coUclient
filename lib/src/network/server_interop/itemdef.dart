library itemdef;

class ItemDef {
	String category, iconUrl, spriteUrl, brokenUrl, toolAnimation, name, description, itemType, item_id;
	int price,
		stacksTo,
		iconNum = 4,
		durability,
		durabilityUsed = 0,
		subSlots = 0;
	num x, y;
	bool onGround = false,
		isContainer = false;
	List<String> subSlotFilter;
	List<Action> actions = [];
	Map<String, int> consumeValues = {};
	Map<String, dynamic> metadata = {};
}

class Action {
	String name;
	bool multiEnabled;
	String description;
	int timeRequired;
	ItemRequirements itemRequirements = new ItemRequirements();
	SkillRequirements skillRequirements = new SkillRequirements();

	Action();
	Action.withName(this.name);

	@override
	String toString() {
		String returnString = "$name requires any of ${itemRequirements.any}, all of ${itemRequirements.all} and at least ";
		skillRequirements.requiredSkillLevels.forEach((String skill, int level) {
			returnString += "$level level of $skill, ";
		});
		returnString = returnString.substring(0,returnString.length-1);

		return returnString;
	}
}

class SkillRequirements {
	Map<String,int> requiredSkillLevels = {};
}
class ItemRequirements {
	List<String> any = [];
	Map<String, int> all = {};
}