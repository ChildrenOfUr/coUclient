part of couclient;

class MenuOption {
	String uiName, serverName, errorText, itemType;
	int timeRequired;
	bool enabled;
	Map dropMap;
}

class RightClickMenu {
	static final String
		ACTION_LIST_PARENT_ID = 'RCActionList',
		MENU_CLASS = 'RightClickMenu',
		MENU_INFO_CLASSES = 'InfoButton fa fa-info-circle',
		MENU_TITLE_ID = 'ClickTitle',
		MENU_VISIBLE_OPACITY = '1.0',
		OPTION_BUTTON_CLASS = 'RCItem',
		OPTION_DISABLED_CLASS = 'RCItemDisabled',
		OPTION_SELECTED_CLASS = 'RCItemSelected',
		OPTION_TOOLTIP_CLASS = 'action_error_tooltip',
		OPTION_WRAPPER_CLASS = 'action_wrapper';

	static bool _waiting = false;

	static void opening([int delay = 0]) {
		_waiting = true;

		new Future.delayed(new Duration(seconds: delay)).then((_) {
			if (_waiting) {
				document.body.classes.add('wait');
			}
		});
	}

	static void opened() {
		_waiting = false;
		document.body.classes.remove('wait');
	}

	static Element create3(
		MouseEvent click, String title, String entityId,
		{String serverClass, String description, List<Action> actions, Function onInfo, ItemDef item, String itemName}
	) {
		Point<int> _positionMenu(DivElement menu) {
			int x, y;

			if (click != null) {
				// Position at cursor

				x = click.client.x - (menu.clientWidth ~/ 2);
				y = click.client.y - (40 + (actions.length * 30));
			} else {
				// Position at player

				num playerX = CurrentPlayer.left,
					playerY = CurrentPlayer.top;

				int playerWidth = CurrentPlayer.width,
					playerHeight = CurrentPlayer.height;

				num translateX = playerX,
					translateY = view.worldElement.clientHeight - playerHeight;

				int streetWidth = currentStreet.bounds.width,
					streetHeight = currentStreet.bounds.height;

				int worldHeight = view.worldElement.clientHeight,
					worldWidth = view.worldElement.clientWidth;

				if (playerX > streetWidth - playerWidth / 2 - worldWidth / 2) {
					translateX = playerX - streetWidth + worldWidth;
				} else if (playerX + playerWidth / 2 > worldWidth / 2) {
					translateX = worldWidth / 2 - playerWidth / 2;
				}

				if (playerY + playerHeight / 2 < worldHeight / 2) {
					translateY = playerY;
				} else if (playerY < streetHeight - playerHeight / 2 - worldHeight / 2) {
					translateY = worldHeight / 2 - playerHeight / 2;
				} else {
					translateY = worldHeight - (streetHeight - playerY);
				}

				x = (translateX + menu.clientWidth + 10) ~/ 1;
				y = (translateY + playerHeight / 2) ~/ 1;
			}

			return new Point(x, y);
		}

		List<Element> _makeOptions(DivElement menu) {
			List<Element> options = [];

			// Keyboard selection
			bool useKeys = (actions.length <= 10);
			int keyIndex = 1;

			// Create option elements
			for (Action action in actions) {
				// Option tooltip
				DivElement optionTooltip = new DivElement()
					..classes = [OPTION_TOOLTIP_CLASS];

				// Option button
				DivElement option = new DivElement()
					..classes = [OPTION_BUTTON_CLASS]
					..text = (useKeys ? '$keyIndex: ' : '') + action.actionName;

				// Option element wrapper (option + tooltip)
				DivElement optionWrapper = new DivElement()
					..classes = [OPTION_WRAPPER_CLASS]
					..append(option)
					..append(optionTooltip);

				// Register keyboard shortcut listener
				if (useKeys) {
					MenuKeys.addListener(keyIndex, () {
						// When this option's number key pressed
						if (click != null) {
							// Recreate mouse click
							option.dispatchEvent(new MouseEvent(
								'click', clientX: click.client.x, clientY: click.client.y));
						} else {
							// Simulate mouse click
							option.click();
						}
					});
				}

				if (action.enabled) {
					// Attach click listeners to enabled actions
					option.onClick.listen((MouseEvent event) async {
						String functionName = action.actionName.toLowerCase();

						Function doClick = ({int howMany: 1}) async {
							bool completed = true;

							// Wait for actions to complete
							if (action.timeRequired > 0) {
								ActionBubble actionBubble = new ActionBubble.withAction(action);
								completed = await actionBubble.wait;
							}

							if (completed) {
								// Action completed
								Map<String, dynamic> arguments = {};

								if (action.dropMap != null) {
									arguments = action.dropMap;
								}

								// Accepts multiple items
								if (action.multiEnabled) {
									arguments['count'] = howMany;
								}

								if (functionName == 'pickup' && howMany > 1) {
									// Picking up multiple items
									List<String> objects = CurrentPlayer.intersectingObjects.keys.toList();
									objects.removeWhere((String id) {
										return (querySelector('#$id').attributes['name'] != (itemName ?? item.name));
									});
									arguments['pickupIds'] = objects;
									arguments.remove('count');
									sendGlobalAction(functionName, arguments);
								} else if (serverClass == "global_action_monster") {
									sendGlobalAction(functionName, {"player": entityId});
								} else {
									// Other action
									if (item != null) {
										arguments['itemdata'] = item.metadata;
									}

									sendAction(functionName, entityId, arguments);
								}
							}
						};

						if (action.multiEnabled) {
							int max = 0;
							String itemToCount = '';
							try {
								itemToCount = action?.itemRequirements?.all?.keys?.first;
							} catch (_) {}
							if (itemToCount != '') {
								max = _getNumItems(itemToCount);
								itemName = itemToCount;
							}

							if (item != null) {
								int slot = -1, subSlot = -1;

								if (action.dropMap != null) {
									slot = action.dropMap['slot'];
									subSlot = action.dropMap['subSlot'];
								}

								// Count in inventory
								max = _getNumItems(item.itemType, slot: slot, subSlot: subSlot);
							}

							// Picking up an item
							if (functionName == 'pickup') {
								// Count on ground
								max = CurrentPlayer.intersectingObjects.keys.where((String id) {
									return (querySelector('#$id').attributes['name'] == itemName);
								}).toList().length;
							}

							if (max == 1) {
								// Don't show the how many menu if there is only one item
								doClick();
							} else {
								// Open the how many menu
								HowManyMenu.create(event, functionName, max, doClick, itemName: itemName ?? item.name);
							}
						}else {
							doClick();
						}
					});

					// Select option with mouse
					option.onMouseOver.listen((MouseEvent event) {
						(event.target as Element).classes.add(OPTION_SELECTED_CLASS);
					});

					// Deselect option with mouse
					option.onMouseOut.listen((MouseEvent event) {
						(event.target as Element).classes.remove(OPTION_SELECTED_CLASS);
					});
				} else {
					// Mark disabled options
					option.classes.add(OPTION_DISABLED_CLASS);
					option.onClick.listen((_) {
						new Toast(action.error);
					});
				}

				// Initialize tooltip
				showActionError(optionTooltip, action.error);

				// Add element to menu
				options.add(optionWrapper);

				// Increment keyboard shortcut number
				keyIndex++;
			}

			if (options.length == 1) {
				// Pre-select only option
				options.single.children.first.classes.add(OPTION_SELECTED_CLASS);
			} else if (options.length > 1) {
				// Pre-select option, and wrap around controls
				menu.onKeyPress.listen((KeyboardEvent event) {
					//print('pressed ${event.keyCode}');
					if (event.keyCode == 40) {
						// Down arrow
						options.first.children.first
							.classes.toggle(OPTION_SELECTED_CLASS);
					} else if (event.keyCode == 38) {
						// Up arrow
						options.first.children[actions.length]
							.classes.toggle(OPTION_SELECTED_CLASS);
					}
				});
			}

			return options;
		}

		opening();

		// Close any other menu
		destroy();

		// Title display
		SpanElement titleText = new SpanElement()
			..id = MENU_TITLE_ID
			..text = title;

		// Info button
		DivElement infoBtn = new DivElement()
			..className = MENU_INFO_CLASSES
			..hidden = (onInfo == null)
			..onClick.listen((MouseEvent event) => onInfo(event));

		// Action button list parent
		DivElement optionParent = new DivElement()
			..id = ACTION_LIST_PARENT_ID;

		// Assemble menu parent element
		DivElement menuParent = new DivElement()
			..id = MENU_CLASS
			..append(titleText)
			..append(infoBtn)
			..append(optionParent);

		// Add options to list
		for (Element option in _makeOptions(menuParent)) {
			optionParent.append(option);
		}

		// Hide menu when clicking away from it
		document.onClick.first.then((_) => destroy());

		// Hide menu when escape key pressed
		document.onKeyUp.listen((KeyboardEvent event) {
			if (event.keyCode == 27) {
				destroy();
			}
		});

		// Render menu to begin positioning
		document.body.append(menuParent);

		// Position menu at call location
		Point<int> menuPos = _positionMenu(menuParent);
		menuParent.style.transform = 'translateX(${menuPos.x}px) translateY(${menuPos.y}px)';

		// Show menu
		menuParent.style.opacity = MENU_VISIBLE_OPACITY;

		opened();

		// Return reference to menu element
		return menuParent;
	}

	static Element create2(MouseEvent click, String title, List<Map> options,
		{String description: '', String itemName: ''}) {
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

		opening();

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

		List<Element> newOptions = new List();
		for (Map option in options) {
			DivElement wrapper = new DivElement()
				..className = "action_wrapper";
			DivElement tooltip = new DivElement()
				..className = "action_error_tooltip";
			DivElement menuitem = new DivElement();
			menuitem
				..classes.add("RCItem")
				..text = option["name"];

			if (option["enabled"]) {
				menuitem.onClick.listen((_) async {
					int timeRequired = option["timeRequired"];

					bool completed = true;
					if (timeRequired > 0) {
						ActionBubble actionBubble = new ActionBubble(option['name'], timeRequired, option["associatedSkill"]);
						completed = await actionBubble.wait;
					}

					if (completed) {
						Map arguments = null;
						if (option["arguments"] != null) {
							arguments = option["arguments"];
						}

						if (option.containsKey('serverCallback')) {
							sendAction(option["serverCallback"].toLowerCase(), option["entityId"], arguments);
						}
						if (option.containsKey('clientCallback')) {
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
					if (k.keyCode == 27) {
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
			if (newOptions.length > 1) {
				menu.onKeyPress.listen((e) {
					if (e.keyCode == 40) {
						// down arrow
						newOptions[0].children[0].classes.toggle("RCItemSelected");
					}
					if (e.keyCode == 38) {
						// up arrow
						newOptions[0].children[newOptions.length].classes.toggle("RCItemSelected");
					}
				});
			} else if (newOptions.length == 1) {
				newOptions[0].children[0].classes.toggle("RCItemSelected");
			}
		}

		document.body.append(menu);
		if (click != null) {
			x = click.page.x - (menu.clientWidth ~/ 2);
			y = click.page.y - (40 + (options.length * 30));
		} else {
			num posX = CurrentPlayer.left,
				posY = CurrentPlayer.top;
			int width = CurrentPlayer.width,
				height = CurrentPlayer.height;
			num translateX = posX,
				translateY = view.worldElement.clientHeight - height;
			if (posX > currentStreet.bounds.width - width / 2 - view.worldElement.clientWidth / 2) {
				translateX = posX - currentStreet.bounds.width + view.worldElement.clientWidth;
			} else if (posX + width / 2 > view.worldElement.clientWidth / 2) {
				translateX = view.worldElement.clientWidth / 2 - width / 2;
			}
			if (posY + height / 2 < view.worldElement.clientHeight / 2) {
				translateY = posY;
			} else if (posY < currentStreet.bounds.height - height / 2 - view.worldElement.clientHeight / 2) {
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
		opened();
		return menu;
	}

	static void showActionError(Element tooltip, String errorText) {
		tooltip.hidden = errorText == '';
		tooltip.text = errorText;
	}

	static int destroy() {
		int destroyed = 0;
		Element menu;

		do {
			menu = querySelector("#RightClickMenu");

			if (menu != null) {
				menu.remove();
				MenuKeys.clearListeners();
				transmit("right_click_menu", "destroy");
				destroyed++;
			}

			menu = querySelector("#RightClickMenu");
		} while (menu != null);

		return destroyed;
	}
}
