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
	String actionName, _actionWord, error;
	bool enabled = true, multiEnabled = false;
	String description = '';
	int timeRequired = 0;
	ItemRequirements itemRequirements = new ItemRequirements();
	SkillRequirements skillRequirements = new SkillRequirements();
	EnergyRequirements energyRequirements = new EnergyRequirements();
	String associatedSkill;
	Map dropMap;

	Action();

	Action.withName(this.actionName);

	Action.clone(Action action) {
		actionName = action.actionName;
		_actionWord = action._actionWord;
		enabled = action.enabled;
		multiEnabled = action.multiEnabled;
		description = action.description;
		timeRequired = action.timeRequired;
		itemRequirements = new ItemRequirements.clone(action.itemRequirements);
		skillRequirements = new SkillRequirements.clone(action.skillRequirements);
		energyRequirements = new EnergyRequirements.clone(action.energyRequirements);
		associatedSkill = action.associatedSkill;
	}

	String get actionWord => _actionWord ?? actionName.toLowerCase();
	void set actionWord(String word) {
		_actionWord = word;
	}

	@override
	String toString() {
		String returnString = "$actionName requires any of ${itemRequirements.any}, all of ${itemRequirements.all} and at least ";
		skillRequirements.requiredSkillLevels.forEach((String skill, int level) {
			returnString += "$level level of $skill, ";
		});
		returnString = returnString.substring(0, returnString.length - 1);

		return returnString;
	}
}

class SkillRequirements {
	Map<String, int> requiredSkillLevels = {};
	String error = "You don't have the required skill(s)";

	SkillRequirements();
	SkillRequirements.clone(SkillRequirements req) {
		requiredSkillLevels = new Map.from(req.requiredSkillLevels);
		error = req.error;
	}
}

class ItemRequirements {
	List<String> any = [];
	Map<String, int> all = {};
	String error = "You don't have the required item(s)";

	ItemRequirements();
	ItemRequirements.clone(ItemRequirements req) {
		any = new List.from(req.any);
		all = new Map.from(req.all);
		error = req.error;
	}
}

class EnergyRequirements {
	int energyAmount;
	String error;

	EnergyRequirements({this.energyAmount: 0}) {
		error = 'You need at least $energyAmount to perform this action';
	}
	EnergyRequirements.clone(EnergyRequirements req) {
		energyAmount = req.energyAmount;
		error = req.error;
	}
}