part of couclient;

Entity getEntity(String id) {
	return entities[id] ?? otherPlayers[id];
}

Element getEntityElement(String id) {
	return querySelector('#$id') ?? querySelector('#player-$id');
}

abstract class Entity {
	Random rand = new Random();

	bool
		glow = false,
		dirty = true,
		multiUnselect = false;

	ChatBubble chatBubble = null;

	CanvasElement canvas;

	num
		left = 0,
		top = 0,
		z = 0,
		width = 0,
		height = 0;

	String id;

	MutableRectangle
		_entityRect = new MutableRectangle(0, 0, 0, 0),
		_destRect;

	List<Action> actions = [];

	void update(double dt) {
		if (this != CurrentPlayer && CurrentPlayer.entityRect.intersects(this.entityRect)) {
			updateGlow(true);
			CurrentPlayer.intersectingObjects[id] = this.entityRect;
		} else {
			CurrentPlayer.intersectingObjects.remove(id);
			updateGlow(false);
		}
	}

	Rectangle get destRect {
		if (_destRect == null) {
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
		if (_entityRect == null) {
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
		if (multiUnselect) {
			glow = false;
			dirty = true;
			return;
		}

		if (glow != newGlow) {
			dirty = true;
		}
		glow = newGlow;
	}

	/**
	 * Returns a list of actions which currently applies to the player and the entity
	 */
	Future<List<Action>> getActions() async {
		bool enabled = false;
		String url = 'http://${Configs.utilServerAddress}/getActions';
		url += '?email=${game.email}&id=$id&label=${currentStreet.label}';
		List<Action> actionList = [];
		actions = decode(await HttpRequest.requestCrossOrigin(url),
											 type: const TypeHelper<List<Action>>().type);
		actions.forEach((Action action) {
			enabled = action.enabled;
			action.actionName = capitalizeFirstLetter(action.actionName);
			String error = "";
			if(enabled) {
				enabled = hasRequirements(action);
				if(enabled) {
					error = action.description;
				} else {
					error = getRequirementString(action);
				}
			} else {
				error = action.error;
			}
			Action menuAction = new Action.clone(action)
				..enabled = enabled
				..error = error;
			actionList.add(menuAction);
		});

		return actionList;
	}

	void interact(String id) {
		Element element = querySelector('#$id') ?? querySelector('#player-$id');

		getActions().then((List<Action> actions) {
			String name = element.dataset['name-override'] ?? element.attributes['type'] ?? id;
			String serverClass = (this is Player ? 'global_action_monster' : name);
			inputManager.showClickMenu(title: name, id: id, serverClass: serverClass, actions: actions);
		});
	}

	@override
	int get hashCode => id.hashCode;

	@override
	operator ==(Entity other) {
		return (other.id == this.id);
	}
}
