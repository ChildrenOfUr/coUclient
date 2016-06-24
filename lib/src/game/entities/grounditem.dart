part of couclient;

class GroundItem extends Entity {
	GroundItem(Map map) {
		if (map.containsKey('actions')) {
			actions = decode(JSON.encode(map['actions']), type: const TypeHelper<List<Action>>().type);
		}

		ImageElement item = new ImageElement(src:map['iconUrl']);
		item.onLoad.first.then((_) {
			left = map['x'];
			top = map['y'] - item.height;
			width = item.width;
			height = item.height;
			id = map['id'];

			item.style.transform = "translateX(${left}px) translateY(${top}px)";
			item.style.position = "absolute";
			item.attributes['translatex'] = left.toString();
			item.attributes['translatey'] = top.toString();
			item.attributes['width'] = item.width.toString();
			item.attributes['height'] = item.height.toString();
			item.attributes['itemType'] = map['itemType'];
			item.attributes['name'] = map['name'];
			item.attributes['description'] = map['description'];
			item.attributes['actions'] = JSON.encode(map['actions']);
			item.classes.add('groundItem');
			item.classes.add('entity');
			item.id = id;
			view.playerHolder.append(item);
			sortEntities();
			addingLocks[id] = false;
		});
	}

	render() {
	}

	@override
	void interact(String id) {
		Element element = querySelector("#$id");
		List<Action> actionList = [];

		bool enabled = false;
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

		inputManager.showClickMenu(null, element.attributes['name'], element.attributes['description'], id, actionList);
	}
}