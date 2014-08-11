part of couclient;

class VendorShelves
{
	static Element create(Map vendorMap)
	{
		DivElement content = new DivElement()..id="VendorShelves"..className="vendorContentInsert";
        		
		for(Map item in vendorMap['itemsForSale'] as List)
    	{
    		DivElement parent = new DivElement()..className = "vendorItemParent";
    		DivElement tooltip = new DivElement()..className = "vendorItemTooltip";
    		ImageElement image = new ImageElement(src:item['iconUrl'])..className = "vendorItemPreview";
    		SpanElement price = new SpanElement()..className="itemPrice";
    		DivElement priceParent = new DivElement()..style.textAlign="center"..append(price);
    		tooltip.text = item['name'];
    		price.text = item['price'].toString() + "\u20a1";
    		if(item['price'] > metabolics.getCurrants())
            	price.classes.add("cantAfford");
    		
    		parent.onClick.listen((_) => VendorWindow.insertContent(DetailsWindow.create(item,vendorMap)));
    		parent..append(tooltip)..append(image)..append(priceParent);
    		content.append(parent);
    	}
		
		return content;
	}
	
	static void destroy()
	{
		querySelector("#VendorShelves").remove();
	}
}