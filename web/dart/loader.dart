part of coUclient;

void loadAssets(){
  // Play the loading music.
  AudioElement Loading = new AudioElement('./assets/sounds/loading.ogg');
  query('#LoadingScreen').append(Loading);
  Loading.play();
  
  
  
  
  // When done loading, 'hideLoader()'
   hideLoader();
   
   window.onBeforeUnload.listen((_)
       {
     query('#YouWon').hidden = false;    
     // We need to delay the page's closing somehow.
    });
  
}


void hideLoader() {
  query('#LoadingScreen').style.opacity = '0.0';
  Timer t = new Timer(new Duration(seconds:1), query('#LoadingScreen').remove);
  
  
  AudioElement doneLoading = new AudioElement('./assets/sounds/game_loaded.ogg');
  document.body.append(doneLoading);
  doneLoading.play();
}



