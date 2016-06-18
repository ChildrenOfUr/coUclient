part of couclient;

Entity getEntity(String id) {
	return entities[id] ?? otherPlayers[id];
}

Element getEntityElement(String id) {
	return querySelector('#$id') ?? querySelector('#player-$id');
}

void sortEntities() {
	List<Element> elements = [];
	entities.values.forEach((Entity entity) {
		if (entity.canvas != null) {
			elements.add(entity.canvas);
		}
	});
	elements.sort((Element a, Element b) {
		if (entities[a.id] == null || entities[b.id] == null) {
			return 0;
		}
		return entities[a.id].top.compareTo(entities[b.id].top);
	});
	for (Element e in elements) {
		view.playerHolder.append(e);
	}
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
	 * Returns a map of data for the entity
	 * 'alldisabled' (bool) -> true if every action is disabled, false otherwise
	 * 'actions' (List<List>) -> terrible and ready for a right click menu
	 */
	Map<String, dynamic> getActions() {
		List<List> menuActions = [];
		bool allDisabled = true;
		String actionEntity = (this is Player ? 'global_action_monster' : this.id);

		actions.forEach((Action action) {
			bool enabled = action.enabled;
			String error = '';
			if (enabled) {
				allDisabled = false;
				enabled = hasRequirements(action);
				if (enabled) {
					error = action.description;
				} else {
					error = getRequirementString(action);
				}
			} else {
				error = action.error;
			}

			menuActions.add([
				capitalizeFirstLetter(action.actionName) + '|' + action.actionWord + '|${action.timeRequired}|$enabled|$error|${action.multiEnabled}',
				actionEntity,
				'sendAction ${action.actionName} $actionEntity|${action.associatedSkill}'
			]);
		});

		return {'actions': menuActions, 'alldisabled': allDisabled};
	}

	void interact(String id) {
		Element element = querySelector('#$id') ?? querySelector('#player-$id');
		Map<String, dynamic> actions = getActions();

		if (!actions['alldisabled']) {
			inputManager.showClickMenu(null, element.attributes['type'] ?? id, 'Desc', actions['actions']);
		}
	}

	@override
	int get hashCode => id.hashCode;

	@override
	operator ==(Entity other) {
		return (other.id == this.id);
	}
}
