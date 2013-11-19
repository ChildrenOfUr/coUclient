part of coUclient;

game(){
  
  querySelector('#PlayButton').onClick.listen((_)
      {
    // The player has requested that the game is to begin.
    querySelector('#PlayButton').remove();
    
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

      printConsole('System: Initialization Finished.');
      printConsole('');
      
      printConsole('COU DEVELOPMENT CONSOLE V0.4');
      printConsole('For a list of commands type "help"');

      gameLoop.start();
});
  
}

loop() {
  
  
  
  
}

