part of couclient;

Entity getEntity(String id) {
	return entities[id] ?? otherPlayers[id];
}

Element getEntityElement(String id) {
	return querySelector('#$id') ?? querySelector('#player-$id');
}

abstract class Entity {
	Random rand = new Random();

	bool glow = false;
	bool dirty = true;
	bool multiUnselect = false;

	ChatBubble chatBubble = null;

	CanvasElement canvas;

	num left = 0;
	num top = 0;
	num z = 0;
	num width = 0;
	num height = 0;

	String id;

	MutableRectangle _entityRect = new MutableRectangle(0, 0, 0, 0);
	MutableRectangle _destRect;

	EntityActionLoader actionLoader;

	Entity(String id) {
		if (id != null) {
			actionLoader = new EntityActionLoader(id);
		}
	}

	set actions(List<Action> value) {
		actionLoader.actions = value;
	}

	void update(double dt) {
		if (this != CurrentPlayer && CurrentPlayer.entityRect.intersects(this.entityRect)) {
			updateGlow(true);
			CurrentPlayer.intersectingObjects[id] = this.entityRect;
			actionLoader?.download();
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
		return await actionLoader.download();
	}

	void interact(String id) {
		Element element = querySelector('#$id') ?? querySelector('#player-$id');

		getActions().then((List<Action> actions) {
			String name = element.attributes['type'] ?? id;
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

class EntityActionLoader {
	String entity;

	Completer<List<Action>> _load;
	DateTime _age;
	List<Action> _actions = [];

	set actions(List<Action> value) {
		_actions = _parseActions(value);
		_age = new DateTime.now();
	}

	List<Action> get actions => _actions;

	EntityActionLoader(this.entity);

	Future<List<Action>> download() async {
		if (_actionsExist && !_expired) {
			// Use preloaded actions
			return actions;
		} else {
			// Download actions from server
			_load = new Completer();
			List<Action> actionList = decode(await HttpRequest.requestCrossOrigin(_url),
				type: const TypeHelper<List<Action>>().type);

			// Remove old actions
			actions.clear();

			// Create new menu actions
			actions = _parseActions(actionList);

			// Mark as downloaded
			_age = new DateTime.now();
			_load.complete(actions);
			return actions;
		}
	}

	List<Action> _parseActions(List<Action> actionList) {
		List<Action> actions = [];

		for (Action action in actionList) {
			bool enabled = action.enabled;
			String error = '';
			action.actionName = capitalizeFirstLetter(action.actionName);

			if (enabled) {
				enabled = hasRequirements(action);

				if (enabled) {
					error = action.description;
				} else {
					error = getRequirementString(action);
				}
			} else {
				error = action.error;
			}

			actions.add(new Action.clone(action)
				..enabled = enabled
				..error = error);
		}

		return actions;
	}

	bool get _actionsExist => actions.length > 0;

	bool get _expired {
		if (_age == null) {
			return true;
		} else {
			return new DateTime.now()
				.difference(_age)
				.abs()
				.inSeconds > 30;
		}
	}

	String get _url => 'http://${Configs.utilServerAddress}/getActions'
		'?email=${game.email}'
		'&id=$entity'
		'&label=${currentStreet.label}';
}