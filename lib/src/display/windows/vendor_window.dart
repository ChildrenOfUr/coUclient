part of couclient;


class VendorWindow extends Modal {
  String id = 'shopWindow';
  Element header;
  Element buy;
  Element currants;

  Element backToSell;

  Element backToBuy;
  Element buyPlus;
  Element buyMinus;
  Element buyMax;
  Element buyButton;
  Element buyItemCount;
  ImageElement buyItemImage;
  Element buyPriceTag;
  InputElement buyNum;
  Element buyDescription;
  Element buyStacksTo;

  VendorWindow() {
    prepare();

    header = this.window.querySelector('header');
    buy = this.window.querySelector('#buy');
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

  // Calling the modal with a vendorMap opens a vendor window
  call(Map vendorMap) {

    header.text = vendorMap['vendorName'];
    currants.text = " ${commaFormatter.format(metabolics.getCurrants())} currants";

    new List.from(buy.children)..forEach((child) => child.remove());

    for (Map item in vendorMap['itemsForSale'] as List) {
      Element merch = buy.append(new DivElement()..className = 'box');
      merch.append(new ImageElement(src: item['iconUrl'])..className = "icon");
      Element price = merch.append(new DivElement()
          ..text = '${item['price']}₡'
          ..className = 'price-tag');
      if (item['price'] > metabolics.getCurrants()) price.classes.add("cantAfford");

      //DivElement tooltip = new DivElement()..className = "vendorItemTooltip";
      //DivElement priceParent = new DivElement()..style.textAlign="center"..append(price);
      //tooltip.text = item['name'];
      //price.text = item['price'].toString() + "\u20a1";

      merch.onClick.listen((_) => spawnBuyDetails(item, vendorMap));
    }
    DivElement dropTarget = querySelector("#SellDropTarget");
    Draggable draggable = new Draggable(querySelectorAll(".inventoryItem"), avatarHandler: new CustomAvatarHandler());
    Dropzone dropzone = new Dropzone(dropTarget, acceptor: new Acceptor.draggables([draggable]));
    dropzone.onDrop.listen((DropzoneEvent dropEvent)
	{
    	spawnBuyDetails(JSON.decode(dropEvent.draggableElement.attributes['itemMap']),vendorMap);
	});
    this.open();
  }




  spawnBuyDetails(item, Map vendorMap) {

    // toggle the tabs
    this.window.querySelector('#buy').hidden = true;
    this.window.querySelector('#buy-qty').hidden = false;

    buyStacksTo.text = item['stacksTo'].toString();

    // update the buy meter
    int numToBuy = 1;
    _updateNumToBuy(buyNum, buyButton, item, numToBuy);

    // update the image and numbers
    buyButton.text = "Buy 1 for ${item['price']}\u20a1";
    buyItemCount.text = getNumItems(item['name']).toString();
    buyItemImage.src = '${item['iconUrl']}';
    buyDescription.text = item['description'];
    buyPriceTag.text = "${item['price']}\u20a1";

    // set up button listeners
    buyNum.onInput.listen((_) {
      try {
        int newNum = buyNum.valueAsNumber.toInt();
        numToBuy = _updateNumToBuy(buyNum, buyButton, item, newNum);
      } catch (e) {}
    });
    StreamSubscription bb = buyButton.onClick.listen((_) {
      if (metabolics.getCurrants() < item['price'] * numToBuy) return;
      int newValue = metabolics.getCurrants() - item['price'] * numToBuy;
      metabolics.setCurrants(newValue);
      currants.text = " ${commaFormatter.format(metabolics.getCurrants())} currants";
      sendAction("buyItem", vendorMap['id'], {
        "itemName": item['name'],
        "num": numToBuy
      });
      backToBuy.click();
    });
    StreamSubscription bplus = buyPlus.onClick.listen((_) {
      try {
        int newNum = (++buyNum.valueAsNumber).toInt();
        numToBuy = _updateNumToBuy(buyNum, buyButton, item, newNum);
      } catch (e) {}
    });
    StreamSubscription bminus = buyMinus.onClick.listen((_) {
      try {
        int newNum = (--buyNum.valueAsNumber).toInt();
        numToBuy = _updateNumToBuy(buyNum, buyButton, item, newNum);
      } catch (e) {}
    });
    StreamSubscription bmax = buyMax.onClick.listen((_) {
      try {
        int newNum = min((item['stacksTo']).toInt(), (metabolics.getCurrants() / item['price']) ~/ 1);
        numToBuy = _updateNumToBuy(buyNum, buyButton, item, newNum);
      } catch (e) {}
    });
    backToBuy.onClick.first.then((_) {

      // Clean up our event listeners
      bb.cancel();
      bminus.cancel();
      bplus.cancel();
      bmax.cancel();

      this.window.querySelector('#buy-qty').hidden = true;
      this.window.querySelector('#buy').hidden = false;
    });
  }
  static int _updateNumToBuy(InputElement numInput, DivElement buyButton, Map item, int newNum) {
    if (newNum < 1) newNum = 1;
    if (newNum >= 99) newNum = 99;

    numInput.valueAsNumber = newNum;
    int value = item['price'] * newNum;
    buyButton.text = "Buy $newNum for $value\u20a1";

    return numInput.valueAsNumber.toInt();
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


/*
class VendorWindow_old {
  /**
	 *
	 * Creates the UI for a vendor window and returns a reference to the root element
	 *
	 **/
  static Element create(Map vendorMap) {
    DivElement VendorWindow_old = new DivElement()
        ..id = "VendorWindow_old"
        ..className = "PopWindow";

    DivElement header = new DivElement()..className = "PopWindowHeader handle";
    DivElement title = new DivElement()
        ..id = "VendorTitle"
        ..text = vendorMap['vendorName'];
    SpanElement close = new SpanElement()
        ..id = "CloseVendor"
        ..className = "fa fa-times fa-lg red PopCloseEmblem";
    header
        ..append(title)
        ..append(close);

    DivElement tabParent = new DivElement()..id = "VendorTabParent";
    DivElement buy = new DivElement()
        ..id = "BuyTab"
        ..className = "vendorTab vendorTabSelected"
        ..text = "Buy";
    DivElement sell = new DivElement()
        ..id = "SellTab"
        ..className = "vendorTab"
        ..text = "Sell";
    tabParent
        ..append(buy)
        ..append(sell);

    DivElement currantParent = new DivElement()..id = "CurrantParent";
    SpanElement first = new SpanElement()
        ..attributes['style'] = "color:gray;vertical-align:middle"
        ..text = "You have ";
    ImageElement currant = new ImageElement(src: "packages/couclient/system/currant.svg")..id = "NumCurrantsEmblem";
    SpanElement last = new SpanElement()
        ..attributes['style'] = "vertical-align:middle"
        ..id = "NumCurrants"
        ..text = " ${ui.commaFormatter.format(metabolics.getCurrants())} currants";
    currantParent
        ..append(first)
        ..append(currant)
        ..append(last);

    VendorWindow_old
        ..append(header)
        ..append(tabParent)
        ..append(VendorShelves.create(vendorMap))
        ..append(currantParent);

    close.onClick.first.then((_) => destroy());

    buy.onClick.listen((_) {
      insertContent(VendorShelves.create(vendorMap));
      _setActiveTab(buy);
    });

    sell.onClick.listen((_) {
      insertContent(SellInterface.create(vendorMap));
      _setActiveTab(sell);
    });
    document.onKeyUp.listen((KeyboardEvent k) {
      if (k.keyCode == 27) destroy();
    });

    return VendorWindow_old;
  }

  /**
	 *
	 * Finds this window in the document and removes it
	 *
	 **/
  static void destroy() {
    Element window = querySelector("#VendorWindow_old");
    if (window != null) window.remove();
  }

  static void insertContent(Element content) {
    Element existing = querySelector(".vendorContentInsert");
    if (existing != null) existing.remove();
    querySelector("#VendorWindow_old").insertBefore(content, querySelector("#CurrantParent"));
    if (querySelector("#SellInterface") != null || DetailsWindow.inSellMode) _setActiveTab(querySelector("#SellTab")); else _setActiveTab(querySelector("#BuyTab"));
  }

  static void _setActiveTab(Element tab) {
    querySelector("#VendorTabParent").children.forEach((Element child) => child.classes.remove("vendorTabSelected"));
    tab.classes.add("vendorTabSelected");
  }
}
*/
