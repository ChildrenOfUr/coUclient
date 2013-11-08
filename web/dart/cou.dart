part of coUclient;

game(){
  
  query('#PlayButton').onClick.listen((_)
      {
    // The player has requested that the game is to begin.
    query('#PlayButton').remove();
    
    // Begin loading assets
    loadAssets();
    printConsole('System: Loading Assets..');
    
    // Set the meters to their current values.
    initializeMeters();
    printConsole('System: Initializing..');
    
    // Start listening for page resizes
    startResizeListener();
    
    // Start listening for clicks and key presses
    initializeInput();

    
    // Begin the gameloop
      loop.onUpdate = ((loop) {

      
      // Update game logic here. //



      // Update the in-game clock
      refreshClock();
      
     //Update 'closed' winows
      List WindowCloseButtons = queryAll('.PopCloseEmblem');
      for (Element button in WindowCloseButtons)
      button.onClick.listen((_){button.parent.remove();});

    });
      printConsole('System: Initialization Finished.');
      printConsole('');
      
      printConsole('COU DEVELOPMENT CONSOLE V0.4');
      printConsole('For a list of commands type "help"');
      
    loop.start();
});
  
}