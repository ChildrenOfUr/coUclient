part of couclient;

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
			}
			else
			{
				(querySelector("#MobileStyle") as LinkElement).disabled = true;
				target.text = "Mobile View";
				localStorage["interface"] = "desktop";
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
}

String fromKeyCode(int keyCode) {
  String keyPressed = "";
  if (keyCode == 8) keyPressed = "backspace"; //  backspace
  if (keyCode == 9) keyPressed = "tab"; //  tab
  if (keyCode == 13) keyPressed = "enter"; //  enter
  if (keyCode == 16) keyPressed = "shift"; //  shift
  if (keyCode == 17) keyPressed = "ctrl"; //  ctrl
  if (keyCode == 18) keyPressed = "alt"; //  alt
  if (keyCode == 19) keyPressed = "pause/break"; //  pause/break
  if (keyCode == 20) keyPressed = "caps lock"; //  caps lock
  if (keyCode == 27) keyPressed = "escape"; //  escape
  if (keyCode == 32) keyPressed = "space"; // space;
  if (keyCode == 33) keyPressed = "page up"; // page up, to avoid displaying alternate character and confusing people
  if (keyCode == 34) keyPressed = "page down"; // page down
  if (keyCode == 35) keyPressed = "end"; // end
  if (keyCode == 36) keyPressed = "home"; // home
  if (keyCode == 37) keyPressed = "left arrow"; // left arrow
  if (keyCode == 38) keyPressed = "up arrow"; // up arrow
  if (keyCode == 39) keyPressed = "right arrow"; // right arrow
  if (keyCode == 40) keyPressed = "down arrow"; // down arrow
  if (keyCode == 45) keyPressed = "insert"; // insert
  if (keyCode == 46) keyPressed = "delete"; // delete
  if (keyCode == 91) keyPressed = "left window"; // left window
  if (keyCode == 92) keyPressed = "right window"; // right window
  if (keyCode == 93) keyPressed = "select key"; // select key
  if (keyCode == 96) keyPressed = "numpad 0"; // numpad 0
  if (keyCode == 97) keyPressed = "numpad 1"; // numpad 1
  if (keyCode == 98) keyPressed = "numpad 2"; // numpad 2
  if (keyCode == 99) keyPressed = "numpad 3"; // numpad 3
  if (keyCode == 100) keyPressed = "numpad 4"; // numpad 4
  if (keyCode == 101) keyPressed = "numpad 5"; // numpad 5
  if (keyCode == 102) keyPressed = "numpad 6"; // numpad 6
  if (keyCode == 103) keyPressed = "numpad 7"; // numpad 7
  if (keyCode == 104) keyPressed = "numpad 8"; // numpad 8
  if (keyCode == 105) keyPressed = "numpad 9"; // numpad 9
  if (keyCode == 106) keyPressed = "multiply"; // multiply
  if (keyCode == 107) keyPressed = "add"; // add
  if (keyCode == 109) keyPressed = "subtract"; // subtract
  if (keyCode == 110) keyPressed = "decimal point"; // decimal point
  if (keyCode == 111) keyPressed = "divide"; // divide
  if (keyCode == 112) keyPressed = "F1"; // F1
  if (keyCode == 113) keyPressed = "F2"; // F2
  if (keyCode == 114) keyPressed = "F3"; // F3
  if (keyCode == 115) keyPressed = "F4"; // F4
  if (keyCode == 116) keyPressed = "F5"; // F5
  if (keyCode == 117) keyPressed = "F6"; // F6
  if (keyCode == 118) keyPressed = "F7"; // F7
  if (keyCode == 119) keyPressed = "F8"; // F8
  if (keyCode == 120) keyPressed = "F9"; // F9
  if (keyCode == 121) keyPressed = "F10"; // F10
  if (keyCode == 122) keyPressed = "F11"; // F11
  if (keyCode == 123) keyPressed = "F12"; // F12
  if (keyCode == 144) keyPressed = "num lock"; // num lock
  if (keyCode == 145) keyPressed = "scroll lock"; // scroll lock
  if (keyCode == 225) keyPressed = "alt"; //right alt

  return keyPressed;
}


