part of couclient;

abstract class Entity
{
	bool glow = false, dirty = true;
	ChatBubble chatBubble = null;
	CanvasElement canvas;
	num left, top, width, height;
	String id;
	MutableRectangle _entityRect, _destRect;

	void update(double dt)
	{
		if(intersect(CurrentPlayer.avatarRect, entityRect))
		{
			updateGlow(true);
			CurrentPlayer.intersectingObjects[id] = entityRect;
		}
		else
		{
			CurrentPlayer.intersectingObjects.remove(id);
			updateGlow(false);
		}
	}

	Rectangle get destRect
	{
		if(_destRect == null)
			_destRect = new MutableRectangle(0,0,width,height);
		else
		{
			_destRect.left = 0;
			_destRect.top = 0;
			_destRect.width = width;
			_destRect.height = height;
		}

		return _destRect;
	}

	Rectangle get entityRect
	{
		if(_entityRect == null)
			_entityRect = new MutableRectangle(left, top, width, height);
		else
		{
			_entityRect.left = left;
			_entityRect.top = top;
			_entityRect.width = width;
			_entityRect.height = height;
		}

		return _entityRect;
	}

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
                actions.add([capitalizeFirstLetter(actionMap['action']) + "|" + actionMap['actionWord'] + "|${actionMap['timeRequired']}|$enabled|$error", element.id, "sendAction ${actionMap['action']} ${element.id}"]);
            });
		}
		if(!allDisabled)
			inputManager.showClickMenu(null, element.attributes['type'], "Desc", actions);
	}
}