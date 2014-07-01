part of coUclient;

Input playerInput;

class Input
{
    bool leftKey, rightKey, upKey, downKey, jumpKey;
    Map<String,int> keys = {"LeftBindingPrimary":65,"LeftBindingAlt":37,"RightBindingPrimary":68,"RightBindingAlt":39,"UpBindingPrimary":87,"UpBindingAlt":38,"DownBindingPrimary":83,"DownBindingAlt":40,"JumpBindingPrimary":32,"JumpBindingAlt":32,};
	bool ignoreKeys = false, touched = false, clickUsed = false;
	StreamSubscription keyPressSub, keyDownSub;
  
    Input()
	{
		leftKey = false;
		rightKey = false;
		upKey = false;
		downKey = false;
		jumpKey = false;
    }

	//Starts listening to user input.
	init()
	{
		setupKeyBindings();
		
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
			setVolume(volumeSlider.value,false);
		});
		CheckboxInputElement graphicsBlur = querySelector("#GraphicsBlur") as CheckboxInputElement;
		graphicsBlur.onChange.listen((_)
		{
			localStorage["GraphicsBlur"] = graphicsBlur.checked.toString();
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
			if ((k.keyCode == keys["UpBindingPrimary"] || k.keyCode == keys["UpBindingAlt"]) && !ignoreKeys) //up arrow or w and not typing
				upKey = true;
			if ((k.keyCode == keys["DownBindingPrimary"] || k.keyCode == keys["DownBindingAlt"]) && !ignoreKeys) //down arrow or s and not typing
				downKey = true;
			if ((k.keyCode == keys["LeftBindingPrimary"] || k.keyCode == keys["LeftBindingAlt"]) && !ignoreKeys) //left arrow or a and not typing
				leftKey = true;
			if ((k.keyCode == keys["RightBindingPrimary"] || k.keyCode == keys["RightBindingAlt"]) && !ignoreKeys) //right arrow or d and not typing
				rightKey = true;
			if ((k.keyCode == keys["JumpBindingPrimary"] || k.keyCode == keys["JumpBindingAlt"]) && !ignoreKeys) //spacebar and not typing
				jumpKey = true;
	    });
	    
	    document.onKeyUp.listen((KeyboardEvent k)
		{
			if ((k.keyCode == keys["UpBindingPrimary"] || k.keyCode == keys["UpBindingAlt"]) && !ignoreKeys) //up arrow or w and not typing
				upKey = false;
			if ((k.keyCode == keys["DownBindingPrimary"] || k.keyCode == keys["DownBindingAlt"]) && !ignoreKeys) //down arrow or s and not typing
				downKey = false;
			if ((k.keyCode == keys["LeftBindingPrimary"] || k.keyCode == keys["LeftBindingAlt"]) && !ignoreKeys) //left arrow or a and not typing
				leftKey = false;
			if ((k.keyCode == keys["RightBindingPrimary"] || k.keyCode == keys["RightBindingAlt"]) && !ignoreKeys) //right arrow or d and not typing
				rightKey = false;
			if ((k.keyCode == keys["JumpBindingPrimary"] || k.keyCode == keys["JumpBindingAlt"]) && !ignoreKeys) //spacebar and not typing
				jumpKey = false;
	    });
		
		//only for mobile version
		Joystick joystick = new Joystick(querySelector('#Joystick'),querySelector('#Knob'),deadzoneInPercent:.2);
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
				jumpKey = true;
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
				jumpKey = false;
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
			String tsid = street['tsid'];
			
			//send changeStreet to chat server
			if(chat.tabContentMap["Local Chat"].webSocket.readyState == WebSocket.OPEN)
			{
				Map map = new Map();
				map["statusMessage"] = "changeStreet";
				map["username"] = chat.username;
				map["newStreetLabel"] = label;
				map["newStreetTsid"] = tsid;
				map["oldStreet"] = currentStreet.label;
				chat.tabContentMap["Local Chat"].webSocket.send(JSON.encode(map));
			}
			
			new Asset.fromMap(street,label);
			new Street(label).load();
		});
		
		//demo right-clicking
		document.body.onContextMenu.listen((e) => showClickMenu(e,'Testing Right Click', 'this is a demo',[]));
		playerInput = this;
    }
	
	setupKeyBindings()
	{
		//this prevents 2 keys from being set at once
		if(keyPressSub != null)
			keyPressSub.cancel();
		if(keyDownSub != null)
			keyDownSub.cancel();
		
		//set up key bindings
		keys.forEach((String action, int keyCode)
		{
			List<String> storedValue = null;
			if(localStorage[action] != null)
			{
				storedValue = localStorage[action].split(".");
				keys[action] = int.parse(storedValue[0]);
			}
			else
				localStorage[action] = keys[action].toString();
			
			String key = fromKeyCode(keys[action]);
			if(key == "")
			{
				if(storedValue != null && storedValue.length > 1)
					querySelector("#$action").text = new String.fromCharCode(int.parse(storedValue[1])).toUpperCase();
				else
					querySelector("#$action").text = new String.fromCharCode((keys[action]));
			}
			else
				querySelector("#$action").text = key;
		});
	}
	
	clickOrTouch(MouseEvent mouseEvent, TouchEvent touchEvent)
	{
		//don't handle too many touch events too fast
		if(touched)
			return;
		touched = true;
		new Timer.periodic(new Duration(milliseconds: 200), (Timer timer)
		{
			timer.cancel();
			touched = false;
		});
		Element target;
		
		if(mouseEvent != null)
			target = mouseEvent.target;
		else
			target = touchEvent.target;
		
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
		
		//handle settings menu
		if(target.id == "SettingsGlyph" || target.id == "CloseSettings")
		{
			if(querySelector("#Settings").hidden)
			{
				//make sure we cancel any key reassignments left undone
				if(keyPressSub != null)
        			keyPressSub.cancel();
        		if(keyDownSub != null)
        			keyDownSub.cancel();
			}
			toggleSettings();
		}
		
		//handle key re-binds
		if(target.classes.contains("KeyBindingOption"))
		{
			if(!clickUsed)
				setupKeyBindings();
			
			target.text = "(press key to change)";

			//we need to use .listen instead of .first.then so that if the user does not press a key
			//we can cancel the listener at a later time
			keyDownSub = document.body.onKeyDown.listen((KeyboardEvent event)
			{
				keyDownSub.cancel();
				String key = fromKeyCode(event.keyCode);
				int keyCode = event.keyCode;
				if(key == "") //it was not a special key
				{
					keyPressSub = document.body.onKeyPress.listen((KeyboardEvent event)
	    			{
						keyPressSub.cancel();
	    				KeyEvent keyEvent = new KeyEvent.wrap(event);
	    				target.text = new String.fromCharCode(keyEvent.charCode).toUpperCase();
	    				keys[target.id] = keyCode; 
	    				//store keycode and charcode
	    				localStorage[target.id] = keyCode.toString()+"."+keyEvent.charCode.toString();
	    			});
				}
				else
				{
					target.text = key;
					keys[target.id] = event.keyCode;
					localStorage[target.id] = event.keyCode.toString();
				}
			});
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
		
		//handle changing streets via exit signs
		if(target.className == "ExitLabel")
		{
			//make sure loading screen is visible during load
			Element loadingScreen = querySelector('#MapLoadingScreen');
			loadingScreen.className = "MapLoadingScreenIn";
			loadingScreen.style.opacity = "1.0";
			ScriptElement loadStreet = new ScriptElement();
			loadStreet.src = target.attributes['url'];
			playerTeleFrom = target.attributes['from'];
			document.body.append(loadStreet);
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
		
		//mobile css toggle
		if(target.id == "ThemeSwitcher")
		{
			if(target.text.contains("Mobile"))
			{
				(querySelector("#MobileStyle") as LinkElement).disabled = false;
				target.text = "Desktop View";
				localStorage["interface"] = "mobile";
				//make sure that gameScreen is updated with the correct size
				//so that rendering works
				resize();
			}
			else
			{
				(querySelector("#MobileStyle") as LinkElement).disabled = true;
				target.text = "Mobile View";
				localStorage["interface"] = "desktop";
				resize();
			}
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
			resize();
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
