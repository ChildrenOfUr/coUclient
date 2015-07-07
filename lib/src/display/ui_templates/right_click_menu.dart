part of couclient;

class RightClickMenu {
	static Element create(MouseEvent Click, String title, String description, List<List> options, {String itemName: ''}) {
		destroy();
		DivElement menu = new DivElement()
			..id = "RightClickMenu";
		DivElement infoButton = new DivElement()
			..id = "openItemWindow"
			..className = "InfoButton fa fa-info-circle"
			..onClick.listen((_) {
			new ItemWindow().displayItem(itemName);
		});
		SpanElement titleElement = new SpanElement()
			..id = "ClickTitle"
			..text = title;
		DivElement actionList = new DivElement()
			..id = "RCActionList";

		if(itemName != '') {
			infoButton.setAttribute('item-name', itemName);
		}

		if(itemName != '') {
			menu.append(infoButton);
		}
		menu.append(titleElement);
		menu.append(actionList);

		int x, y;

		List <Element> newOptions = new List();
		for(List option in options) {
			DivElement wrapper = new DivElement()
				..className = 'action_wrapper';
			DivElement tooltip = new DivElement()
				..className = 'action_error_tooltip';
			DivElement menuitem = new DivElement();
			menuitem
				..classes.add('RCItem')
				..text = (option[0] as String).split("|")[0];

			if((option[0] as String).split("|")[3] == "true") {
				menuitem.onClick.listen((_) async {
					int timeRequired = int.parse((option[0] as String).split("|")[2]);

					ActionBubble actionBubble = new ActionBubble(option, timeRequired);
					await actionBubble.wait;

					Map arguments = null;
					if(option.length > 3) {
						arguments = option[3];
					}
					sendAction((option[0] as String).split("|")[0].toLowerCase(), option[1], arguments);
				});

				menuitem.onMouseOver.listen((e) {
					e.target.classes.add("RCItemSelected");
				});

				menuitem.onMouseOut.listen((e) {
					e.target.classes.remove("RCItemSelected");
				});

				document.onKeyUp.listen((KeyboardEvent k) {
					if(k.keyCode == 27) {
						destroy();
					}
				});
			} else {
				menuitem.classes.add('RCItemDisabled');
			}

			showActionError(tooltip, (option[0] as String).split("|")[4]);

			wrapper.append(menuitem);
			wrapper.append(tooltip);
			newOptions.add(wrapper);
		}
		if(newOptions.length > 0 && !newOptions[0].children[0].classes.contains("RCItemDisabled")) {
			newOptions[0].children[0].classes.toggle("RCItemSelected");
		}

		document.body.append(menu);
		if(Click != null) {
			if(Click.page.y > window.innerHeight / 2) {
				y = Click.page.y - menu.clientHeight;
			} else {
				y = Click.page.y - 10;
			}
			if(Click.page.x > window.innerWidth / 2) {
				x = Click.page.x - 120;
			} else {
				x = Click.page.x - 10;
			}
		} else {
			num posX = CurrentPlayer.posX, posY = CurrentPlayer.posY;
			int width = CurrentPlayer.width, height = CurrentPlayer.height;
			num translateX = posX, translateY = view.worldElement.clientHeight - height;
			if(posX > currentStreet.bounds.width - width / 2 - view.worldElement.clientWidth / 2) {
				translateX = posX - currentStreet.bounds.width + view.worldElement.clientWidth;
			} else if(posX + width / 2 > view.worldElement.clientWidth / 2) {
				translateX = view.worldElement.clientWidth / 2 - width / 2;
			}
			if(posY + height / 2 < view.worldElement.clientHeight / 2) {
				translateY = posY;
			} else if(posY < currentStreet.bounds.height - height / 2 - view.worldElement.clientHeight / 2) {
				translateY = view.worldElement.clientHeight / 2 - height / 2;
			} else {
				translateY = view.worldElement.clientHeight - (currentStreet.bounds.height - posY);
			}
			x = (translateX + menu.clientWidth + 10) ~/ 1;
			y = (translateY + height / 2) ~/ 1;
		}

		actionList.children.addAll(newOptions);
		menu.style
			..opacity = '1.0'
			..position = 'absolute'
			..top = '$y' 'px'
			..left = '$x' 'px';

		document.onClick.first.then((_) => destroy());
		return menu;
	}

	static void showActionError(Element tooltip, String errorText) {
		tooltip.hidden = errorText == '';
		tooltip.text = errorText;
	}

	static void destroy() {
		Element menu = querySelector("#RightClickMenu");
		if(menu != null) {
			menu.remove();
		}
	}
}