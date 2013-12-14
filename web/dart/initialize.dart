part of coUclient;


init(){
    // The player has requested that the game is to begin.
  
  // Play the loading music.
  AudioElement Loading = new AudioElement('./assets/system/loading.ogg');
  querySelector('#LoadingScreen').append(Loading);
  Loading.play();
  
  assets.loadPack('music', 'assets/music.pack')
    .then((_) =>
  assets.loadPack('streets', 'assets/streets.pack'))
    .then((_)
        {

    // Peacefully fade out the loading screen.
    querySelector('#LoadingScreen').style.opacity = '0.0';
    Timer t = new Timer(new Duration(seconds:1), querySelector('#LoadingScreen').remove);
    
    // Play the 'doneloading' sound
    AudioElement doneLoading = new AudioElement('./assets/system/game_loaded.ogg');
    document.body.append(doneLoading);
    doneLoading.play();
    //doneLoading.onEnded.listen((_) => doneLoading.remove());
    

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
    
    
    setSong('firebog');
    
    Street s = new Street('streets.street');
    s.load();

    
        }
    );
}
















