part of couclient;

//file for self-contained, top level utility functions

//basically if you can copy and paste the function here and there are no errors
//in the code, then consider putting it here, especially if you think it could be used
//in more than one place

/**
 * 
 * Counts the number of items of type [item] that the player currently has in their pack.
 * If the items are spread across more than one inventory slot, this will return the sum
 * of all slots.
 * 
 * For example, if the player has 50 Chunks of Beryl in 3 slots, then this will return 150
 * 
 **/
int getNumItems(String item)
{
	int count = 0;
	String cssName = item.replaceAll(" ","_");
	for(Element item in querySelector("#InventoryBar").querySelectorAll(".item-$cssName"))
		count += int.parse(item.attributes['count']);
	
    return count;
}

/**
 * 
 * A simple function to capitalize the first letter of a string.
 * 
 **/
String capitalizeFirstLetter(String string)
{
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
 **/
bool hasRequirements(List<Map> requires)
{
	//there may be one or more requirements
	//each requirement has a number associated with it and a list of 1 or more items that fullfill it
	//if the list is more than one, it is taken to mean that either one or the other is appropriate or a combination
	for(Map requirement in requires)
	{
		int have = 0;
		int num = requirement['num'];
		List<String> items = requirement['of'];
		items.forEach((String item) => have += getNumItems(item));
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
String getRequirementString(List<Map> requires)
{
	String error = "Requires:";
	requires.forEach((Map requirement)
	{
		error += " ${requirement['num']} of ${requirement['of']},";
	});
	return error.substring(0,error.length-1); //remove trailing comma
}

/**
 * 
 * Send a message to the server that you want to perform [methodName] on [entityId]
 * with optional [arguments]
 * 
 **/
void sendAction(String methodName, String entityId, [Map arguments])
{
	Map map = {};
	map['callMethod'] = methodName;
	map['id'] = entityId;
	map['type'] = querySelector("#${entityId}").className;
	map['streetName'] = currentStreet.label;
	map['username'] = ui.username;
	map['tsid'] = currentStreet._data['tsid'];
	map['arguments'] = arguments;
	streetSocket.send(JSON.encode(map));
}