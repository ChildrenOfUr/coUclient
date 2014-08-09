part of coUclient;

class DetailsWindow
{
	static bool inSellMode = false;
	
	static Element create(Map item, Map vendorMap, {bool sellMode : false})
	{
		inSellMode = sellMode;
		
		DivElement itemDetails = new DivElement()..id="ItemDetails"..className="vendorContentInsert";
		
		DivElement back = new DivElement()..id="BackLink"..text="\u3008 Back";
		DivElement leftColumn = new DivElement()..id="LeftColumn";
		DivElement imageParent = new DivElement()..id="ItemImageParent";
		ImageElement image = new ImageElement(src:item['iconUrl'])..id="ItemImage";
		SpanElement price = new SpanElement()..id="ItemPrice"..text="Price ${item['price']}\u20a1";
		imageParent..append(image)..append(price);
		
		DivElement itemCount = new DivElement()..id="ItemCount";
		SpanElement first = new SpanElement()..attributes['style']="color:gray;vertical-align:middle"..text="You have ";
		SpanElement num = new SpanElement()..id="ItemNum"..className="itemDetailNum"..text="${getNumItems(item['name'])}";
		SpanElement last = new SpanElement()..attributes['style']="color:gray;vertical-align:middle"..text=" of these";
		itemCount..append(first)..append(num)..append(last);
		
		leftColumn..append(imageParent)..append(itemCount);
		
		DivElement rightColumn = new DivElement()..id="RightColumn";
		DivElement name = new DivElement()..id="ItemName"..text = item['name'];
		DivElement quantityParent = new DivElement()..id="QuantityParent";
		SpanElement minus = new SpanElement()..id="MinusButton"..text="-";
		InputElement buyNum = new InputElement()..id="NumToBuy"..type="number"..value="1"..min="1";
		SpanElement plus = new SpanElement()..id="PlusButton"..text="+";
		DivElement max = new DivElement()..id="MaxButton"..className="button light"..text="Max";
		quantityParent..append(minus)..append(buyNum)..append(plus)..append(max);
		
		String verb = "Buy";
		int priceFor1 = item['price'];
		if(sellMode)
		{
			verb = "Sell";
			priceFor1 = (item['price']*.7*1)~/1;
		}
		DivElement buy = new DivElement()..id="BuyButton"..className="button light"..attributes['style']="margin-left:10px;"..text="$verb 1 for $priceFor1\u20a1";
		DivElement desc = new DivElement()..id="Description"..text = item['description'];
		DivElement itemStack = new DivElement()..id="ItemStack";
		SpanElement slot = new SpanElement()..id="BlankSlot";
		SpanElement slotFirst = new SpanElement()..attributes['style']="color:gray;vertical-align:middle"..text="Fits up to ";
		SpanElement stackNum = new SpanElement()..id="StackNum"..className="itemDetailNum"..text="${item['stacksTo']}";
		SpanElement slotLast = new SpanElement()..attributes['style']="color:gray;vertical-align:middle"..text=" in an inventory slot";
		itemStack..append(slot)..append(slotFirst)..append(stackNum)..append(slotLast);
		
		rightColumn..append(name)..append(quantityParent)..append(buy)..append(desc)..append(itemStack);
		
		itemDetails..append(back)..append(leftColumn)..append(rightColumn);
		    	
    	int numToBuy = 1;
    	buyNum.onInput.listen((_)
    	{
    		try
    		{
    			int newNum = buyNum.valueAsNumber.toInt();
    			if(newNum > getNumItems(item['name']))
    			{
    				newNum = getNumItems(item['name']);
    				buyNum.value = getNumItems(item['name']).toString();
    			}
    			numToBuy = _updateNumToBuy(buyNum,buy,item['price'],newNum,verb);
    		}catch(e){}
    	});
    	buy.onClick.listen((_)
    	{
    		if(!sellMode && getCurrants() < item['price']*numToBuy)
    			return;
    		
    		int newValue = getCurrants()-item['price']*numToBuy;
    		if(sellMode)
    			newValue = getCurrants()+(item['price']*.7*numToBuy)~/1;
    		setCurrants((newValue).toString());
    		querySelector("#NumCurrants").text = " ${ui.commaFormatter.format(getCurrants())} currants";
    		sendAction("${verb.toLowerCase()}Item",vendorMap['id'],{"itemName":item['name'],"num":numToBuy});
    		back.click();
    	});
    	plus.onClick.listen((_)
    	{
            try
            {
            	int newNum = (++buyNum.valueAsNumber).toInt();
            	if(sellMode && buyNum.valueAsNumber >= getNumItems(item['name']))
            		newNum = getNumItems(item['name']);
            	numToBuy = _updateNumToBuy(buyNum,buy,item['price'],newNum,verb);
            }catch(e){}
    	});
    	minus.onClick.listen((_)
    	{
    		try
    	    {
    	    	int newNum = (--buyNum.valueAsNumber).toInt();
    	    	numToBuy = _updateNumToBuy(buyNum,buy,item['price'],newNum,verb);
    	    }catch(e){}
    	});
    	max.onClick.listen((_)
		{
    		try
    	    {
    	    	int newNum = min((item['stacksTo']).toInt(),(getCurrants()/item['price'])~/1);
    	    	if(sellMode)
    	    		newNum = getNumItems(item['name']);
    	    	numToBuy = _updateNumToBuy(buyNum,buy,item['price'],newNum,verb);
    	    }catch(e){}
		});
    	back.onClick.first.then((_)
    	{
    		destroy();
    		if(sellMode)
    			VendorWindow.insertContent(SellInterface.create(vendorMap));
    		else
    			VendorWindow.insertContent(VendorShelves.create(vendorMap));
    	});
		
		return itemDetails;
	}
	
	static void destroy()
	{
		querySelector("#ItemDetails").remove();
	}
	
	static int _updateNumToBuy(InputElement numInput, DivElement buyButton, int price, int newNum, String verb)
    {
    	if(newNum < 1)
    		newNum = 1;
    	
    	numInput.valueAsNumber = newNum;
    	int value = price*newNum;
    	if(verb == "Sell")
    		value = (price*.7*newNum)~/1;
        buyButton.text = "$verb $newNum for $value\u20a1";
        
        return numInput.valueAsNumber.toInt();
    }
}