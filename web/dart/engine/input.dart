part of coUclient;

Input playerInput;

class Input
{
    bool leftKey, rightKey, upKey, downKey, jumpKey, actionKey;
    Map<String,int> keys = {"LeftBindingPrimary":65,"LeftBindingAlt":37,"RightBindingPrimary":68,"RightBindingAlt":39,"UpBindingPrimary":87,"UpBindingAlt":38,"DownBindingPrimary":83,"DownBindingAlt":40,"JumpBindingPrimary":32,"JumpBindingAlt":32,"ActionBindingPrimary":13,"ActionBindingAlt":13};
	bool ignoreKeys = false, touched = false, clickUsed = false;
	StreamSubscription keyPressSub, keyDownSub, menuKeyListener;
	DateTime lastSelect = new DateTime.now();
  
    Input()
	{
		leftKey = false;
		rightKey = false;
		upKey = false;
		downKey = false;
		jumpKey = false;
		actionKey = false;
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
	    	if(ignoreKeys || menuKeyListener != null || querySelector(".fill") != null)
	    		return;
	    	
			if ((k.keyCode == keys["UpBindingPrimary"] || k.keyCode == keys["UpBindingAlt"])) //up arrow or w
				upKey = true;
			if ((k.keyCode == keys["DownBindingPrimary"] || k.keyCode == keys["DownBindingAlt"])) //down arrow or s
				downKey = true;
			if ((k.keyCode == keys["LeftBindingPrimary"] || k.keyCode == keys["LeftBindingAlt"])) //left arrow or a
				leftKey = true;
			if ((k.keyCode == keys["RightBindingPrimary"] || k.keyCode == keys["RightBindingAlt"])) //right arrow or d
				rightKey = true;
			if ((k.keyCode == keys["JumpBindingPrimary"] || k.keyCode == keys["JumpBindingAlt"])) //spacebar
				jumpKey = true;
			if ((k.keyCode == keys["ActionBindingPrimary"] || k.keyCode == keys["ActionBindingAlt"])) //enter
			{
				doObjectInteraction();
			}
	    });
	    
	    document.onKeyUp.listen((KeyboardEvent k)
		{
	    	if(ignoreKeys)
        		return;
	    	
			if ((k.keyCode == keys["UpBindingPrimary"] || k.keyCode == keys["UpBindingAlt"])) //up arrow or w 
				upKey = false;
			if ((k.keyCode == keys["DownBindingPrimary"] || k.keyCode == keys["DownBindingAlt"])) //down arrow or s 
				downKey = false;
			if ((k.keyCode == keys["LeftBindingPrimary"] || k.keyCode == keys["LeftBindingAlt"])) //left arrow or a 
				leftKey = false;
			if ((k.keyCode == keys["RightBindingPrimary"] || k.keyCode == keys["RightBindingAlt"])) //right arrow or d 
				rightKey = false;
			if ((k.keyCode == keys["JumpBindingPrimary"] || k.keyCode == keys["JumpBindingAlt"])) //spacebar 
				jumpKey = false;
			if ((k.keyCode == keys["ActionBindingPrimary"] || k.keyCode == keys["ActionBindingAlt"])) //enter 
            	actionKey = false;
	    });
		
		//only for mobile version
		Joystick joystick = new Joystick(querySelector('#Joystick'),querySelector('#Knob'),deadzoneInPercent:.2);
		joystick.onMove.listen((_)
		{
			//don't move during harvesting, etc.
			if(querySelector(".fill") == null)
			{
				if(joystick.UP) upKey = true;
    			else upKey = false;
    			if(joystick.DOWN) downKey = true;
    			else downKey = false;
    			if(joystick.LEFT) leftKey = true;
    			else leftKey = false;
    			if(joystick.RIGHT) rightKey = true;
    			else rightKey = false;
			}
			
			Element clickMenu = querySelector("#RightClickMenu");
			if(clickMenu != null)
			{
				Element list = querySelector('#RCActionList');
				//only select a new option once every 300ms
				bool selectAgain = lastSelect.add(new Duration(milliseconds:300)).isBefore(new DateTime.now());
				if(joystick.UP && selectAgain)
					selectUp(list,"RCItemSelected");
				if(joystick.DOWN && selectAgain)
					selectDown(list,"RCItemSelected");
				if(joystick.LEFT || joystick.RIGHT)
					stopMenu(clickMenu);
			}
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
				if(querySelector("#RightClickMenu") != null)
					doAction(querySelector('#RCActionList'),querySelector("#RightClickMenu"),"RCItemSelected");
				else
					doObjectInteraction();
			}
		});
		document.onTouchEnd.listen((TouchEvent event)
		{
			Element target = event.target;
			
			if(target.id == "AButton")
			{
				jumpKey = false;
			}
		});
		
		document.onClick.listen((MouseEvent event) => clickOrTouch(event,null));
		document.onTouchStart.listen((TouchEvent event) => clickOrTouch(null,event));
		
		new TouchScroller(querySelector('#InventoryBar'),TouchScroller.HORIZONTAL);
		new TouchScroller(querySelector('#InventoryBag'),TouchScroller.HORIZONTAL);
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
		
		//listen for right-clicks on entities that we're close to
		document.body.onContextMenu.listen((MouseEvent e)
		{
			Element element = e.target as Element;
			int groundY = 0, xOffset = 0, yOffset = 0;
			if(element.attributes['ground_y'] != null)
				groundY = int.parse(element.attributes['ground_y']);
			else
			{
				xOffset = camera.getX();
				yOffset = camera.getY();
			}
			num x = e.offset.x+xOffset, y = e.offset.y-groundY+yOffset;
			List<String> ids =[];
			CurrentPlayer.intersectingObjects.forEach((String id, Rectangle rect)
			{
				if(x > rect.left && x < rect.right && y > rect.top && y < rect.bottom)
					ids.add(id);
			});
			
			if(ids.length > 0)
				doObjectInteraction(e,ids);
		});
		
		playerInput = this;
    }
	
	void doObjectInteraction([MouseEvent e, List<String> ids])
	{
		if(CurrentPlayer.intersectingObjects.length > 0 && querySelector('#RightClickMenu') == null && querySelector(".fill") == null)
		{
			if(CurrentPlayer.intersectingObjects.length == 1)
				CurrentPlayer.intersectingObjects.forEach(
						(String id, Rectangle rect) => interactWithObject(id));
			else
				createMultiEntityWindow();
		}
		else
		{
			if(e != null)
			{
				//TODO show a right click menu that is meaningful or don't show anything
				//showClickMenu(e,'Testing Right Click', 'this is a demo',[["Sample"]]);
			}
		}
	}
	
	void createMultiEntityWindow()
	{
		Element oldWindow = querySelector("#InteractionWindow");
		if(oldWindow != null)
			oldWindow.remove();
		
		document.body.append(InteractionWindow.create());
    	Element multiWindow = querySelector("#InteractionWindow");
    	querySelector("#CloseInteraction").onClick.first.then((_) => stopMenu(multiWindow));
    	querySelector("#InteractionTitle").text = "Interact With...";
    	Element content = querySelector("#InteractionContent");
    	
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
				stopMenu(multiWindow);
                interactWithObject(id);
			});
			content.append(container);
		}
        
        content.children.first.classes.add("entitySelected");
        
        menuKeyListener = document.onKeyDown.listen((KeyboardEvent k)
		{
			if((k.keyCode == keys["UpBindingPrimary"] || k.keyCode == keys["UpBindingAlt"]) && !ignoreKeys) //up arrow or w and not typing
				stopMenu(multiWindow);
			if((k.keyCode == keys["DownBindingPrimary"] || k.keyCode == keys["DownBindingAlt"]) && !ignoreKeys) //down arrow or s and not typing
				stopMenu(multiWindow);
			if((k.keyCode == keys["LeftBindingPrimary"] || k.keyCode == keys["LeftBindingAlt"]) && !ignoreKeys) //left arrow or a and not typing
				selectUp(content,"entitySelected");
			if((k.keyCode == keys["RightBindingPrimary"] || k.keyCode == keys["RightBindingAlt"]) && !ignoreKeys) //right arrow or d and not typing
				selectDown(content,"entitySelected");
			if((k.keyCode == keys["JumpBindingPrimary"] || k.keyCode == keys["JumpBindingAlt"]) && !ignoreKeys) //spacebar and not typing
				stopMenu(multiWindow);
			if((k.keyCode == keys["ActionBindingPrimary"] || k.keyCode == keys["ActionBindingAlt"]) && !ignoreKeys) //spacebar and not typing
			{
				stopMenu(multiWindow);
				interactWithObject(content.querySelector('.entitySelected').children.first.attributes['id']);
			}
		});
		document.onClick.listen((_)
		{
			stopMenu(multiWindow);
		});
		document.body.append(multiWindow);
	}
	
	void interactWithObject(String id)
	{
		Element element = querySelector("#$id");
		List<List> actions = [];
		bool allDisabled = true;
		if(element.attributes['actions'] != null)
		{
			List<Map> actionsList = JSON.decode(element.attributes['actions']);
			actionsList.forEach((Map actionMap)
			{
				bool enabled = actionMap['enabled'];
				if(enabled)
					allDisabled = false;
				String error = "";
				if(actionMap['requires'] != null)
				{
					enabled = hasRequirements(actionMap['requires']);
					error = getRequirementString(actionMap['requires']);
				}
				actions.add([capitalizeFirstLetter(actionMap['action'])+"|"+actionMap['actionWord']+"|${actionMap['timeRequired']}|$enabled|$error",element.id,"sendAction ${actionMap['action']} ${element.id}"]);
			});
		}
		if(!allDisabled)
			showClickMenu(null,element.attributes['type'],"Desc",actions);
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
			{
			  ui._createMap();
				showMap(); 
			}
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
				querySelector("#InventoryDrawer").append(querySelector('#InventoryBar'));
                querySelector("#InventoryDrawer").append(querySelector('#InventoryBag'));
				//make sure that gameScreen is updated with the correct size
				//so that rendering works
				resize();
			}
			else
			{
				(querySelector("#MobileStyle") as LinkElement).disabled = true;
				target.text = "Mobile View";
				localStorage["interface"] = "desktop";
				querySelector("#Inventory").append(querySelector('#InventoryBar'));
				querySelector("#Inventory").append(querySelector('#InventoryBag'));
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
	hideClickMenu(Element window) 
	{
		if(window != null)
			window.remove();
	}
	
	showClickMenu(MouseEvent Click, String title, String description, List<List> options)
	{
		hideClickMenu(querySelector('#RightClickMenu'));
		document.body.append(RightClickMenu.create());
		Element clickMenu = querySelector('#RightClickMenu');
		Element list = querySelector('#RCActionList');
		
		int x,y;
		if(Click != null)
		{
			if (Click.page.y > window.innerHeight/2)
    			y = Click.page.y - 55 - (options.length * 30);
    		else
    			y = Click.page.y - 10;
    		if (Click.page.x > window.innerWidth/2)
    			x = Click.page.x - 120;
    		else
    			x = Click.page.x - 10;
		}
		else
		{
			num posX = CurrentPlayer.posX, posY = CurrentPlayer.posY;
			int width = CurrentPlayer.width, height = CurrentPlayer.height;
			num translateX = posX, translateY = ui.gameScreenHeight - height;
    		if(posX > currentStreet.bounds.width - width/2 - ui.gameScreenWidth/2)
    			translateX = posX - currentStreet.bounds.width + ui.gameScreenWidth;
    		else if(posX + width/2 > ui.gameScreenWidth/2)
    			translateX = ui.gameScreenWidth/2 - width/2;
    		if(posY + height/2 < ui.gameScreenHeight/2)
    			translateY = posY;
    		else if(posY < currentStreet.bounds.height - height/2 - ui.gameScreenHeight/2)
    			translateY = ui.gameScreenHeight/2 - height/2;
    		else
    			translateY = ui.gameScreenHeight - (currentStreet.bounds.height - posY);
			x = (translateX+querySelector("#RightClickMenu").clientWidth+10)~/1;
			y = (translateY+height/2)~/1;
		}
		querySelector('#ClickTitle').text = title;
		querySelector('#ClickDesc').text = description;
		List <Element> newOptions = new List();
		for (List option in options)
		{
			DivElement menuitem = new DivElement();
			menuitem..classes.add('RCItem')..text = (option[0] as String).split("|")[0];
			
			if((option[0] as String).split("|")[3] == "true")
			{
		        menuitem..onClick.listen((_)
				{
		        	int timeRequired = int.parse((option[0] as String).split("|")[2]);
		        	
					SpanElement outline = new SpanElement()
						..text = (option[0] as String).split("|")[1]
						..className = "border"
						..style.top  = '$y' 'px'
                        ..style.left = '$x' 'px';
					SpanElement fill = new SpanElement()
						..text = (option[0] as String).split("|")[1]
						..className = "fill"
						..style.transition = "width ${timeRequired/1000}s linear"
						..style.top  = '$y' 'px'
                        ..style.left = '$x' 'px';
					document.body..append(outline)..append(fill);
					//start the "fill animation"
					fill.style.width = outline.clientWidth.toString()+"px";
					
					StreamSubscription escListener;					
					Timer miningTimer = new Timer(new Duration(milliseconds:timeRequired+300), () 
					{
						outline.remove();
						fill.remove();
						sendAction((option[0] as String).split("|")[0].toLowerCase(),option[1]);
						escListener.cancel();
					});
					escListener = document.onKeyUp.listen((KeyboardEvent k)
					{
						if(k.keyCode == 27)
						{
							outline.remove();
                        	fill.remove();
                        	escListener.cancel();
                        	miningTimer.cancel();
						}
					});
				})
				..onMouseOver.listen((_)
    			{
    				list.children.forEach((Element child)
    				{
    					if(child != menuitem)
    						child.classes.remove("RCItemSelected");
    				});
    				menuitem.classes.add("RCItemSelected");
    			});
			}
			else
			{
				menuitem..classes.add('RCItemDisabled')
					    ..onMouseOver.listen((_) => querySelector('#ClickDesc').text = (option[0] as String).split("|")[4]);
			}
			newOptions.add(menuitem);
		}
		if(newOptions.length > 0 && !newOptions[0].classes.contains("RCItemDisabled"))
			newOptions[0].classes.toggle("RCItemSelected");
		
		list.children.addAll(newOptions);
		clickMenu.style
			..opacity = '1.0'
			..position = 'absolute'
			..top  = '$y' 'px'
			..left = '$x' 'px';
		
		printConsole('Spawned rc window called "' + title + '".');
		
		menuKeyListener = document.onKeyDown.listen((KeyboardEvent k)
		{
			if((k.keyCode == keys["UpBindingPrimary"] || k.keyCode == keys["UpBindingAlt"]) && !ignoreKeys) //up arrow or w and not typing
				selectUp(list,"RCItemSelected");
			if((k.keyCode == keys["DownBindingPrimary"] || k.keyCode == keys["DownBindingAlt"]) && !ignoreKeys) //down arrow or s and not typing
				selectDown(list,"RCItemSelected");
			if((k.keyCode == keys["LeftBindingPrimary"] || k.keyCode == keys["LeftBindingAlt"]) && !ignoreKeys) //left arrow or a and not typing
				stopMenu(clickMenu);
			if((k.keyCode == keys["RightBindingPrimary"] || k.keyCode == keys["RightBindingAlt"]) && !ignoreKeys) //right arrow or d and not typing
				stopMenu(clickMenu);
			if((k.keyCode == keys["JumpBindingPrimary"] || k.keyCode == keys["JumpBindingAlt"]) && !ignoreKeys) //spacebar and not typing
				stopMenu(clickMenu);
			if((k.keyCode == keys["ActionBindingPrimary"] || k.keyCode == keys["ActionBindingAlt"]) && !ignoreKeys) //spacebar and not typing
				doAction(list,clickMenu,"RCItemSelected");
		});
		document.onClick.listen((_)
		{
			stopMenu(clickMenu);
		});
	}
	
	void selectUp(Element menu, String className)
	{
		List<Element> options = menu.children;
		int removed = 0;
		for(int i=0; i<options.length; i++)
		{
			if(options[i].classes.remove(className))
				removed = i;
		}
		if(removed == 0)
			options[options.length-1].classes.add(className);
		else
			options[removed-1].classes.add(className);
		
		lastSelect = new DateTime.now();
	}
	
	void selectDown(Element menu, String className)
	{
		List<Element> options = menu.children;
		int removed = options.length-1;
		for(int i=0; i<options.length; i++)
		{
			if(options[i].classes.remove(className))
				removed = i;
		}
		if(removed == options.length-1)
			options[0].classes.add(className);
		else
			options[removed+1].classes.add(className);
		
		lastSelect = new DateTime.now();
	}
	
	void stopMenu(Element window)
	{
		if(menuKeyListener != null)
		{
			menuKeyListener.cancel();
			menuKeyListener = null;
		}
        hideClickMenu(window);
	}
	
	void doAction(Element list, Element window, String className)
	{
		for(Element element in list.children)
		{
			if(element.classes.contains(className))
			{
				element.click();
				break;
			}
		}
		stopMenu(window);
	}
}