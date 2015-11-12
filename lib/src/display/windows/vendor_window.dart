part of couclient;

class VendorWindow extends Modal {
	static VendorWindow vendorWindow;
	String id = 'shopWindow';
	String npcId = '';
	Element header, name, buy, sell, currants, backToSell, backToBuy, buyPlus, buyMinus;
	Element buyMax, buyButton, buyItemCount, buyPriceTag, buyDescription, buyStacksTo, amtSelector;
	ImageElement buyItemImage;
	InputElement buyNum;

	factory VendorWindow() {
		if(vendorWindow == null) {
			vendorWindow = new VendorWindow._();
		}

		return vendorWindow;
	}

	VendorWindow._() {
		prepare();

		header = this.displayElement.querySelector('header');
		buy = this.displayElement.querySelector('#buy');
		sell = this.displayElement.querySelector('#sell');
		currants = this.displayElement.querySelector('.qty');
		name = this.displayElement.querySelector(".ItemName");

		backToBuy = this.displayElement.querySelector('#buy-qty .back');
		backToSell = this.displayElement.querySelector('#sell-qty .back');

		buyPlus = this.displayElement.querySelector('#buy-qty .plus');
		buyMinus = this.displayElement.querySelector('#buy-qty .minus');
		buyMax = this.displayElement.querySelector('#buy-qty .max');
		buyButton = this.displayElement.querySelector('#buy-qty .BuyButton');
		buyNum = this.displayElement.querySelector('#buy-qty .NumToBuy');
		buyItemCount = this.displayElement.querySelector('#buy-qty .ItemNum');
		buyItemImage = this.displayElement.querySelector('#buy-qty .ItemImage');
		buyDescription = this.displayElement.querySelector('#buy-qty .Description');
		buyStacksTo = this.displayElement.querySelector('#buy-qty .StackNum');
		buyPriceTag = this.displayElement.querySelector('#buy-qty .ItemPrice');
		amtSelector = this.displayElement.querySelector('.QuantityParent');
	}

	@override
	close() {
		sendAction("close", npcId, {});
		super.close();

		// Enable inventory sorting
		InvDragging.enable("vendorWindow");
	}

	@override
	open() {
		displayElement.hidden = false;
		elementOpen = true;
		this.focus();

		// Disable inventory sorting
		InvDragging.disable("vendorWindow");
	}

	// Calling the modal with a vendorMap opens a vendor window
	call(Map vendorMap, {bool sellMode:false}) {
		npcId = vendorMap['id'];
		String windowTitle = vendorMap['vendorName'];
		if(windowTitle.contains('Street Spirit:')) {
			windowTitle = windowTitle.substring(15);
		}
		header.innerHtml = '<i class="fa-li fa fa-shopping-cart"></i>' + windowTitle;
		currants.text = " ${commaFormatter.format(metabolics.currants)} currants";

		new List.from(buy.children)
			..forEach((child) => child.remove());

		for(Map item in vendorMap['itemsForSale'] as List) {
			Element merch = buy.append(new DivElement()
				                           ..className = 'box');
			merch.append(new ImageElement(src: item['iconUrl'])
				             ..className = "icon");

			Element price;

			if (item["discount"] != 1) {
				price = merch.append(
					new DivElement()
						..text = "Sale!"
						..classes.addAll(["price-tag", "sale-price-tag"])
				);
			} else if (item['price'] < 9999) {
				price = merch.append(
					new DivElement()
						..text = '${item['price']}₡'
						..className = 'price-tag'
				);
			} else {
				price = merch.append(
					new DivElement()
						..text = 'A Lot'
						..className = 'price-tag'
				);
			}

			if(item['price'] > metabolics.currants) {
				price.classes.add("cantAfford");
			}

			//DivElement tooltip = new DivElement()..className = "vendorItemTooltip";
			//DivElement priceParent = new DivElement()..style.textAlign="center"..append(price);
			//tooltip.text = item['name'];
			//price.text = item['price'].toString() + "\u20a1";

			merch.onClick.listen((_) => spawnBuyDetails(item, vendorMap['id']));
		}

		DivElement dropTarget = querySelector("#SellDropTarget");
		Draggable draggable = new Draggable(querySelectorAll(".inventoryItem"), avatarHandler: new CustomAvatarHandler());
		Dropzone dropzone = new Dropzone(dropTarget, acceptor: new Acceptor.draggables([draggable]));
		dropzone.onDrop.listen((DropzoneEvent dropEvent) {
			spawnBuyDetails(JSON.decode(dropEvent.draggableElement.attributes['itemMap']), vendorMap['id'], sellMode:true);
		});

		if(sellMode)
			this.displayElement.querySelector('#SellTab').click();
		else
			this.displayElement.querySelector('#BuyTab').click();
		this.open();
	}

	spawnBuyDetails(Map item, String vendorId, {bool sellMode: false}) {
		// toggle the tabs
		buy.hidden = true;
		this.displayElement.querySelector('#buy-qty').hidden = false;

		buyStacksTo.text = item['stacksTo'].toString();

		// update the buy meter
		int numToBuy = 1;
		_updateNumToBuy(item, numToBuy, sellMode:sellMode);

		// update the image and numbers
		if(sellMode) {
			amtSelector.style.opacity = 'initial';
			amtSelector.style.pointerEvents = 'initial';
			buyButton.style.opacity = 'initial';
			buyButton.style.pointerEvents = 'initial';
			buyButton.text = "Sell 1 for ${(item['price'] * .7) ~/ 1}\u20a1";
		} else {
			if(getBlankSlots(item) == 0) {
				amtSelector.style.opacity = '0.5';
				amtSelector.style.pointerEvents = 'none';
				buyButton.style.opacity = '0.5';
				buyButton.text = 'No inventory space';
				buyButton.style.pointerEvents = 'none';
			} else {
				amtSelector.style.opacity = 'initial';
				amtSelector.style.pointerEvents = 'initial';
				buyButton.style.opacity = 'initial';
				buyButton.style.pointerEvents = 'initial';
				if (item["discount"] == 1) {
					buyButton.text = "Buy 1 for ${item['price']}\u20a1";
				} else {
					buyButton.text = "On sale! Buy 1 for ${(item['price'] * item["discount"]).toInt().toString()}\u20a1";
				}
			}
		}

		buyItemCount.text = getNumItems(item['itemType']).toString();
		buyItemImage.src = '${item['iconUrl']}';
		buyDescription.text = item['description'];
		buyPriceTag.text = "${item['price']}\u20a1";
		name.text = item['name'];

		// set up button listeners
		buyNum.onInput.listen((_) {
			try {
				int newNum = buyNum.valueAsNumber.toInt();
				numToBuy = _updateNumToBuy(item, newNum, sellMode:sellMode);
			}
			catch(e) {
			}
		});

		StreamSubscription bb = buyButton.onClick.listen((_) {
			int newValue;
			Map actionMap = {"itemType": item['itemType'], "num": numToBuy};

			if(sellMode) {
				if(numToBuy > getNumItems(item['itemType']))
					return;

				newValue = metabolics.currants + (item['price'] * numToBuy * .7) ~/ 1;
				sendAction("sellItem", vendorId, actionMap);
			}
			else {
				if(metabolics.currants < item['price'] * numToBuy)
					return;

				newValue = metabolics.currants - item['price'] * numToBuy;
				sendAction("buyItem", vendorId, actionMap);
			}

			currants.text = " ${commaFormatter.format(newValue)} currants";
			backToBuy.click();
		});

		// Plus Button
		StreamSubscription bplus = buyPlus.onClick.listen((_) async {
			try {

				if (sellMode) {
					// Selling an item

					if (buyNum.valueAsNumber + 1 <= getNumItems(item["itemType"])) {
						// We have enough to sell
						int newNum = (++buyNum.valueAsNumber).toInt();
						numToBuy = _updateNumToBuy(item, newNum, sellMode: sellMode);
					}

				} else {
					// Buying an item

					if (buyNum.valueAsNumber + 1 <= (await getBlankSlots(item))) {
						// You can fit the max number of items in your inventory
						int newNum = (++buyNum.valueAsNumber).toInt();
						numToBuy = _updateNumToBuy(item, newNum, sellMode: sellMode);
					}

				}

			}
			catch(e) {
				logmessage("[Vendor] Plus Button Error: $e");
			}
		});

		// Minus Button
		StreamSubscription bminus = buyMinus.onClick.listen((_) {
			try {
				if (buyNum.valueAsNumber > 1) {
					// We can't go to 0 or negative
					int newNum = (--buyNum.valueAsNumber).toInt();
					numToBuy = _updateNumToBuy(item, newNum, sellMode: sellMode);
				}
			}
			catch(e) {
				logmessage("[Vendor] Minus Button Error: $e");
			}
		});

		// Max Button
		StreamSubscription bmax = buyMax.onClick.listen((_) async {
			try {
				int newNum;
				if(sellMode) {
					// Selling an item
					newNum = min(item['stacksTo'].toInt(), getNumItems(item['itemType']));
				} else {
					// Buying an item
					newNum = min((await getBlankSlots(item)), min((item['stacksTo']).toInt(), (metabolics.currants / item['price']) ~/ 1));
				}
				numToBuy = _updateNumToBuy(item, newNum, sellMode:sellMode);
			}
			catch(e) {
				logmessage("[Vendor] Max Button Error: $e");
			}
		});

		backToBuy.onClick.first.then((_) {
			// Clean up our event listeners
			bb.cancel();
			bminus.cancel();
			bplus.cancel();
			bmax.cancel();

			this.displayElement.querySelector('#buy-qty').hidden = true;
			if(sellMode)
				sell.hidden = false;
			else
				buy.hidden = false;
		});
	}

	int _updateNumToBuy(Map item, int newNum, {bool sellMode: false}) {
		if(newNum < 1) newNum = 1;
		if(newNum >= 99) newNum = 99;

		if(sellMode)
			newNum = min(newNum, getNumItems(item['itemType']));

		buyNum.valueAsNumber = newNum;
		int value = item['price'] * newNum;
		if(sellMode)
			value = (value * .7) ~/ 1;

		if(sellMode)
			buyButton.text = "Sell $newNum for $value\u20a1";
		else
			buyButton.text = "Buy $newNum for $value\u20a1";

		return buyNum.valueAsNumber.toInt();
	}
}

/*The purpose here is that because the inventory items are contained
 * within their parent, they cannot be on a high enough z-index to appear
 * overtop of the vendor window when dragged. Therefore we will add it to
 * the body instead and then it can be overtop of the window.
 *
 * This only applies to the avatar which lasts as long as the drag
 * operation lasts so there shouldn't be any side-effects.
 */
class CustomAvatarHandler extends CloneAvatarHandler {
	@override
	void dragStart(Element draggable, Point startPosition) {
		num x = draggable.getBoundingClientRect().left;
		num y = draggable.getBoundingClientRect().top;
		super.dragStart(draggable, startPosition);
		document.body.append(super.avatar);
		super.setLeftTop(new Point(x, y));
	}
}