part of couclient;

class InteractionWindow {
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
				entityInBubble = new ImageElement()
					..src = "files/system/icons/signpost.svg";
			} else {
				// Provide static image for entities with states
				entityInBubble = new ImageElement()
					..src = "http://childrenofur.com/assets/staticEntityImages/${entityOnStreet.attributes["type"]}.png";
			}

			if (entityOnStreet is CanvasElement) {
				(entityInBubble as CanvasElement).context2D.drawImage(entityOnStreet, 0, 0);
				entityInBubble.style.zIndex = null;
			}
			entityInBubble.style
				..transform = ""
				..position = ""
				..display = "block"
				..margin = "auto";
			if (
			entityInBubble.attributes != null &&
			entityInBubble.attributes["type"] != null &&
			entityInBubble.attributes["type"] != ""
			) {
				entityInBubble.title = entityInBubble.attributes["type"];
				entityInBubble.style.cursor = "help";
			}
			entityInBubble.attributes['id'] = id;
			container.append(entityInBubble);
			container.onMouseOver.listen((_) {
				content.children.forEach((Element child) {
					if(child != container) {
						child.classes.remove("entitySelected");
					}
				});
				container.classes.add("entitySelected");
			});
			container.onClick.first.then((MouseEvent e) {
				e.stopPropagation();
				inputManager.stopMenu(interactionWindow);
				entities[id].interact(id);
			});
			content.append(container);
		}

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
			}
			//right arrow or d and not typing
			if((k.keyCode == keys["RightBindingPrimary"] || k.keyCode == keys["RightBindingAlt"]) && !ignoreKeys) {
				inputManager.selectDown(content.querySelectorAll('.entityContainer'), "entitySelected");
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

		return interactionWindow;
	}

	static void destroy() {
		querySelector("#InteractionWindow").remove();
	}
}