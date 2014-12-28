part of couclient;

class SellInterface
{
	static Element create(Map vendorMap)
	{
		DivElement interface = new DivElement()..id="SellInterface"..className="vendorContentInsert";

		DivElement dropTarget = new DivElement()..id="SellDropTarget";
		ImageElement callout = new ImageElement(src:"packages/couclient/system/callout_dropitem.png")..id="SellCallout";

		interface..append(dropTarget)..append(callout);

        Draggable draggable = new Draggable(querySelectorAll(".inventoryItem"),avatarHandler: new AvatarHandler.clone());
        Dropzone dropzone = new Dropzone(dropTarget, acceptor: new Acceptor.draggables([draggable]));
        print('draggable: $draggable, dropzone: $dropzone');
        dropzone.onDrop.listen((DropzoneEvent dropEvent)
		{
			VendorWindow_old.insertContent(DetailsWindow.create(JSON.decode(dropEvent.draggableElement.attributes['itemMap']),vendorMap,sellMode:true));
		});

		return interface;
	}

	static void destroy()
	{
		querySelector("#SellInterface").remove();
	}
}