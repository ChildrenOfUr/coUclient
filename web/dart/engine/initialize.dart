part of coUclient;


main(){
  // The player has requested that the game is to begin.
  
  // run all audio initialization tasks  
  init_audio();

//////////////////////////////////////////////////////////////////////////////////////
  // Play the loading music.
  AudioElement Loading = new AudioElement('./assets/system/loading.ogg');
  if(int.parse(prevVolume) > 0 && isMuted == '0')
  {
    Loading.volume = int.parse(prevVolume)/100;
    querySelector('#LoadingScreen').append(Loading);
    Loading.play();
  }
  // This AudioElement is destroyed with the loading screen.
//////////////////////////////////////////////////////////////////////////////////////
  
  // On-game-started loading tasks  
  
    load_audio()
    .then((_) => assets.loadPack('streets', './assets/streets.pack'))
    .then((_)
        {
    // Peacefully fade out the loading screen.
    querySelector('#LoadingScreen').style.opacity = '0.0';
    Timer t = new Timer(new Duration(seconds:1), querySelector('#LoadingScreen').remove);
  
    // Set the meters to their current values.
    ui.init();      

    printConsole('System: Initializing..');
    
    // Start listening for clicks and key presses
    playerInput = new Input()
    ..init();
    
    printConsole('System: Initialization Finished.');
    printConsole('');
    
    printConsole('COU DEVELOPMENT CONSOLE');
    printConsole('For a list of commands type "help"');
    
    
    
//////////////////////////////////////////////////////////////////////////////////////
  // Play the 'doneloading' sound
    AudioElement doneLoading = new AudioElement('./assets/system/game_loaded.ogg');
    if(int.parse(prevVolume) > 0 && isMuted == '0')
    {
      doneLoading.volume = int.parse(prevVolume)/100;
      document.body.append(doneLoading);
      doneLoading.play();
      doneLoading.onEnded.listen((_) => doneLoading.remove()); 
    }
    // This AudioElement is Destroyed when it's done playing.
//////////////////////////////////////////////////////////////////////////////////////
    new Street('streets.street')
    ..load();
    
    
    // Prepare the various Systems
    world.addSystem(new CameraSystem());
    world.initialize();
    
    
    // Begin the GAME!!!
    game.start();
   });
      
}
















