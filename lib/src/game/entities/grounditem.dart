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
			item.attributes['type'] = map['name'];
			item.attributes['description'] = map['description'];
			item.attributes['actions'] = JSON.encode(map['actions']);
			item.classes.add('groundItem');
			item.classes.add('entity');
			item.id = id;
			view.playerHolder.append(item);
			addingLocks[id] = false;
		});
	}

	render() {
	}

	@override
	void interact(String id) {
		Element element = querySelector("#$id");
		List<List> menuActions = [];

		bool enabled = false;
		actions.forEach((Action action) {
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
			menuActions.add([
							capitalizeFirstLetter(action.action) + '|' +
							'|0|$enabled|$error|${action.multiEnabled}',
							id,
							"sendAction ${action.action} $id",
						]);
		});

		inputManager.showClickMenu(null, element.attributes['type'], element.attributes['description'], menuActions, itemName:element.attributes['type']);
	}
}