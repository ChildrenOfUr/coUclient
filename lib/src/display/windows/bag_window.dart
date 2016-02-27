part of couclient;

class BagWindow extends Modal {

	static List<BagWindow> openWindows = [];
	static List<BagWindow> bagWindows = [];

	static closeId(String id) {
		openWindows
			.where((BagWindow w) => w.id == id)
			.first
			.close();
		openWindows.removeWhere((BagWindow w) => w.id == id);
	}

	static bool get isOpen {
		return (querySelectorAll("#windowHolder > .bagWindow").length > 0);
	}

	static void updateSourceSlot(int oldSlotIndex, int newSlotIndex) {
		for (BagWindow w in bagWindows) {
			if (w.sourceSlotNum == oldSlotIndex) {
				w.sourceSlotNum = newSlotIndex;
				w.updateWell(w.sourceItem);
				break;
			}
		}
	}

	String id,
		bagId;
	int numSlots, sourceSlotNum;
	//when set to true, the ui inside the bag will be updated when the bag is next opened
	bool dataUpdated = false;
	ItemDef sourceItem;

	Dropzone acceptors;

	factory BagWindow(int sourceSlotNum, ItemDef sourceItem, {String id : null, bool open : true}) {
		if (id == null) {
			return new BagWindow._(sourceSlotNum, sourceItem, openWindow:open);
		} else {
			for(BagWindow w in bagWindows) {
				if (w.id == id) {
					if(open) {
						w.open();
					}
					return w;
				}
			}
			return new BagWindow._(sourceSlotNum, sourceItem, openWindow:open);
		}
	}

	BagWindow._(this.sourceSlotNum, this.sourceItem, {bool openWindow : true}) {
		bool creating = true;
		id = 'bagWindow' + WindowManager.randomId.toString();
		bagWindows.add(this);

		//load the ui of the window and open it when ready
		load(sourceItem).then((DivElement windowElement) {
			displayElement = windowElement;
			// Handle drag and drop
			new Service(["inventoryUpdated", 'metadataUpdated'], (_) {
				if (acceptors != null) {
					acceptors.destroy();
				}
				acceptors = new Dropzone(
					displayElement.querySelectorAll(".bagwindow-box"),
					acceptor: new BagFilterAcceptor(sourceItem.subSlotFilter)
					)
					..onDrop.listen((DropzoneEvent e) => InvDragging.handleDrop(e));

				displayElement.querySelectorAll('.box').forEach((Element e) {
					new Draggable(e.children[0], avatarHandler: new CustomAvatarHandler(),
						              draggingClass: 'item-flying')
						..onDragStart.listen((DraggableEvent e) => InvDragging.handlePickup(e));
				});
			});

			new Service(['updateMetadata'], (Map indexToItem) async {
				int index = indexToItem['index'];
				if(index != sourceSlotNum) {
					return;
				}
				this.sourceItem = indexToItem['item'];
				if(displayElement.hidden) {
					dataUpdated = true;
				} else {
					if(!creating) {
						updateWell(sourceItem);
					}
				}
			});

			querySelector("#windowHolder").append(displayElement);
			prepare();
			if(openWindow) {
				open();
			} else {
				displayElement.hidden = true;
			}
			creating = false;
		});
	}

	Future updateWell(ItemDef sourceItem) async {
		Element newWell = await load(sourceItem, false);
		displayElement.querySelector("ur-well").replaceWith(newWell);
		transmit('metadataUpdated', true);
	}

	Future<Element> load(ItemDef sourceItem, [bool full = true]) async {
		// Header

		Element closeButton, icon, header;
		SpanElement titleSpan;

		if (full) {
			closeButton = new Element.tag("i")
				..classes.add("fa-li")
				..classes.add("fa")
				..classes.add("fa-times")
				..classes.add("close");

			icon = new ImageElement()
				..classes.add("fa-li")
				..src = "files/system/icons/bag.svg";

			titleSpan = new SpanElement()
				..classes.add("iw-title")
				..text = sourceItem.name;

			if (sourceItem.name.length >= 24) {
				titleSpan.style.fontSize = "24px";
			}

			header = new Element.header()
				..append(icon)..append(titleSpan);
		}

		// Content

		Element well = new Element.tag("ur-well");

		int numSlots = sourceItem.subSlots;
		List<Map> subSlots;

		if (sourceItem.metadata["slots"] == null) {
			// Empty bag
			subSlots = [];
			while (subSlots.length < numSlots) {
				subSlots.add(({
					"itemType": "",
					"count": 0,
					"metadata": {}
				}));
			}
		} else {
			// Bag has contents
			subSlots = sourceItem.metadata["slots"];
		}

		if (subSlots.length != sourceItem.subSlots) {
			print('source count: ${sourceItem.subSlots}');
			print('list length: ${subSlots.length}');
			throw new StateError("Number of slots in bag does not match bag size");
		} else {
			int slotNum = 0;
			well.style.opacity = '0';
			document.body.append(well); //for measuring
			await Future.forEach(subSlots, (Map bagSlot) async {
				DivElement slot = new DivElement();
				// Slot
				slot
					..classes.addAll(["box", "bagwindow-box"])
					..dataset["slot-num"] = slotNum.toString();
				well.append(slot);
				// Item
				DivElement itemInSlot = new DivElement();
				slot.append(itemInSlot);
				if (!bagSlot["itemType"].isEmpty) {
					ItemDef item = decode(JSON.encode(bagSlot['item']), type: ItemDef);
					ImageElement img = new ImageElement(src: item.spriteUrl);
					String className = 'item-${item.itemType} inventoryItem bagInventoryItem';
					await sizeItem(img,itemInSlot,slot,item,bagSlot['count'], sourceSlotNum, cssClass: className, bagSlotNum: slotNum);
				}

				slotNum++;
			});
			well.style.opacity = '1'; //we're done measuring now
			well.remove();
		}

		// Window

		if (full) {
			DivElement window = new DivElement()
				..id = id
				..classes.add("window")
				..classes.add("bagWindow")
				..append(header)..append(closeButton)..append(well)
				..dataset["source-bag"] = sourceSlotNum.toString();

			return window;
		} else {
			return well;
		}
	}

	@override
	open({bool ignoreKeys: false}) {
		super.open();
		openWindows.add(this);

		updateWell(sourceItem);
	}

	@override
	close() {
		super.close();

		// Update the source inventory icon
		Element sourceBox = view.inventory.children
			.where((Element box) => box.dataset["slot-num"] == sourceSlotNum.toString())
			.first;
		sourceBox.querySelector(".item-container-toggle").click();
	}

	// Update the inventory icons (used by the inventory)

	static updateTriggerBtn(bool open, Element item) {
		Element btn = item.parent.querySelector(".item-container-toggle");
		if (!open) {
			// Closed, opening the bag
			btn.classes
				..remove("item-container-closed")..remove("fa-plus")
				..add("item-container-open")..add("fa-times");
			item.classes.add("inv-item-disabled");
		} else {
			// Opened, closing the bag
			btn.classes
				..remove("item-container-open")..remove("fa-times")
				..add("item-container-closed")..add("fa-plus");
			item.classes.remove("inv-item-disabled");
		}
	}
}
