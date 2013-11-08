part of coUclient;

//Starts listening to user imput.
  initializeInput() {
  
  // Disable the default functionality of game_loop
  loop.pointerLock.lockOnClick = false;

  // Handle the console opener
  query('#ConsoleGlyph').onClick.listen((a){
  showConsole();
  });  
    // Handle the fullscreen Requests
  query('#FullscreenGlyph').onClick.listen((a){
  document.documentElement.requestFullscreen();
  });  
  query('#FullscreenResetGlyph').onClick.listen((a){
  document.exitFullscreen();
  });  
  document.onFullscreenChange.listen((_)
      {
        if (document.fullscreenEnabled)
        {
          printConsole('System: FullScreen = true');
          query('#FullscreenGlyph').style.display = 'none';
          query('#FullscreenResetGlyph').style.display = 'inline';
          
        }
        else
        {
          printConsole('System: FullScreen = false');
          query('#FullscreenGlyph').style.display = 'inline';
          query('#FullscreenResetGlyph').style.display = 'none';
        }
      });

  //Handle player keypress input
  //TODO setup general keypress input functions.
  
  
  
}
