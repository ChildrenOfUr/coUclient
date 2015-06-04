part of couclient;

class VendorWindow extends Modal
{
	String id = 'shopWindow';
	String npcId = '';
	Element header, buy, sell, currants, backToSell, backToBuy, buyPlus, buyMinus;
	Element buyMax, buyButton, buyItemCount, buyPriceTag, buyDescription, buyStacksTo;
	ImageElement buyItemImage;
	InputElement buyNum;

	VendorWindow()
	{
		prepare();

		header = this.window.querySelector('header');
		buy = this.window.querySelector('#buy');
		sell = this.window.querySelector('#sell');
		currants = this.window.querySelector('.qty');

		backToBuy = this.window.querySelector('#buy-qty .back');
		backToSell = this.window.querySelector('#sell-qty .back');

		buyPlus = this.window.querySelector('#buy-qty .plus');
		buyMinus = this.window.querySelector('#buy-qty .minus');
		buyMax = this.window.querySelector('#buy-qty .max');
		buyButton = this.window.querySelector('#buy-qty .BuyButton');
		buyNum = this.window.querySelector('#buy-qty .NumToBuy');
		buyItemCount = this.window.querySelector('#buy-qty .ItemNum');
		buyItemImage = this.window.querySelector('#buy-qty .ItemImage');
		buyDescription = this.window.querySelector('#buy-qty .Description');
		buyStacksTo = this.window.querySelector('#buy-qty .StackNum');
		buyPriceTag = this.window.querySelector('#buy-qty .ItemPrice');
	}

	@override
	close() {
		sendAction("close", npcId, {});
		super.close();
	}

	// Calling the modal with a vendorMap opens a vendor window
	call(Map vendorMap, {bool sellMode:false})
	{
		npcId = vendorMap['id'];
		print(npcId);
		header.text = vendorMap['vendorName'];
		currants.text = " ${commaFormatter.format(metabolics.currants)} currants";

		new List.from(buy.children)..forEach((child) => child.remove());

		for (Map item in vendorMap['itemsForSale'] as List)
		{
			Element merch = buy.append(new DivElement()..className = 'box');
			merch.append(new ImageElement(src: item['iconUrl'])..className = "icon");
			Element price = merch.append(new DivElement()
				..text = '${item['price']}₡'
				..className = 'price-tag');

			if (item['price'] > metabolics.currants)
				price.classes.add("cantAfford");

			//DivElement tooltip = new DivElement()..className = "vendorItemTooltip";
			//DivElement priceParent = new DivElement()..style.textAlign="center"..append(price);
			//tooltip.text = item['name'];
			//price.text = item['price'].toString() + "\u20a1";

			merch.onClick.listen((_) => spawnBuyDetails(item, vendorMap['id']));
		}

		DivElement dropTarget = querySelector("#SellDropTarget");
		Draggable draggable = new Draggable(querySelectorAll(".inventoryItem"), avatarHandler: new CustomAvatarHandler());
		Dropzone dropzone = new Dropzone(dropTarget, acceptor: new Acceptor.draggables([draggable]));
		dropzone.onDrop.listen((DropzoneEvent dropEvent)
		{
			spawnBuyDetails(JSON.decode(dropEvent.draggableElement.attributes['itemMap']),vendorMap['id'],sellMode:true);
		});

		if(sellMode)
			this.window.querySelector('#SellTab').click();
		else
			this.window.querySelector('#BuyTab').click();
		this.open();
	}

	spawnBuyDetails(Map item, String vendorId, {bool sellMode: false})
	{
		// toggle the tabs
		buy.hidden = true;
		this.window.querySelector('#buy-qty').hidden = false;

		buyStacksTo.text = item['stacksTo'].toString();

		// update the buy meter
		int numToBuy = 1;
		_updateNumToBuy(item, numToBuy, sellMode:sellMode);

		// update the image and numbers
		if(sellMode)
			buyButton.text = "Sell 1 for ${item['price']}\u20a1";
		else
			buyButton.text = "Buy 1 for ${item['price']}\u20a1";

		buyItemCount.text = getNumItems(item['name']).toString();
		buyItemImage.src = '${item['iconUrl']}';
		buyDescription.text = item['description'];
		buyPriceTag.text = "${item['price']}\u20a1";

		// set up button listeners
		buyNum.onInput.listen((_)
		{
			try
			{
			    int newNum = buyNum.valueAsNumber.toInt();
			    numToBuy = _updateNumToBuy(item, newNum, sellMode:sellMode);
			}
			catch (e) {}
		});

		StreamSubscription bb = buyButton.onClick.listen((_)
		{
			int newValue;
			Map actionMap = {"itemName": item['name'],"num": numToBuy};

			if(sellMode)
			{
				if(numToBuy > getNumItems(item['name']))
					return;

				newValue = metabolics.currants + (item['price'] * numToBuy * .7) ~/ 1;
				sendAction("sellItem", vendorId, actionMap);
			}
			else
			{
				if(metabolics.currants < item['price'] * numToBuy)
    				return;

    			newValue = metabolics.currants - item['price'] * numToBuy;
    			sendAction("buyItem", vendorId, actionMap);
			}

			currants.text = " ${commaFormatter.format(newValue)} currants";
			backToBuy.click();
		});

		StreamSubscription bplus = buyPlus.onClick.listen((_)
		{
			try
			{
				int newNum = (++buyNum.valueAsNumber).toInt();
				numToBuy = _updateNumToBuy(item, newNum, sellMode:sellMode);
			}
			catch (e) {}
		});
		StreamSubscription bminus = buyMinus.onClick.listen((_)
		{
			try
			{
				int newNum = (--buyNum.valueAsNumber).toInt();
				numToBuy = _updateNumToBuy(item, newNum, sellMode:sellMode);
			}
			catch (e) {}
		});
		StreamSubscription bmax = buyMax.onClick.listen((_)
		{
			try
			{
				int newNum;
				if(sellMode)
					newNum = min((item['stacksTo']).toInt(),getNumItems(item['name']));
				else
					newNum = min((item['stacksTo']).toInt(), (metabolics.currants / item['price']) ~/ 1);
				numToBuy = _updateNumToBuy(item, newNum, sellMode:sellMode);
			}
			catch (e) {}
		});

		backToBuy.onClick.first.then((_)
		{
			// Clean up our event listeners
			bb.cancel();
			bminus.cancel();
			bplus.cancel();
			bmax.cancel();

			this.window.querySelector('#buy-qty').hidden = true;
			if(sellMode)
				sell.hidden = false;
			else
				buy.hidden = false;
		});
	}

	int _updateNumToBuy(Map item, int newNum, {bool sellMode: false})
	{
		if (newNum < 1) newNum = 1;
		if (newNum >= 99) newNum = 99;

		if(sellMode)
			newNum = min(newNum,getNumItems(item['name']));

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
class CustomAvatarHandler extends CloneAvatarHandler
{
	@override
	void dragStart(Element draggable, Point startPosition)
	{
		num x = draggable.getBoundingClientRect().left;
		num y = draggable.getBoundingClientRect().top;
		super.dragStart(draggable, startPosition);
		document.body.append(super.avatar);
		super.setLeftTop(new Point(x,y));
	}
}