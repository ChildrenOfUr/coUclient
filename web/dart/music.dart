part of coUclient;


String client_ID = "7d2a07867f8a3d47d4f059b600b250b1";


playMusic(String asset){  
  AudioElement musicBox = querySelector('#MusicBox');
  
  String title = assets['music.' + asset]['title'];
  String artist = assets['music.' + asset]['user']['username'];
  print('$title by $artist');
  
  
  // Changes the ui
  ui._setSong(artist, title);
  
  musicBox.src = assets['music.' + asset]['stream_url'] + '?client_id=$client_ID';
  musicBox.play();
  musicBox.onEnded.listen((_) => musicBox.play());
  
  
}
