part of coUclient;

class RightClickMenu
{
	static Element create()
	{
		DivElement menu = new DivElement()..id="RightClickMenu";
		
		DivElement infoButton = new DivElement()..className="InfoButton"..text="Info";
		SpanElement title = new SpanElement()..id="ClickTitle"..text="A Chicken";
		BRElement br = new BRElement();
		SpanElement desc = new SpanElement()..id="ClickDesc"..className="soft"..text="Obtain wheat. Costs 2 energy";
		DivElement actionList = new DivElement()..id="RCActionList";
		
		menu..append(infoButton)..append(title)..append(br)..append(desc)..append(actionList);
        	    
    	return menu;
	}
	
	static void destroy()
	{
		querySelector("#RightClickMenu").remove();
	}
}