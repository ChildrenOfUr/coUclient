part of couclient;

class InteractionWindow {
	static List<String> shrineTypes = [
		"Alph", "Cosma", "Friendly", "Grendaline", "Humbaba", "Lem", "Mab", "Pot", "Spriggan", "Tii", "Zille"
	];
	static Element create() {
		DivElement interactionWindow = new DivElement()
			..id = "InteractionWindow"
			..className = "interactionWindow";

		DivElement header = new DivElement()
			..className = "PopWindowHeader handle";
		SpanElement title = new SpanElement()
			..id = "InteractionTitle"
			..text = "Interact with...";
		header.append(title);

		DivElement content = new DivElement()
			..id = "InteractionContent";

		interactionWindow
			..append(header)
			..append(content);

		for(String id in CurrentPlayer.intersectingObjects.keys) {
			DivElement container = new DivElement()
				..style.display = "inline-block"
				..style.textAlign = "center"
				..classes.add("entityContainer");
			Element entityOnStreet = querySelector("#$id");
			Element entityInBubble;

			if (entityOnStreet.id.contains("pole")) {

				// Signpost image already loaded
				entityInBubble = new ImageElement()..src = "files/system/icons/signpost.svg";

			} else if (entityOnStreet is CanvasElement){

				// Provide static image for entities with states
				String entityName = entityOnStreet.attributes["type"];
				if (entityName.contains("Street Spirit")) {
					entityInBubble = new ImageElement()..src = "files/system/icons/currant.svg";
				} else if (shrineTypes.contains(entityName)) {
					entityInBubble = new ImageElement()..src = "files/system/icons/shrine.svg";
				} else {
					entityInBubble = new ImageElement()..src = "http://childrenofur.com/assets/staticEntityImages/$entityName.png";
				}

			} else if (entityOnStreet is ImageElement) {

				// Dropped item, use its image
				entityInBubble = new ImageElement()..src = entityOnStreet.src;

			}

			// Find a title
			if (entityOnStreet.attributes["type"] != null) {
				container.title = entityOnStreet.attributes["type"];
			}

			// Use the same id
			entityInBubble.attributes['id'] = id;
			entityInBubble.classes.add('entityInBubble');
			entities[id].multiUnselect = true;

			// Insert entity into bubble
			container.append(entityInBubble);

			// Select entities with mouse
			container.onMouseOver.listen((_) {
				content.children.forEach((Element child) {
					if(child != container) {
						entities[child.children.first.id].multiUnselect = true;
						child.classes.remove("entitySelected");
					}
				});
				entities[id].multiUnselect = false;
				container.classes.add("entitySelected");
			});

			// Use selected entity
			container.onClick.first.then((MouseEvent e) {
				e.stopPropagation();
				inputManager.stopMenu(interactionWindow);
				entities[id].interact(id);
			});

			// Entity has no available actions
			try {
				if (entities[id].getActions(id)["alldisabled"]) {
					container.classes.add("disabled");
				}
			} catch (_) {
				// Item was not an entity, so it doesn't matter
			}

			// Display
			content.append(container);
		}

		entities[content.children.first.children.first.id].multiUnselect = false;
		content.children.first.classes.add("entitySelected");

		inputManager.menuKeyListener = document.onKeyDown.listen((KeyboardEvent k) {
			Map keys = inputManager.keys;
			bool ignoreKeys = inputManager.ignoreKeys;
			//up arrow or w and not typing
			if((k.keyCode == keys["UpBindingPrimary"] || k.keyCode == keys["UpBindingAlt"]) && !ignoreKeys) {
				inputManager.stopMenu(interactionWindow);
			}
			//down arrow or s and not typing
			if((k.keyCode == keys["DownBindingPrimary"] || k.keyCode == keys["DownBindingAlt"]) && !ignoreKeys) {
				inputManager.stopMenu(interactionWindow);
			}
			//left arrow or a and not typing
			if((k.keyCode == keys["LeftBindingPrimary"] || k.keyCode == keys["LeftBindingAlt"]) && !ignoreKeys) {
				inputManager.selectUp(content.querySelectorAll('.entityContainer'), "entitySelected");
				querySelectorAll('.entityInBubble:not(.entitySelected)').forEach((Element entity) {
					entities[entity.id].multiUnselect = true;
				});
				entities[querySelector('.entitySelected').children.first.id].multiUnselect = false;
			}
			//right arrow or d and not typing
			if((k.keyCode == keys["RightBindingPrimary"] || k.keyCode == keys["RightBindingAlt"]) && !ignoreKeys) {
				inputManager.selectDown(content.querySelectorAll('.entityContainer'), "entitySelected");
				querySelectorAll('.entityInBubble:not(.entitySelected)').forEach((Element entity) {
					entities[entity.id].multiUnselect = true;
				});
				entities[querySelector('.entitySelected').children.first.id].multiUnselect = false;
			}
			//spacebar and not typing
			if((k.keyCode == keys["JumpBindingPrimary"] || k.keyCode == keys["JumpBindingAlt"]) && !ignoreKeys) {
				inputManager.stopMenu(interactionWindow);
			}
			//enter and not typing
			if((k.keyCode == keys["ActionBindingPrimary"] || k.keyCode == keys["ActionBindingAlt"]) && !ignoreKeys) {
				inputManager.stopMenu(interactionWindow);
				String id = content.querySelector('.entitySelected').children.first.attributes['id'];
				entities[id].interact(id);
			}
		});
		document.onKeyUp.listen((KeyboardEvent k) {
			if(k.keyCode == 27) {
				inputManager.stopMenu(interactionWindow);
			}
		});
		document.onClick.listen((_) => inputManager.stopMenu(interactionWindow));

		//when the menu is closed, let's allow all entities to glow like normal again
		new Service('menuStopping', (_) {
			entities.values.forEach((Entity entity) => entity.multiUnselect = false);
		});

		return interactionWindow;
	}

	static void destroy() {
		querySelector("#InteractionWindow").remove();
	}
}