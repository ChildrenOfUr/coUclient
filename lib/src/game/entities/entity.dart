part of couclient;

abstract class Entity {
	bool glow = false, dirty = true;
	ChatBubble chatBubble = null;
	CanvasElement canvas;
	num left = 0, top = 0, width = 0, height = 0;
	String id;
	MutableRectangle _entityRect, _destRect;
	List<Action> actions = [];

	void update(double dt) {
		if(intersect(CurrentPlayer.avatarRect, entityRect)) {
			updateGlow(true);
			CurrentPlayer.intersectingObjects[id] = entityRect;
		} else {
			CurrentPlayer.intersectingObjects.remove(id);
			updateGlow(false);
		}
	}

	Rectangle get destRect {
		if(_destRect == null) {
			_destRect = new MutableRectangle(0, 0, width, height);
		} else {
			_destRect.left = 0;
			_destRect.top = 0;
			_destRect.width = width;
			_destRect.height = height;
		}

		return _destRect;
	}

	Rectangle get entityRect {
		if(_entityRect == null) {
			_entityRect = new MutableRectangle(left, top, width, height);
		} else {
			_entityRect.left = left;
			_entityRect.top = top;
			_entityRect.width = width;
			_entityRect.height = height;
		}

		return _entityRect;
	}

	void render();

	void updateGlow(bool newGlow) {
		if(glow != newGlow) {
			dirty = true;
		}
		glow = newGlow;
	}

	/**
	 * Returns a map of data for the entity with the id provided (in element provided, or found if not)
	 * "alldisabled" (bool) -> true if every action is disabled, false otherwise
	 * "actions" (List<List>) -> terrible and ready for a right click menu
	 */
	Map<String, dynamic> getActions(String id) {
		List<List> menuActions = [];
		bool allDisabled = true;

		actions.forEach((Action action) {
			bool enabled = action.enabled;
			if(enabled) {
				allDisabled = false;
			}

			String error = "";
			List<Map> requires = [];
			action.itemRequirements.all.forEach((String item, int num) => requires.add({'num':num, 'of':[item]}));
			if(action.itemRequirements.any.length > 0) {
				requires.add({'num':1, 'of':action.itemRequirements.any});
			}
			enabled = hasRequirements(requires);
			if(enabled) {
				error = action.description;
			} else {
				error = getRequirementString(requires);
			}

			menuActions.add([capitalizeFirstLetter(action.action) + "|" + action.actionWord + "|${action.timeRequired}|$enabled|$error|${action.multiEnabled}", id, "sendAction ${action.action} $id|${action.associatedSkill}"]);
		});

		return {"actions": menuActions, "alldisabled": allDisabled};
	}

	void interact(String id) {
		Element element = querySelector("#$id");
		Map<String, dynamic> actions = getActions(id);

		if(!actions["alldisabled"]) {
			inputManager.showClickMenu(null, element.attributes['type'], "Desc", actions["actions"]);
		}
	}
}