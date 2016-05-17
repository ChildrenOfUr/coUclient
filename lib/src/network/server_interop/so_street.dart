part of couclient;

bool _metadataEqual(Map metaA, Map metaB) {
	if ((metaA == null && metaB == null) ||
	    (metaA.isEmpty && metaB.isEmpty)) {
		return true;
	}
//	//metadata is only used to store slots right now, so check that
//	if (metaA['slots'] != null && metaB['slots'] != null) {
//		List<Map> slotsA = metaA['slots'];
//		List<Map> slotsB = metaB['slots'];
//		if (slotsA.length == slotsB.length) {
//			for (int i = 0; i < slotsA.length; i++) {
//				Map slotA = slotsA[i];
//				Map slotB = slotsB[i];
//				if (slotA['itemType'] != slotB['itemType'] ||
//				    slotA['count'] != slotB['count']) {
//					return false;
//				}
//			}
//		}
//	}
	return JSON.encode(metaA) == JSON.encode(metaB);
//	return true;
}

_setupStreetSocket(String streetName) {
	//start a timer for a few seconds and then show the server down message if not canceled
	Timer serverDownTimer = new Timer(new Duration(seconds: 10), () {
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
			updateInventory(map);
			return;
		}

		if (map['vendorName'] == 'Auctioneer') {
			new AuctionWindow().open();
			return;
		}
		if (map['openWindow'] != null) {
			if (map['openWindow'] == 'vendorSell') new VendorWindow().call(map, sellMode: true);
			if (map['openWindow'] == 'mailbox') new MailboxWindow().open();
			if (map['openWindow'] == 'itemChooser') {
				Function callback = ({String itemType, int count: 1, int slot: -1, int subSlot: -1}) {
					sendAction(map["action"], map['id'], {
						'itemType': itemType,
						'count': count,
						'slot': slot,
						'subSlot': subSlot
					});
				};
				new ItemChooser(map['windowTitle'], callback, filter: map['filter']);
			}
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
			new Toast(map['message'], skipChat: map["skipChat"], onClick: map["onClick"]);
			return;
		}
		if (map["useItem"] != null) {
			new UseWindow(map["useItem"], map["useItemName"]);
			return;
		}

		if (map["achv_id"] != null) {
			new AchievementOverlay(map);
			return;
		}

		if (map["buff"] != null) {
			new Buff.fromMap(map["buff"]);
			return;
		}

		if (map["buff_remove"] != null) {
			Buff.removeBuff(map["buff_remove"]);
			return;
		}

		if (map["note_write"] != null) {
			new NoteWindow(-1, true);
			return;
		}

		if (map["note_response"] != null) {
			transmit("note_response", map["note_response"]);
			return;
		}

		if (map["note_read"] != null) {
			new NoteWindow(int.parse(map["note_read"]));

			return;
		}

		if (map['npcMove'] != null) {
			for (Map npcMap in map['npcs'] as List<Map>) {
				NPC npc = entities[npcMap["id"]];
				if (npc == null) {
					return;
				}

				npc.facingRight = npcMap["facingRight"];
				npc.ySpeed = npcMap['ySpeed'];
				npc.speed = npcMap['speed'];

				npc.x = npcMap['x'];
				npc.y = npcMap['y'];

				npc.updateAnimation(npcMap);
			}

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
					npc.updateAnimation(npcMap);
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