part of coUclient;


init(){
    // The player has requested that the game is to begin.
  
  // Play the loading music.
  AudioElement Loading = new AudioElement('./assets/sounds/loading.ogg');
  querySelector('#LoadingScreen').append(Loading);
  Loading.play();
    
  assets.loadPack('groddle', 'assets/packs/groddle.pack').then((_)
        {

// Peacefully fade out the loading screen.
    querySelector('#LoadingScreen').style.opacity = '0.0';
    Timer t = new Timer(new Duration(seconds:1), querySelector('#LoadingScreen').remove);
    
    // Play the 'doneloading' sound
    AudioElement doneLoading = new AudioElement('./assets/sounds/game_loaded.ogg');
    document.body.append(doneLoading);
    doneLoading.play();
    

    // Set the meters to their current values.
    ui.init();      

    printConsole('System: Initializing..');
    
    // Start listening for page resizes
    resize();
    window.onResize.listen((_) => resize());
    
    // Start listening for clicks and key presses
    initializeInput();
    
    printConsole('System: Initialization Finished.');
    printConsole('');
    
    printConsole('COU DEVELOPMENT CONSOLE V0.4');
    printConsole('For a list of commands type "help"');
    
    
    Street s = new Street('groddle.street');
    s.load();

    
        }
    );
}
















