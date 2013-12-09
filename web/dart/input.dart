part of coUclient;

  //Starts listening to user imput.
  initializeInput() {
  
  // disable default game_loop pointerlock
   game.pointerLock.lockOnClick = false;
    
    
  // Handle the console opener
  querySelector('#ConsoleGlyph').onClick.listen((a){
  showConsole();
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
        if (document.fullscreenEnabled)
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
   


  //Handle player keypress input
  //TODO setup general keypress input functions.
  
  document.onKeyPress.listen((KeyboardEvent k)
      {
        if (k.keyCode == 119)// w
          camera['y']-=20;
        if (k.keyCode == 115)// s
          camera['y']+=20;
        if (k.keyCode == 97)// a
          camera['x']-=20;
        if (k.keyCode == 100)// d
          camera['x']+=20;
      
      printConsole(k.keyCode.toString());
      
      });
  
  
  
  
  
  //demo right-clicking
  document.body.onContextMenu.listen((e) => showClickMenu(e,'Testing Right Click', 'this is a demo',[]));
  
}
