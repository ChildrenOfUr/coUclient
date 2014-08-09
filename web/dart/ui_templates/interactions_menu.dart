part of coUclient;

class InteractionWindow
{
	static Element create()
	{
		DivElement interactionWindow = new DivElement()..id="InteractionWindow"..className="interactionWindow";
		
		DivElement header = new DivElement()..className="PopWindowHeader handle";
		DivElement title = new DivElement()..id="InteractionTitle"..text="Interact With...";
		SpanElement close = new SpanElement()..id="CloseInteraction"..className="fa fa-times fa-lg red PopCloseEmblem";
		header..append(title)..append(close);
		
		DivElement content = new DivElement()..id="InteractionContent";
		
		interactionWindow..append(header)..append(content);
		
    	close.onClick.first.then((_) => playerInput.stopMenu(interactionWindow));
    	
        for(String id in CurrentPlayer.intersectingObjects.keys)
		{
			DivElement container = new DivElement()
				..style.display = "inline-block"
				..style.textAlign = "center"
				..classes.add("entityContainer");
			Element oldEntity = querySelector("#$id");
			Element entity = oldEntity.clone(false);
			if(oldEntity is CanvasElement)
				(entity as CanvasElement).context2D.drawImage(oldEntity, 0, 0);
			entity.style.transform = "";
			entity.style.position = "";
			entity.style.display = "block";
			entity.style.margin = "auto";
			entity.attributes['id'] = id;
			container.append(entity);
			SpanElement text = new SpanElement()..text = entity.attributes['type'];
			container.append(text);
			container.onMouseOver.listen((_)
			{
				content.children.forEach((Element child)
				{
					if(child != container)
						child.classes.remove("entitySelected");
				});
				container.classes.add("entitySelected");
			});
			container.onClick.first.then((MouseEvent e)
			{
				e.stopPropagation();
				playerInput.stopMenu(interactionWindow);
                playerInput.interactWithObject(id);
			});
			content.append(container);
		}
        
        content.children.first.classes.add("entitySelected");
        
        playerInput.menuKeyListener = document.onKeyDown.listen((KeyboardEvent k)
		{
        	Map keys = playerInput.keys;
        	bool ignoreKeys = playerInput.ignoreKeys;
			if((k.keyCode == keys["UpBindingPrimary"] || k.keyCode == keys["UpBindingAlt"]) && !ignoreKeys) //up arrow or w and not typing
				playerInput.stopMenu(interactionWindow);
			if((k.keyCode == keys["DownBindingPrimary"] || k.keyCode == keys["DownBindingAlt"]) && !ignoreKeys) //down arrow or s and not typing
				playerInput.stopMenu(interactionWindow);
			if((k.keyCode == keys["LeftBindingPrimary"] || k.keyCode == keys["LeftBindingAlt"]) && !ignoreKeys) //left arrow or a and not typing
				playerInput.selectUp(content,"entitySelected");
			if((k.keyCode == keys["RightBindingPrimary"] || k.keyCode == keys["RightBindingAlt"]) && !ignoreKeys) //right arrow or d and not typing
				playerInput.selectDown(content,"entitySelected");
			if((k.keyCode == keys["JumpBindingPrimary"] || k.keyCode == keys["JumpBindingAlt"]) && !ignoreKeys) //spacebar and not typing
				playerInput.stopMenu(interactionWindow);
			if((k.keyCode == keys["ActionBindingPrimary"] || k.keyCode == keys["ActionBindingAlt"]) && !ignoreKeys) //spacebar and not typing
			{
				playerInput.stopMenu(interactionWindow);
				playerInput.interactWithObject(content.querySelector('.entitySelected').children.first.attributes['id']);
			}
		});
        document..onKeyUp.listen((KeyboardEvent k)
		{
			if(k.keyCode == 27)
				playerInput.stopMenu(interactionWindow);
		});
		document.onClick.listen((_) => playerInput.stopMenu(interactionWindow));
	
		return interactionWindow;
	}
	
	static void destroy()
	{
		querySelector("#InteractionWindow").remove();
	}
}