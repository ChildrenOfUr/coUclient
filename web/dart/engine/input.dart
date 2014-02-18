part of coUclient;

Input playerInput;

class Input
{
    bool leftKey, rightKey, upKey, downKey, spaceKey;
	bool ignoreKeys = false, touched = false;
  
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
		//game.pointerLock.lockOnClick = false;  
	
	    document.onFullscreenChange.listen((_)
		{
			if (document.fullscreenElement != null)
		    {
			    printConsole('System: FullScreen = true');
			    querySelectorAll('.FullscreenGlyph').style.display = 'none';
			    querySelectorAll('.FullscreenResetGlyph').style.display = 'inline';
		    }
		    else
		    {
			    printConsole('System: FullScreen = false');
			    querySelectorAll('.FullscreenGlyph').style.display = 'inline';
			    querySelectorAll('.FullscreenResetGlyph').style.display = 'none';
		    }
		});
	  
		//Handle volume slider changes
		InputElement volumeSlider = querySelector('#VolumeSlider');
		volumeSlider.onChange.listen((_)
		{
			setVolume(volumeSlider.value);
		});   
	      
		//handle chat input getting focused/unfocused so that the character doesn't move while typing
		ElementList chatInputs = querySelectorAll('.Typing');
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
		
		//only for mobile version
		Joystick joystick = new Joystick(querySelector('#Joystick'),querySelector('#Knob'));
		joystick.onMove.listen((_)
		{
			if(joystick.UP) upKey = true;
			else upKey = false;
			if(joystick.DOWN) downKey = true;
			else downKey = false;
			if(joystick.LEFT) leftKey = true;
			else leftKey = false;
			if(joystick.RIGHT) rightKey = true;
			else rightKey = false;
		});
		joystick.onRelease.listen((_)
		{
			upKey = false; downKey = false; rightKey = false; leftKey = false;
		});
		document.onTouchStart.listen((TouchEvent event)
		{
			Element target = event.target;
			
			if(target.id == "AButton")
			{
				event.preventDefault(); //to disable long press calling the context menu
				spaceKey = true;
			}
			
			if(target.id == "BButton")
			{
				event.preventDefault(); //to disable long press calling the context menu
			}
		});
		document.onTouchEnd.listen((TouchEvent event)
		{
			Element target = event.target;
			
			if(target.id == "AButton")
			{
				spaceKey = false;
			}
			
			if(target.id == "BButton")
			{
			
			}
		});
		
		document.onClick.listen((MouseEvent event) => clickOrTouch(event,null));
		document.onTouchStart.listen((TouchEvent event) => clickOrTouch(null,event));
		
		new TouchScroller(querySelector('#MobileInventory'),TouchScroller.HORIZONTAL);
		new TouchScroller(querySelector('#MobileInventoryBag'),TouchScroller.HORIZONTAL);
		//end mobile specific stuff
		
		window.onMessage.listen((MessageEvent event)
		{
			Map<String,String> street = JSON.decode(event.data);
			String label = street['label'];
			
			//send changeStreet to chat server
			Map map = new Map();
			map["statusMessage"] = "changeStreet";
			map["username"] = chat.username;
			map["newStreet"] = label;
			map["oldStreet"] = currentStreet.label;
			chat.tabContentMap["Local Chat"].webSocket.send(JSON.encode(map));
			
			new Asset.fromMap(street,label);
			new Street(label).load();
		});
		
		//demo right-clicking
		document.body.onContextMenu.listen((e) => showClickMenu(e,'Testing Right Click', 'this is a demo',[]));
		playerInput = this;
    }
	
	clickOrTouch(MouseEvent mouseEvent, TouchEvent touchEvent)
	{
		Element target;
		
		if(mouseEvent != null)
		{
			//if we handled this in the onTouchStart event, don't handle it here
			if(touched)
				return;
			target = mouseEvent.target;
		}
		else
		{
			target = touchEvent.target;
			touched = true;
			new Timer.periodic(new Duration(milliseconds: 100), (Timer timer)
			{
				timer.cancel();
				touched = false;
			});
		}
		
		// Handle the console opener/closer
		if(target.id == "ConsoleGlyph")
		{
			if(querySelector('#DevConsole').hidden)
				showConsole();
			else
				hideConsole(1);
		}
		if(target.id == "CloseConsole")
		{
			hideConsole(1);
		}
		
		// Handle the fullscreen Requests
		if(target.className.contains("FullscreenGlyph"))
		{
			document.documentElement.requestFullscreen();
		}
		if(target.className.contains("FullscreenResetGlyph"))
		{
			document.exitFullscreen();
		}
		
		//Toggle mute and previous volume when volume button clicked
		//parent because it contains different elements depending on mute state
		if(target.parent.id == "AudioGlyph" || target.parent.id == "MobileAudioGlyph")
		{
			String mute = '0';
			if(localStorage['isMuted'] == '0')
				mute = '1';
			ui._setMute(mute);
		}
		
		//handle chat settings menu
		if(target.id == "ChatSettingsIcon")
		{
			Element chatMenu = querySelector("#ChatSettingsMenu");
			if(chatMenu.hidden)
				chatMenu.hidden = false;
			else
				chatMenu.hidden = true;
		}
		if(target.id == "MobileChatSettingsIcon") //mobile version
		{
			Element chatMenu = querySelector("#MobileChatSettingsMenu");
			if(chatMenu.hidden)
				chatMenu.hidden = false;
			else
				chatMenu.hidden = true;
		}
		
		//handle changing streets via exit labels
		if(target.className == "ExitLabel")
		{
			//make sure loading screen is visible during load
			Element loadingScreen = querySelector('#MapLoadingScreen');
			loadingScreen.className = "MapLoadingScreenIn";
			loadingScreen.style.opacity = "1.0";
			ScriptElement loadStreet = new ScriptElement();
			loadStreet.src = target.attributes['url'];
			document.body.append(loadStreet);
		}
		
		if(target.id == "Exits")
		{
			if(target.classes.contains("ExitsExpanded"))
			{
				target.classes.clear();
				target.classes.add("ExitsCollapsed");
				target.classes.add("icon-expand-alt");
			}
			else
			{
				target.classes.clear();
				target.classes.add("ExitsExpanded");
				target.classes.add("icon-collapse-alt");
			}
		}
		
		//show and hide map
    if(target.id == "MapGlyph")
    {
      if(querySelector('#MapWindow').hidden)
        showMap();
      else
        hideMap(1);
    }
    if(target.id == "CloseMap")
    {
      hideMap(1);
    }
		
		
		//////////////////////////////////////////
		///mobile specific click targets
		//////////////////////////////////////////
		if(target.className == "ChannelName")
		{
			//get channel name depending on which element was clicked
			String channelName = target.id.substring(target.id.indexOf("-")+1).replaceAll("_", " ");
			querySelector('#ChatChannelTitle').text = channelName;
			
			//reset unreadMessages
			chat.tabContentMap[channelName].resetMessages(mouseEvent);
			
			//
			TextInputElement input = querySelector('#MobileChatInput') as TextInputElement;
			chat.tabContentMap[channelName].processInput(input);
			
			//bring up the right screen
			querySelector('#ChatScreen').hidden = false;
			querySelector('#ChannelSelectorScreen').hidden = true;
			
			//send all conversations to z-index=0 except the one we want to see
			querySelectorAll('.Conversation').style.zIndex = "0";
			querySelector('#conversation-'+channelName.replaceAll(" ", "_")).style.zIndex = "1";
		}
		
		if(target.id == "BackFromChat")
		{
			//set all conversation's to z-index=0 to determine visibility later
			querySelectorAll('.Conversation').style.zIndex = "0";
			querySelector('#ChatScreen').hidden = true;
			querySelector('#ChannelSelectorScreen').hidden = false;
		}
		
		if(target.id == "BackFromChannelSelector")
		{
			querySelector('#ChannelSelectorScreen').hidden = true;
			querySelector('#MainScreen').hidden = false;
		}
		
		if(target.id == "ChatBubble" || target.id == "ChatBubbleText")
		{
			//if chat is reconnecting, don't do anything
			if(querySelector('#ChatBubbleDisconnect').style.display == "inline-block")
				return;
			
			querySelector('#ChannelSelectorScreen').hidden = false;
			querySelector('#MainScreen').hidden = true;
		}
		
		if(target.id == "SendButton")
		{
			//get name of channel this text should be sent to
			//then process the input using the associated TabContent object
			String channelName = querySelector('#ChatChannelTitle').text;
			TextInputElement input = querySelector('#MobileChatInput') as TextInputElement;
			
			if(input.value.trim().length == 0) //don't allow for blank messages
				return;
			
			chat.tabContentMap[channelName].parseInput(input.value);
			input.value = '';
		}
		
		if(target.id == "InventoryTitle")
		{
			Element drawer = querySelector("#InventoryDrawer");
			if(drawer.style.bottom == "0px")
				drawer.style.bottom = "-75px";
			else
				drawer.style.bottom = "0px";
		}
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
				..onClick.listen((_){runCommand(option[2]);});
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
