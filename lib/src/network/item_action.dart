part of couclient;

class SkillRequirements {
	Map<String,int> requiredSkillLevels = {};
}
class ItemRequirements {
	List<String> any = [], all = [];
}
class Action {
	String name;
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