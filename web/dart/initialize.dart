part of coUclient;


init(){
    // The player has requested that the game is to begin.
  
  //respect previous volume setting (if any)
  Storage localStorage = window.localStorage;
  String prevVolume = localStorage['prevVolume'];
  String isMuted = localStorage['isMuted'];
  if(prevVolume != null)
  {
    setSoundVolume(prevVolume);
    (querySelector('#VolumeSlider') as InputElement).value = prevVolume;
    querySelector('#rangevalue').innerHtml = prevVolume;
  }
  else
  {
    prevVolume = '50';
    localStorage['prevVolume'] = '50';
  }
  if(isMuted == null)
  {
    isMuted = '0';
    localStorage['isMuted'] = '0';
  }
  ui._setMute(isMuted);
 
  if(int.parse(prevVolume) > 0 && isMuted == '0')
  {
    // Play the loading music.
    AudioElement Loading = new AudioElement('./assets/system/loading.ogg');
    Loading.volume = int.parse(prevVolume)/100;
    querySelector('#LoadingScreen').append(Loading);
    Loading.play();
  }
  
  assets.loadPack('sounds', './assets/sounds.pack')// These will just be non-music sounds.
    .then((AssetPack sounds) 
        {
      // Load all our SoundCloud songs and store the resulting SCsongs in the jukebox
      // Someday we may want to do this individually when a street loads, rather than all at once.
      List songsToLoad = new List();
      for (String song in sounds['music'].keys)
      {
         Future future = ui.SC.load(sounds['music'][song]['scid']).then((scSong) => ui.jukebox[song] = scSong);
         songsToLoad.add(future);
      }
      return Future.wait(songsToLoad);
        })
    .then((_) => assets.loadPack('streets', './assets/streets.pack'))
    .then((_)
        {
      
      

    // Peacefully fade out the loading screen.
    querySelector('#LoadingScreen').style.opacity = '0.0';
    Timer t = new Timer(new Duration(seconds:1), querySelector('#LoadingScreen').remove);
    
    if(int.parse(prevVolume) > 0 && isMuted == '0')
    {
      // Play the 'doneloading' sound
      AudioElement doneLoading = new AudioElement('./assets/system/game_loaded.ogg');
      doneLoading.volume = int.parse(prevVolume)/100;
      document.body.append(doneLoading);
      doneLoading.play();
      doneLoading.onEnded.listen((_) => doneLoading.remove()); 
    }
    

    // Set the meters to their current values.
    ui.init();      

    printConsole('System: Initializing..');
    
    // Start listening for page resizes
    resize();
    window.onResize.listen((_) => resize());
    
    // Start listening for clicks and key presses
    playerInput = new Input();
    playerInput.initialize();
    
    printConsole('System: Initialization Finished.');
    printConsole('');
    
    printConsole('COU DEVELOPMENT CONSOLE V0.4');
    printConsole('For a list of commands type "help"');
    
    
    Street s = new Street('streets.street');
    s.load();
    setSong('firebog');
    
    document.body.children.add(gameCanvas);
    
    gameScreen.append(gameCanvas);
    
    gameCanvas.style.zIndex = ('0');
    gameCanvas.width = CurrentStreet.width;
    gameCanvas.height = CurrentStreet.height;
    
    gameCanvas.style.position = 'absolute';
    gameCanvas.style.left = '0 px';
    gameCanvas.style.top =  '0 px';   
    
    Player CurrentPlayer = new Player();
    
    CurrentCamera = new Camera();
    
        }
    );
}
















