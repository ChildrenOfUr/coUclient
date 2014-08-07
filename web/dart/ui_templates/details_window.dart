part of coUclient;

class DetailsWindow
{
	static Element create()
	{
		DivElement itemDetails = new DivElement()..id="ItemDetails"..className="vendorContentInsert";
		
		DivElement back = new DivElement()..id="BackLink"..text="\u3008 Back";
		DivElement leftColumn = new DivElement()..id="LeftColumn";
		DivElement imageParent = new DivElement()..id="ItemImageParent";
		ImageElement image = new ImageElement()..id="ItemImage";
		SpanElement price = new SpanElement()..id="ItemPrice";
		imageParent..append(image)..append(price);
		
		DivElement itemCount = new DivElement()..id="ItemCount";
		SpanElement first = new SpanElement()..attributes['style']="color:gray;vertical-align:middle"..text="You have ";
		SpanElement num = new SpanElement()..id="ItemNum"..className="itemDetailNum"..text="0";
		SpanElement last = new SpanElement()..attributes['style']="color:gray;vertical-align:middle"..text=" of these";
		itemCount..append(first)..append(num)..append(last);
		
		leftColumn..append(imageParent)..append(itemCount);
		
		DivElement rightColumn = new DivElement()..id="RightColumn";
		DivElement name = new DivElement()..id="ItemName";
		DivElement quantityParent = new DivElement()..id="QuantityParent";
		SpanElement minus = new SpanElement()..id="MinusButton"..text="-";
		InputElement numToBuy = new InputElement()..id="NumToBuy"..type="number"..value="1"..min="1";
		SpanElement plus = new SpanElement()..id="PlusButton"..text="+";
		DivElement max = new DivElement()..id="MaxButton"..className="button light"..text="Max";
		quantityParent..append(minus)..append(numToBuy)..append(plus)..append(max);
		
		DivElement buy = new DivElement()..id="BuyButton"..className="button light"..text="Buy 1 for 10&#8353;";
		DivElement desc = new DivElement()..id="Description";
		DivElement itemStack = new DivElement()..id="ItemStack";
		SpanElement slot = new SpanElement()..id="BlankSlot";
		SpanElement slotFirst = new SpanElement()..attributes['style']="color:gray;vertical-align:middle"..text="Fits up to ";
		SpanElement stackNum = new SpanElement()..id="StackNum"..className="itemDetailNum"..text="0";
		SpanElement slotLast = new SpanElement()..attributes['style']="color:gray;vertical-align:middle"..text=" in an inventory slot";
		itemStack..append(slot)..append(slotFirst)..append(stackNum)..append(slotLast);
		
		rightColumn..append(name)..append(quantityParent)..append(buy)..append(desc)..append(itemStack);
		
		itemDetails..append(back)..append(leftColumn)..append(rightColumn);
		
		return itemDetails;
	}
	
	static void destroy()
	{
		querySelector("#ItemDetails").remove();
	}
}