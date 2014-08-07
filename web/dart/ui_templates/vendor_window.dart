part of coUclient;

class VendorWindow
{
	/**
	 * 
	 * Creates the UI for a vendor window and returns a reference to the root element
	 * 
	 **/
	static Element create()
	{
		DivElement vendorWindow = new DivElement()..id="VendorWindow"..className = "PopWindow";
		
		DivElement header = new DivElement()..className = "PopWindowHeader handle";
		DivElement title = new DivElement()..id="VendorTitle";
		SpanElement close = new SpanElement()..id="CloseVendor"..className="fa fa-times fa-lg red PopCloseEmblem";
		header..append(title)..append(close);
		
		DivElement content = new DivElement()..id="VendorContent"..className="vendorContentInsert";
		
		DivElement currantParent = new DivElement()..id="CurrantParent";
		SpanElement first = new SpanElement()..attributes['style']="color:gray;vertical-align:middle"..text="You have ";
		ImageElement currant = new ImageElement(src:"./assets/system/currant.svg")..id="NumCurrantsEmblem";
		SpanElement last = new SpanElement()..attributes['style']="vertical-align:middle"..id="NumCurrants"..text=" 0 currants";
		currantParent..append(first)..append(currant)..append(last);
		
		vendorWindow..append(header)..append(content)..append(currantParent);
		
		return vendorWindow;
	}
	
	/**
	 * 
	 * Finds this window in the document and removes it
	 * 
	 **/
	static void destroy()
	{
		querySelector("#VendorWindow").remove();
	}
}