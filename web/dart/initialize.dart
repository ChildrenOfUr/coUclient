part of coUclient;


init(){
    // The player has requested that the game is to begin.
  
  //respect previous volume setting (if any)
  Storage localStorage = window.localStorage;
  String prevVolume = localStorage['prevVolume'];
  String isMuted = localStorage['isMuted'];
  if(prevVolume != null)
  {
    setVolume(prevVolume);
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
  
  assets.loadPack('music', './assets/music.pack')
    .then((_) =>
  assets.loadPack('streets', './assets/streets.pack'))
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
      //doneLoading.onEnded.listen((_) => doneLoading.remove()); 
    }
    

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
















