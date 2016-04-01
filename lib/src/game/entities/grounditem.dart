part of couclient;

class GroundItem extends Entity {
	GroundItem(Map map) {
		ImageElement item = new ImageElement(src:map['iconUrl']);
		item.onLoad.first.then((_) {
			left = map['x'];
			top = map['y'];
			width = item.width;
			height = item.height;
			id = map['id'];

			item.style.transform = "translateX(${map['x']}px) translateY(${map['y']}px)";
			item.style.position = "absolute";
			item.attributes['translatex'] = map['x'].toString();
			item.attributes['translatey'] = map['y'].toString();
			item.attributes['width'] = item.width.toString();
			item.attributes['height'] = item.height.toString();
			item.attributes['type'] = map['name'];
			item.attributes['description'] = map['description'];
			item.attributes['actions'] = JSON.encode(map['actions']);
			item.classes.add('groundItem');
			item.classes.add('entity');
			item.id = map['id'];
			view.playerHolder.append(item);
			addingLocks[id] = false;
		});
	}

	render() {
	}

	@override
	void interact(String id) {
		Element element = querySelector("#$id");
		List<List> actions = [];

		if(element.attributes['actions'] != null) {
			List<Action> actionsList = decode(element.attributes['actions'], type: const TypeHelper<List<Action>>().type);
			bool enabled = false;
			actionsList.forEach((Action action) {
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
				actions.add([
					            capitalizeFirstLetter(action.name) + '|' +
					            '|0|$enabled|$error|${action.multiEnabled}',
					            id,
					            "sendAction ${action.name} $id",
				            ]);
			});
		}

		inputManager.showClickMenu(null, element.attributes['type'], element.attributes['description'], actions, itemName:element.attributes['type']);
	}
}