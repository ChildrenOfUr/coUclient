library scproxy;
import 'dart:html';
import 'dart:async';
import 'dart:convert';

class Scound {
  AudioElement _sound;
  Map meta;
  
  bool paused = false;
  bool muted = false;
  bool _stopped = false;
  
  Stream onPlay;
  StreamController _stopController = new StreamController();
  Stream onStop;
  Stream onEnded;
  Stream onPause;
  StreamController _resumeController = new StreamController();
  Stream onResume;
  
  Scound(this._sound, this.meta){
    onPlay = _sound.onPlay;
    onStop = _stopController.stream;        
    onEnded = _sound.onEnded;     
    onPause = _sound.onPause;    
    onResume = _resumeController.stream;    
  }
  
  // methods act on the sound object and trigger relevant events.
  play(){
    _stopped = false;
    _sound.play();
  }
  
  loop(bool value){
    _sound.loop = value;
  }
  /* // at the moment there is a 'currentTime' problem
  *stop(){
  *  _stopped = true;
  * _sound.pause();
  * _sound.currentTime = 0;
  *  _stopController.add(null);
  *}
  */
  pause(){
    _sound.pause();
    paused = true;
    
  }
  resume(){
    _sound.play();
    paused = false;
    _resumeController.add(null);
  }
  togglePause(){
    if (paused == true)
    resume();
    else
    pause();
  }
  
  //takes values 0 to 100
  //converts to a value between 0.0 and 1.0
  volume(int value){
    _sound.volume = value/100; //int divided by int is a double in Dart
  }
  setPan(int value){// takes values -100 to 100
   
  }
  mute(){
    _sound.muted = true;
    muted = true;
  }
  unmute(){
    _sound.muted = false;
    muted = false;
  }
  toggleMute(){
   
    if (muted == true)
    muted = false;
    else
    muted = true;
  }
  
  // Destroy the sound object,and close all the event listeners
  remove(){
    _sound.remove();
    _stopController.close();
    _resumeController.close();
  }

}

class SC {
  String client_id;  
  SC(this.client_id) {} 
  
  
  Future <Scound> load(String track_id){ 
    Completer completer = new Completer();
    Scound newScound;
    Map newMeta;  
    AudioElement newAudio;
    
      // Get the metadata for the sound
      HttpRequest.getString('http://api.soundcloud.com'+ track_id +'.json?client_id=$client_id')
        .then((json){
          newMeta = JSON.decode(json);
          
       // Create and load the audio element
          newAudio = document.body.append(new AudioElement(newMeta['stream_url'] + '?client_id=$client_id'));
          newAudio.load();
          // Return the new Scound
          completer.complete(new Scound(newAudio,newMeta));
        });
    return completer.future;
  }
}