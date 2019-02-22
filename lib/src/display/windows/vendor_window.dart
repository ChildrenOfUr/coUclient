part of couclient;

class VendorWindow extends Modal {
	static VendorWindow _instance;
	String id = 'shopWindow';
	String npcId = '';
	Element header, name, buy, sell, currants, backToSell, backToBuy, buyPlus, buyMinus;
	Element buyMax, buyButton, buyItemCount, buyPriceTag, buyDescription, buyStacksTo, amtSelector;
	ImageElement buyItemImage;
	InputElement buyNum;
	StreamSubscription maxListener, minusListener, plusListener, buyListener, buyNumListener;

	factory VendorWindow() {
		if(_instance == null) {
			_instance = new VendorWindow._();
		}

		return _instance;
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
	}

	@override
	openTab(String tabId) {
		super.openTab(tabId);
	}

	// Calling the modal with a vendorMap opens a vendor window
	call(Map vendorMap, {bool sellMode:false}) {
		npcId = vendorMap['id'];
		String windowTitle = vendorMap['vendorName'];
		if(windowTitle.contains('Street Spirit:')) {
			windowTitle = windowTitle.substring(15) + " Vendor";
		}
		header.innerHtml = '<i class="fa-li fa fa-shopping-cart"></i>' + windowTitle;
		currants.text = " ${commaFormatter.format(metabolics.currants)} currant${(metabolics.currants != 1 ? "s" : "")}";

		new List.from(buy.children)
			..forEach((child) => child.remove());

		for(Map item in vendorMap['itemsForSale'] as List) {
			Element merch = buy.append(new DivElement()
				                           ..className = 'box'..title = item["name"]);
			merch.append(new ImageElement(src: item['iconUrl'])
				             ..className = "icon");

			Element price;

			if (item["discount"] != 1) {
				// Item on sale, see price by clicking
				price = merch.append(
					new DivElement()
						..text = "Sale!"
						..classes.addAll(["price-tag", "sale-price-tag"])
				);
			} else if (item['price'] >= 9999) {
				// Really expensive item
				price = merch.append(
				  new DivElement()
					  ..text = 'A Lot'
					  ..className = 'price-tag'
				);
			} else {
				// Normal item
				price = merch.append(
				  new DivElement()
					  ..text = '${item['price']}₡'
					  ..className = 'price-tag'
				);
			}

			if(item['price'] * item["discount"] > metabolics.currants) {
				price.classes.add("cantAfford");
			}

			merch.onClick.listen((_) => spawnBuyDetails(item, vendorMap['id']));
		}

		DivElement dropTarget = querySelector("#SellDropTarget");
		Dropzone dropzone = new Dropzone(dropTarget);
		dropzone.onDrop.listen((DropzoneEvent dropEvent) {
			// TODO: fix this only getting called the first time
			// https://github.com/ChildrenOfUr/cou-issues/issues/279
			// print("dropped item");

			//verify it is a valid item before acting on it
			if(dropEvent.draggableElement.attributes['itemMap'] == null) {
				return;
			}
			spawnBuyDetails(jsonDecode(dropEvent.draggableElement.attributes['itemMap']) as Map,
				vendorMap['id'], sellMode:true);
		});

		if(sellMode) {
			this.displayElement.querySelector('#SellTab').click();
		} else {
			this.displayElement.querySelector('#BuyTab').click();
		}
		this.open(ignoreKeys: true);
	}

	void spawnBuyDetails(Map<String, dynamic> item, String vendorId, {bool sellMode: false}) {
		// Check for non-empty bags
		if (
			(item['isContainer'] != null && item['isContainer'] as bool)
			&& (item['metadata'] != null && item['metadata']['slots'] != null)
		) {
			List<Map<String, dynamic>> slots = (jsonDecode(item['metadata']['slots']) as List)
				.cast<Map<String, dynamic>>();
			bool itemFound = false;
			for (Map<String, dynamic> slot in slots) {
				if ((slot['itemType'] as String).trim().length > 0 ||
					slot['item'] != null || (slot['count'] as int) > 0) {
					itemFound = true;
				}
			}
			if (itemFound) {
				new Toast('Empty this and try again!');
				return;
			}
		}

		//cancel the previous button listeners (if applicable)
		maxListener?.cancel();
		minusListener?.cancel();
		plusListener?.cancel();
		buyListener?.cancel();
		buyNumListener?.cancel();

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
			buyButton.text = "Sell 1 for ${((item['price'] as int) * .7) ~/ 1}\u20a1";
		} else {
			if(util.getBlankSlots(item) == 0) {
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
					buyButton.text = "On sale! Buy 1 for "
						"${((item['price'] as int) * (item["discount"] as num)).toInt().toString()}\u20a1";
				}
			}
		}

		buyItemCount.text = util.getNumItems(item['itemType']).toString();
		buyItemImage.src = item['iconUrl'] as String;
		buyDescription.text = item['description'] as String;
		buyPriceTag.text = "${item['price']}\u20a1";
		name.text = item['name'];

		// set up button listeners
		buyNumListener = buyNum.onInput.listen((_) {
			try {
				int newNum = buyNum.valueAsNumber.toInt();
				numToBuy = _updateNumToBuy(item, newNum, sellMode:sellMode);
			}
			catch(e) {}
		});

		// Sell/Buy Button
		buyListener = buyButton.onClick.listen((_) {
			int newValue;
			Map actionMap = {"itemType": item['itemType'], "num": numToBuy};
			String diffSign;

			if(sellMode) {
				if(numToBuy > util.getNumItems(item['itemType'])) {
					return;
				}

				newValue = metabolics.currants + (item['price'] * numToBuy * .7) ~/ 1;
				sendAction("sellItem", vendorId, actionMap);
				diffSign = "+";
			} else {
				if(metabolics.currants < item["discount"] * item["price"] * numToBuy) {
					return;
				}

				newValue = metabolics.currants - ((item['price'] as int) * (item["discount"] as num) * numToBuy).toInt();
				sendAction("buyItem", vendorId, actionMap);
				diffSign = "-";
			}

			currants.text = " ${commaFormatter.format(newValue)} currant${(newValue != 1 ? "s" : "")}";

			// Animate currant change at bottom
			int currantDiff = (metabolics.currants - newValue).abs();
			String diffStr = diffSign + currantDiff.toString();
			animateText(currants.parent, diffStr, "currant-vendor-anim");

			backToBuy.click();
		});

		// Plus Button
		plusListener = buyPlus.onClick.listen((_) async {
			try {

				if (sellMode) {
					// Selling an item

					if (buyNum.valueAsNumber + 1 <= util.getNumItems(item["itemType"])) {
						// We have enough to sell
						int newNum = (++buyNum.valueAsNumber).toInt();
						numToBuy = _updateNumToBuy(item, newNum, sellMode: sellMode);
					}

				} else {
					// Buying an item

					if (buyNum.valueAsNumber + 1 <= _maxAdditions(item)) {
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
		minusListener = buyMinus.onClick.listen((_) {
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
		maxListener = buyMax.onClick.listen((_) async {
			try {
				int newNum;
				if(sellMode) {
					// Selling an item
					newNum = util.getNumItems(item['itemType']);
				} else {
					// Buying an item
					newNum = min(_maxAdditions(item), (metabolics.currants / item['price']) ~/ 1);
				}
				numToBuy = _updateNumToBuy(item, newNum, sellMode:sellMode);
			}
			catch(e) {
				logmessage("[Vendor] Max Button Error: $e");
			}
		});

		backToBuy.onClick.first.then((_) {
			this.displayElement.querySelector('#buy-qty').hidden = true;
			if(sellMode) {
				sell.hidden = false;
			} else {
				buy.hidden = false;
			}
		});
	}

	int _maxAdditions(Map item) {
		int count = util.getBlankSlots(item)*item['stacksTo'];
		count += util.getStackRemainders(item['itemType']);

		return count;
	}

	int _updateNumToBuy(Map<String, dynamic> item, int newNum, {bool sellMode: false}) {
		if(newNum < 1) {
			newNum = 1;
		}

		if(sellMode) {
			newNum = min(newNum, util.getNumItems(item['itemType']));
		}

		buyNum.valueAsNumber = newNum;
		int value = (item['price'] as int) * newNum;
		if(sellMode) {
			value = (value * .7) ~/ 1;
		}

		if(sellMode) {
			buyButton.text = "Sell $newNum for $value\u20a1";
		} else {
			buyButton.text = "Buy $newNum for $value\u20a1";
		}

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
