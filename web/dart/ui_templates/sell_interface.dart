part of coUclient;

class SellInterface
{
	static DivElement interface;
	static Map vendorMap;
	static Draggable draggable;
	
	static Element create(Map map)
	{
		vendorMap = map;
		draggable = new Draggable(querySelectorAll(".inventoryItem"),avatarHandler: new AvatarHandler.clone());
                
		if(interface == null)
			_makeUI();
		else
			interface.style.display = "block";
		
		return interface;
	}
	
	static void destroy()
	{
		querySelector("#SellInterface").style.display = "none";
	}
	
	static void _makeUI()
	{
		interface = new DivElement()..id="SellInterface"..className="vendorContentInsert";
        		
		DivElement dropTarget = new DivElement()..id="SellDropTarget";
		ImageElement callout = new ImageElement(src:"assets/system/callout_dropitem.png")..id="SellCallout";
		
		interface..append(dropTarget)..append(callout);
        
        Dropzone dropzone = new Dropzone(dropTarget);
        dropzone.onDrop.listen((DropzoneEvent dropEvent)
		{
			destroy();
			VendorWindow.insertContent(DetailsWindow.create(JSON.decode(dropEvent.draggableElement.attributes['itemMap']),vendorMap,sellMode:true));
		});
	}
}