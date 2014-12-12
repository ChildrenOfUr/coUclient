part of couclient;

abstract class Entity
{
	bool glow = false, dirty = true;
	ChatBubble chatBubble = null;
	CanvasElement canvas;

	void update(double dt);
	void render();

	void updateGlow(bool newGlow)
	{
		if(glow != newGlow)
			dirty = true;
		glow = newGlow;
	}

	void interact(String id)
  	{
  		Element element = querySelector("#$id");
  		List<List> actions = [];
  		bool allDisabled = true;
  		if(element.attributes['actions'] != null)
  		{
  			List<Map> actionsList = JSON.decode(element.attributes['actions']);
  			actionsList.forEach((Map actionMap)
  			{
  				bool enabled = actionMap['enabled'];
  				if(enabled)
  					allDisabled = false;
  				String error = "";
  				if(actionMap['requires'] != null)
  				{
  					enabled = hasRequirements(actionMap['requires']);
  					error = getRequirementString(actionMap['requires']);
  				}
  				actions.add([capitalizeFirstLetter(actionMap['action'])+"|"+actionMap['actionWord']+"|${actionMap['timeRequired']}|$enabled|$error",element.id,"sendAction ${actionMap['action']} ${element.id}"]);
  			});
  		}
  		if(!allDisabled)
  			inputManager.showClickMenu(null,element.attributes['type'],"Desc",actions);
  	}
}