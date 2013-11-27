part of coUclient;

Future loadAssets(){
  // Play the loading music.
  AudioElement Loading = new AudioElement('./assets/sounds/loading.ogg');
  querySelector('#LoadingScreen').append(Loading);
  Loading.play();
  
  // initialize ResourceManager and load images and sounds
  resourceManager = new xl.ResourceManager()
  
  // images
  
  
  
  // sounds
  
  
  
  // streets
  ..addTextFile('test', './assets/data/location/' + 'test' + '.json')
  
  
  ;

  // When done loading, 'hideLoader()'
  return resourceManager.load()
    .then((_) => hideLoader())
    .then((_){})
    .catchError((e) => print(e));
}


void hideLoader() {
  // Connect our stagexl canvas to our displayContainer
  // see display.dart
  stage.addChild(new displayContainer());
  
  // Peacefully fade out the loading screen.
  querySelector('#LoadingScreen').style.opacity = '0.0';
  Timer t = new Timer(new Duration(seconds:1), querySelector('#LoadingScreen').remove);
  
  // Play the 'doneloading' sound
  AudioElement doneLoading = new AudioElement('./assets/sounds/game_loaded.ogg');
  document.body.append(doneLoading);
  doneLoading.play();
  listenForLeave(); 
}


listenForLeave(){
  //Start listening for the game's exit and display "You Won!"
  window.onBeforeUnload.listen((_)
      {
    querySelector('#YouWon').hidden = false;    
      });
}


