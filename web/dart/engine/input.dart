part of coUclient;

Input playerInput;

class Input
{
    bool leftKey;
    bool rightKey;
    bool upKey;
    bool downKey;
    bool spaceKey;
	bool ignoreKeys = false;
  
    Input()
	{
		leftKey = false;
		rightKey = false;
		upKey = false;
		downKey = false;
		spaceKey = false;
    }

	//Starts listening to user imput.
	init() 
	{
		// disable default game_loop pointerlock
		game.pointerLock.lockOnClick = false;
      
		// Handle the console opener/closer
		querySelector('#ConsoleGlyph').onClick.listen((a)
		{
			if(querySelector('#DevConsole').hidden)
				showConsole();
			else
		  		hideConsole(1);
		});
		querySelector("#CloseConsole").onClick.listen((_)
		{
			hideConsole(1);
		});
	    
	    // Handle the fullscreen Requests
	    querySelector('#FullscreenGlyph').onClick.listen((a)
		{
	    	document.documentElement.requestFullscreen();
	    });  
	    querySelector('#FullscreenResetGlyph').onClick.listen((a)
		{
	    	document.exitFullscreen();
	    });  
	
	    document.onFullscreenChange.listen((_)
		{
			if (document.fullscreenElement != null)
		    {
			    printConsole('System: FullScreen = true');
			    querySelector('#FullscreenGlyph').style.display = 'none';
			    querySelector('#FullscreenResetGlyph').style.display = 'inline';
		    }
		    else
		    {
			    printConsole('System: FullScreen = false');
			    querySelector('#FullscreenGlyph').style.display = 'inline';
			    querySelector('#FullscreenResetGlyph').style.display = 'none';
		    }
		});
	  
		//Toggle mute and previous volume when volume button clicked
		Storage localStorage = window.localStorage;
		querySelector('#AudioGlyph').onClick.listen((_)
		{
			String mute = '0';
			if(localStorage['isMuted'] == '0')
			mute = '1';
			ui._setMute(mute);
		});
		//Handle volume slider changes
		InputElement volumeSlider = querySelector('#VolumeSlider');
		volumeSlider.onChange.listen((_)
		{
			setVolume(volumeSlider.value);
			localStorage['prevVolume'] = volumeSlider.value;
		});   
	      
		//handle chat input getting focused/unfocused so that the character doesn't move while typing
		ElementList chatInputs = querySelectorAll('.ChatInput');
		chatInputs.onFocus.listen((_)
		{
			ignoreKeys = true;
		});
		chatInputs.onBlur.listen((_)
		{
			ignoreKeys = false;
		});
	     
	    //Handle player input
	    //KeyUp and KeyDown are neccesary for preventing weird movement glitches
	    //keyCode's could be configurable in the future
	    document.onKeyDown.listen((KeyboardEvent k)
		{
			if ((k.keyCode == 38 || k.keyCode == 87) && !ignoreKeys) //up arrow or w and not typing
				upKey = true;
			if ((k.keyCode == 40 || k.keyCode == 83) && !ignoreKeys) //down arrow or s and not typing
				downKey = true;
			if ((k.keyCode == 37 || k.keyCode == 65) && !ignoreKeys) //left arrow or a and not typing
				leftKey = true;
			if ((k.keyCode == 39 || k.keyCode == 68) && !ignoreKeys) //right arrow or d and not typing
				rightKey = true;
			if (k.keyCode == 32 && !ignoreKeys) //spacebar and not typing
				spaceKey = true;
	    });
	    
	    document.onKeyUp.listen((KeyboardEvent k)
		{
			if ((k.keyCode == 38 || k.keyCode == 87) && !ignoreKeys) //up arrow or w and not typing
				upKey = false;
			if ((k.keyCode == 40 || k.keyCode == 83) && !ignoreKeys) //down arrow or s and not typing
				downKey = false;
			if ((k.keyCode == 37 || k.keyCode == 65) && !ignoreKeys) //left arrow or a and not typing
				leftKey = false;
			if ((k.keyCode == 39 || k.keyCode == 68) && !ignoreKeys) //right arrow or d and not typing
				rightKey = false;
			if (k.keyCode == 32 && !ignoreKeys) //spacebar and not typing
				spaceKey = false;
	    });
	    
		//demo right-clicking
		document.body.onContextMenu.listen((e) => showClickMenu(e,'Testing Right Click', 'this is a demo',[]));
		playerInput = this;
    }
	
	// Right-click menu functions
	hideClickMenu() 
	{
		if (querySelector('#RightClickMenu') != null)
		querySelector('#RightClickMenu').remove();
	}
	
	showClickMenu(MouseEvent Click, String title, String description, List<List> options)
	{
		hideClickMenu();
		TemplateElement t = querySelector('#RC_Template');
		Node menu = document.body.append(t.content.clone(true));
		int x,y;
		if (Click.page.y > window.innerHeight/2)
		y = Click.page.y - 55 - (options.length * 30);
		else
		y = Click.page.y - 10;
		if (Click.page.x > window.innerWidth/2)
		x = Click.page.x - 120;
		else
		x = Click.page.x - 10;
		querySelector('#ClickTitle').text = title;
		querySelector('#ClickDesc').text = description;
		List <Element> newOptions = new List();
		for (List option in options)
		{
			DivElement menuitem = new DivElement()
				..classes.add('RCItem')
				..text = option[0]
				..onClick.listen((_){doThisForMe(option[2]);});
			newOptions.add(menuitem);
		}
		querySelector('#RCActionList').children.addAll(newOptions);
		querySelector('#RightClickMenu').style
		..opacity = '1.0'
		..position = 'absolute'
		..top  = '$y' 'px'
		..left = '$x' 'px';
		
		printConsole('Spawned rc window called "' + title + '".');
		
		document.onClick.listen((_)
		{
			hideClickMenu();
		});
	}
}
