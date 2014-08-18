part of couclient;


class VendorWindow extends Modal {
  String id = 'shopWindow';
  Element header;
  Element buy;
  
  
  VendorWindow() {
    prepare();
    header = this.window.querySelector('header');
      buy = this.window.querySelector('#buy');
      
      
      

    }
  
  // Calling the modal with a vendorMap opens a vendor window
  call(Map vendorMap) {

    
    header.text = vendorMap['vendorName'];
    
    new List.from(buy.children)..forEach((child) => child.remove());
    
    for(Map item in vendorMap['itemsForSale'] as List)
      {
        Element merch = buy.append(new DivElement()..className = 'box');
        merch.append(new ImageElement(src:item['iconUrl'])..className = "icon");
      
        //DivElement tooltip = new DivElement()..className = "vendorItemTooltip";
        
        //SpanElement price = new SpanElement()..className="itemPrice";
        //DivElement priceParent = new DivElement()..style.textAlign="center"..append(price);
        //tooltip.text = item['name'];
        //price.text = item['price'].toString() + "\u20a1";
        //if(item['price'] > metabolics.getCurrants())
        //      price.classes.add("cantAfford");
        
        //parent.onClick.listen((_) => VendorWindow_old.insertContent(DetailsWindow.create(item,vendorMap)));
       // parent..append(tooltip)..append(image)..append(priceParent);
      }
    
    
    
    
    this.open();
  }
  
}






class VendorWindow_old
{
	/**
	 * 
	 * Creates the UI for a vendor window and returns a reference to the root element
	 * 
	 **/
	static Element create(Map vendorMap)
	{
		DivElement VendorWindow_old = new DivElement()..id="VendorWindow_old"..className = "PopWindow";
		
		DivElement header = new DivElement()..className = "PopWindowHeader handle";
		DivElement title = new DivElement()..id="VendorTitle"..text = vendorMap['vendorName'];
		SpanElement close = new SpanElement()..id="CloseVendor"..className="fa fa-times fa-lg red PopCloseEmblem";
		header..append(title)..append(close);
		
		DivElement tabParent = new DivElement()..id="VendorTabParent";
		DivElement buy = new DivElement()..id="BuyTab"..className="vendorTab vendorTabSelected"..text="Buy";
		DivElement sell = new DivElement()..id="SellTab"..className="vendorTab"..text="Sell";
		tabParent..append(buy)..append(sell);
		
		DivElement currantParent = new DivElement()..id="CurrantParent";
		SpanElement first = new SpanElement()..attributes['style']="color:gray;vertical-align:middle"..text="You have ";
		ImageElement currant = new ImageElement(src:"packages/couclient/system/currant.svg")..id="NumCurrantsEmblem";
		SpanElement last = new SpanElement()..attributes['style']="vertical-align:middle"..id="NumCurrants"..text = " ${ui.commaFormatter.format(metabolics.getCurrants())} currants";
		currantParent..append(first)..append(currant)..append(last);
		
		VendorWindow_old..append(header)..append(tabParent)..append(VendorShelves.create(vendorMap))..append(currantParent);
		
		close.onClick.first.then((_) => destroy());
		
		buy.onClick.listen((_)
		{
			insertContent(VendorShelves.create(vendorMap));
			_setActiveTab(buy);
		});
		
		sell.onClick.listen((_)
		{
			insertContent(SellInterface.create(vendorMap));
			_setActiveTab(sell);
		});
		document.onKeyUp.listen((KeyboardEvent k)
		{
			if(k.keyCode == 27)
				destroy();
		});
		
		return VendorWindow_old;
	}
	
	/**
	 * 
	 * Finds this window in the document and removes it
	 * 
	 **/
	static void destroy()
	{
		Element window = querySelector("#VendorWindow_old");
		if(window != null)
			window.remove();
	}
	
	static void insertContent(Element content)
	{
		Element existing = querySelector(".vendorContentInsert");
		if(existing != null)
			existing.remove();
		querySelector("#VendorWindow_old").insertBefore(content, querySelector("#CurrantParent"));
		if(querySelector("#SellInterface") != null || DetailsWindow.inSellMode)
			_setActiveTab(querySelector("#SellTab"));
		else
			_setActiveTab(querySelector("#BuyTab"));
	}
	
	static void _setActiveTab(Element tab)
	{
		querySelector("#VendorTabParent").children.forEach((Element child) => child.classes.remove("vendorTabSelected"));
		tab.classes.add("vendorTabSelected");
	}
}