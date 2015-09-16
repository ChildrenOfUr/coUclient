part of couclient;

bool _metadataEqual(Map metaA, Map metaB) {
	if ((metaA == null && metaB == null) ||
	    (metaA.isEmpty && metaB.isEmpty)) {
		return true;
	}
	//metadata is only used to store slots right now, so check that
	if (metaA['slots'] != null && metaB['slots'] != null) {
		List<Map> slotsA = metaA['slots'];
		List<Map> slotsB = metaB['slots'];
		if (slotsA.length == slotsB.length) {
			for (int i = 0; i < slotsA.length; i++) {
				Map slotA = slotsA[i];
				Map slotB = slotsB[i];
				if (slotA['itemType'] != slotB['itemType'] ||
				    slotA['count'] != slotB['count']) {
					return false;
				}
			}
		}
	}
	return true;
}

_setupStreetSocket(String streetName) {
	//start a timer for a few seconds and then show the server down message if not canceled
	Timer serverDownTimer = new Timer(new Duration(seconds:2), () {
		querySelector('#server-down').hidden = false;
		serverDown = true;
	});
	streetSocket = new WebSocket(streetEventServer);

	streetSocket.onOpen.listen((_) {
		querySelector('#server-down').hidden = true;
		serverDownTimer.cancel();
		if (serverDown) {
			window.location.reload();
		}
		sendJoinedMessage(streetName);
	});
	streetSocket.onMessage.listen((MessageEvent event) {
		Map map = JSON.decode(event.data);
		if (map['error'] != null) {
			reconnect = false;
			logmessage('[Multiplayer (Street)] Error ${map['error']}');
			streetSocket.close();
			return;
		}

		if (map['label'] != null && currentStreet.label != map['label']) {
			return;
		}

		//check if we are receiving our inventory
		if (map['inventory'] != null) {
			List<Slot> currentSlots = playerInventory.slots;
			int slotNum = 0;
			List<Slot> slots = [];

			//couldn't get the structure to decode correctly so I hacked together this
			//it produces the right result, but looks terrible
			map['slots'].forEach((Map m) {
				Slot slot = new Slot();
				if (!m['itemType'].isEmpty) {
					ItemDef item;
					if (m['item']['metadata']['slots'] == null) {
						item = decode(JSON.encode(m['item']), type:ItemDef);
					} else {
						Map metadata = (m['item'] as Map).remove('metadata');
						item = decode(JSON.encode(m['item']), type:ItemDef);
						item.metadata = metadata;
					}
					slot.item = item;
					slot.itemType = item.itemType;
					slot.count = m['count'];
				}
				slots.add(slot);
				slotNum++;
			});

			playerInventory.slots = slots;

			//if the current inventory differs (count, type, metatdata) then clear it
			//and change it, else leave it alone
			List<Element> uiSlots = querySelectorAll(".box").toList();
			for (int i = 0; i < 10; i++) {
				Slot newSlot = slots.elementAt(i);

				bool updateNeeded = false, update = false;

				//if we've never received our inventory before, update all slots
				if (currentSlots.length == 0) {
					updateNeeded = true;
				} else {
					Slot currentSlot = currentSlots.elementAt(i);

					if (currentSlot.itemType != newSlot.itemType) {
						updateNeeded = true;
					} else if (currentSlot.count != newSlot.count) {
						updateNeeded = true;
						update = true;
					} else if (currentSlot.item != null && newSlot.item != null &&
					            !_metadataEqual(currentSlot.item.metadata, newSlot.item.metadata)) {
						transmit('updateMetadata',newSlot.item);
						continue;
					}
				}

				if (updateNeeded) {
					if(!update) {
						uiSlots.elementAt(i).children.clear();
					}
					for (int j = 0; j < newSlot.count; j++) {
						addItemToInventory(newSlot.item, i, update:update);
					}
				}
			}

			transmit("inventoryUpdated", true);

			return;
		}

		if (map['vendorName'] == 'Auctioneer') {
			new AuctionWindow().open();
			return;
		}
		if (map['openWindow'] != null) {
			if (map['openWindow'] == 'vendorSell') new VendorWindow().call(map, sellMode: true);
			if (map['openWindow'] == 'mailbox') new MailboxWindow().open();
			return;
		}
		if (map['itemsForSale'] != null) {
			new VendorWindow().call(map);
			return;
		}
		if (map['giantName'] != null) {
			new ShrineWindow(map['giantName'], map['favor'], map['maxFavor'], map['id']).open();
			return;
		}
		if (map['favorUpdate'] != null) {
			transmit('favorUpdate', map);
			return;
		}
		if (map['gotoStreet'] != null) {
			streetService.requestStreet(map['tsid']);
			return;
		}
		if (map['toast'] != null) {
			toast(map['message']);
			return;
		}
		if (map["useItem"] != null) {
			new UseWindow(map["useItem"], map["useItemName"]);
			return;
		}

		(map["quoins"] as List).forEach((Map quoinMap) {
			if (quoinMap["remove"] == "true") {
				Element objectToRemove = querySelector("#${quoinMap["id"]}");
				if (objectToRemove != null) objectToRemove.style.display =
				"none";
				//.remove() is very slow
			} else {
				String id = quoinMap["id"];
				Element element = querySelector("#$id");
				if (element == null) addQuoin(quoinMap);
				else if (element.style.display == "none") {
					element.style.display = "block";
					quoins[id].collected = false;
				}
			}
		});
		(map["doors"] as List).forEach((Map doorMap) {
			String id = doorMap["id"];
			Element element = querySelector("#$id");
			Door door = entities[doorMap["id"]];
			if (element == null) {
				addDoor(doorMap);
			}
			else {
				element.attributes['actions'] = JSON.encode(doorMap['actions']);
				if (door != null) {
					_updateChatBubble(doorMap, door);
				}
			}
		});
		(map["plants"] as List).forEach((Map plantMap) {
			String id = plantMap["id"];
			Element element = querySelector("#$id");
			Plant plant = entities[plantMap["id"]];
			if (element == null) {
				addPlant(plantMap);
			}
			else {
				element.attributes['actions'] = JSON.encode(plantMap['actions']);
				if (plant != null) {
					if (plant.state != plantMap['state']) {
						plant.updateState(plantMap['state']);
					}
					_updateChatBubble(plantMap, plant);
				}
			}
		});
		(map["npcs"] as List).forEach((Map npcMap) {
			String id = npcMap["id"];
			Element element = querySelector("#$id");
			NPC npc = entities[npcMap["id"]];
			if (element == null) {
				addNPC(npcMap);
			}
			else {
				element.attributes['actions'] = JSON.encode(npcMap['actions']);
				if (npc != null) {
					//new animation
					if (npc.animation.animationName != npcMap["animation_name"]) {
						npc.ready = false;

						List<int> frameList = [];
						for (int i = 0; i < npcMap['numFrames']; i++) {
							frameList.add(i);
						}

						npc.animation = new Animation(npcMap['url'], npcMap['animation_name'],
						                              npcMap['numRows'], npcMap['numColumns'], frameList,
						                              loops: npcMap['loops']);
						npc.animation.load().then((_) => npc.ready = true);
					}

					npc.facingRight = npcMap["facingRight"];
					_updateChatBubble(npcMap, npc);
				}
			}
		});
		(map['groundItems'] as List).forEach((Map itemMap) {
			String id = itemMap['id'];
			Element element = querySelector("#$id");
			if (element == null) {
				addItem(itemMap);
			} else {
				if (itemMap['onGround'] == false) {
					element.remove();
					entities.remove(id);
					CurrentPlayer.intersectingObjects.clear();
				} else {
					element.attributes['actions'] = JSON.encode(itemMap['actions']);
				}
			}
		});
	});
	streetSocket.onClose.listen((CloseEvent e) {
		logmessage('[Multiplayer (Street)] Socket closed');
		if (!reconnect) {
			querySelector('#server-down').hidden = false;
			serverDown = true;
			reconnect = true;
			return;
		}

		joined = "";
		//wait 5 seconds and try to reconnect
		new Timer(new Duration(seconds: 5), () {
			_setupStreetSocket(currentStreet.label);
		});
	});
	streetSocket.onError.listen((Event e) {
		logmessage('[Multiplayer (Street)] Error ${e}');
	});
}