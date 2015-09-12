part of couclient;

class RightClickMenu {

	static Element create2(MouseEvent click, String title, List<Map> options, {String description: '', String itemName: ''}) {
		/**
		 * title: main text shown at the top
		 *
		 * description: smaller text, shown under title
		 *
		 * options:
		 * [
		 *   {
		 *     "name": <name of option shown in list>,
		 *     "description": <description in tooltip>,
		 *     "enabled": <true|false, will determine if the option can be selected>,
		 *     "timeRequired": <number, seconds the action takes (instant if not defined)>,
		 *     "serverCallback": <function name for server entity>,
		 *     "clientCallback": <a no-argument function>,
		 *     "entityId": <entity summoning the menu>,
		 *     "arguments": <Map of arguments the option takes>
		 *   },
		 *   ...
		 * ]
		 *
		 * itemName: string of the item selected, will show the (i) button if not null and will open the item info window when the (i) is clicked
		 */

		// allow only one open at a time

		destroy();

		// define parts

		DivElement menu, infoButton, actionList;
		SpanElement titleElement;

		// menu base

		menu = new DivElement()
			..id = "RightClickMenu";

		// main title

		titleElement = new SpanElement()
			..id = "ClickTitle"
			..text = title;

		menu.append(titleElement);

		// show item info window

		if (itemName != '') {
			infoButton = new DivElement()
				..id = "openItemWindow"
				..className = "InfoButton fa fa-info-circle"
				..setAttribute('item-name', itemName)
				..onClick.listen((_) {
					new ItemWindow(itemName).displayItem();
				});
			menu.append(infoButton);
		}

		// actions

		actionList = new DivElement()
			..id = "RCActionList";

		menu.append(actionList);

		// position

		int x, y;

		// options

		List <Element> newOptions = new List();
		for(Map option in options) {
			DivElement wrapper = new DivElement()
				..className = "action_wrapper";
			DivElement tooltip = new DivElement()
				..className = "action_error_tooltip";
			DivElement menuitem = new DivElement();
			menuitem
				..classes.add("RCItem")
				..text = option["name"];

			if(option["enabled"]) {
				menuitem.onClick.listen((_) async {
					int timeRequired = option["timeRequired"];

					bool completed = true;
					if(timeRequired > 0) {
						ActionBubble actionBubble = new ActionBubble(option['name'], timeRequired);
						completed = await actionBubble.wait;
					}

					if(completed) {
						Map arguments = null;
						if(option["arguments"] != null) {
							arguments = option["arguments"];
						}

						if(option.containsKey('serverCallback')) {
							sendAction(option["serverCallback"].toLowerCase(), option["entityId"], arguments);
						}
						if(option.containsKey('clientCallback')) {
							option['clientCallback']();
						}
					}
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

			if (option["description"] != null) {
				showActionError(tooltip, option["description"]);
			}

			wrapper.append(menuitem);
			wrapper.append(tooltip);
			newOptions.add(wrapper);
		}

		// keyboard navigation

		if (!newOptions[0].children[0].classes.contains("RCItemDisabled")) {
			if(newOptions.length > 1) {
				menu.onKeyPress.listen((e) {
					if (e.keyCode == 40) { // down arrow
						newOptions[0].children[0].classes.toggle("RCItemSelected");
					}
					if (e.keyCode == 38) { // up arrow
						newOptions[0].children[newOptions.length].classes.toggle("RCItemSelected");
					}
				});
			} else if (newOptions.length == 1) {
				newOptions[0].children[0].classes.toggle("RCItemSelected");
			}
		}

		document.body.append(menu);
		if(click != null) {
			x = click.page.x - (menu.clientWidth ~/ 2);
			y = click.page.y - (40 + (options.length * 30));
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
			..transform = 'translateX(' + x.toString() + 'px) translateY(' + y.toString() + 'px)';

		document.onClick.first.then((_) => destroy());
		return menu;
	}

	static Element create(MouseEvent Click, String title, String description, List<List> options, {String itemName: ''}) {
		destroy();
		DivElement menu = new DivElement()
			..id = "RightClickMenu";
		DivElement infoButton = new DivElement()
			..id = "openItemWindow"
			..className = "InfoButton fa fa-info-circle"
			..onClick.listen((_) => new ItemWindow(itemName).displayItem());
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

					bool completed = true;
					if(timeRequired > 0) {
						ActionBubble actionBubble = new ActionBubble((option[0] as String).split("|")[1], timeRequired);
						completed = await actionBubble.wait;
					}

					if (timeRequired == -999) {
						// Special value to create a bagify menu
						int invIndex = int.parse((Click.target as Element).parent.dataset["slot-num"]);
						new BagifyMenu(invIndex);
					} else if(completed) {
						// Action completed
						Map arguments = null;
						if(option.length > 3) {
							arguments = option[3];
						}
						sendAction((option[0] as String).split("|")[0].toLowerCase(), option[1], arguments);
					}
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
		if (newOptions.length > 0 &&
		    !newOptions[0].children[0].classes.contains("RCItemDisabled")) {
			if(newOptions.length > 1) {
				menu.onKeyPress.listen((e) {
					if (e.keyCode == 40) { // down arrow
						newOptions[0].children[0].classes.toggle("RCItemSelected");
					}
					if (e.keyCode == 38) { // up arrow
						newOptions[0].children[newOptions.length].classes.toggle("RCItemSelected");
					}
				});
			} else if (newOptions.length == 1) {
				newOptions[0].children[0].classes.toggle("RCItemSelected");
			}
		}

		document.body.append(menu);
		if(Click != null) {
			x = Click.page.x - (menu.clientWidth ~/ 2);
			y = Click.page.y - (40 + (options.length * 30));
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
			..transform = 'translateX(' + x.toString() + 'px) translateY(' + y.toString() + 'px)';

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