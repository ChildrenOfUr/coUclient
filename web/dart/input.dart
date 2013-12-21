part of coUclient;

Input playerInput;

  class Input{
    bool leftKey;
    bool rightKey;
    bool upKey;
    bool downKey;
    bool spaceKey;
  
    Input(){
      leftKey = false;
      rightKey = false;
      upKey = false;
      downKey = false;
      spaceKey = false;
    }

  //Starts listening to user imput.
  initialize() {
  
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
    querySelector('#FullscreenGlyph').onClick.listen((a){
    document.documentElement.requestFullscreen();
    });  
    querySelector('#FullscreenResetGlyph').onClick.listen((a){
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
        
   
      
    // Right-click menu functions
    
    hideClickMenu() {
      if (querySelector('#RightClickMenu') != null)
        querySelector('#RightClickMenu').remove();
    } 
    showClickMenu(MouseEvent Click, String title, String description, List<List> options){
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
    
    document.onClick.listen((_){
      hideClickMenu();});
   }
     
    //Handle player input
    //KeyUp and KeyDown are neccesary for preventing weird movement glitches
    //keyCode's could be configurable in the future
  
    document.onKeyDown.listen((KeyboardEvent k){
      if (k.keyCode == 38 || k.keyCode == 119){//up arrow or w
        upKey = true;
      }
      if (k.keyCode == 40 || k.keyCode == 115){//down arrow or s
        downKey = true;
      }
      if (k.keyCode == 37 || k.keyCode == 97){//left arrow or a
        leftKey = true;
      }
      if (k.keyCode == 39 || k.keyCode == 100){//right arrow or d
        rightKey = true;
      }
      if (k.keyCode == 32){//spacebar
        spaceKey = true;
      }
    });
    
    document.onKeyUp.listen((KeyboardEvent k){
      if (k.keyCode == 38 || k.keyCode == 119){//up arrow or w
        upKey = false;
      }
      if (k.keyCode == 40 || k.keyCode == 115){//down arrow or s
        downKey = false;
      }
      if (k.keyCode == 37 || k.keyCode == 97){//left arrow or a
        leftKey = false;
      }
      if (k.keyCode == 39 || k.keyCode == 100){//right arrow or d
        rightKey = false;
      }
      if (k.keyCode == 32){//spacebar
        spaceKey = false;
      }
    });
    
    
    //demo right-clicking
    document.body.onContextMenu.listen((e) => showClickMenu(e,'Testing Right Click', 'this is a demo',[]));
    playerInput = this;
    }

}
