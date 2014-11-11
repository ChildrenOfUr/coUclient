part of couclient;
// Handles all the engine's audio needs


class SoundManager {
  Map<String, Sound> gameSounds = {};
  Map<String, AudioChannel> audioChannels = {};
  bool useWebAudio = true;

  // Stores all the loaded user interface sounds.
  Batch ui_sounds;

  SC sc = new SC(SC_TOKEN);
  Map songs = new Map();
  Scound currentSong;
  AudioInstance currentAudioInstance;

  SoundManager() {

    init().then((_) {
      new Service([#playSong],(Message event) {
          event.content = event.content.replaceAll(' ', '');
          if (songs[event.content] == null) {
            loadSong(event.content).then((_) {
              _playSong(event.content);
            });
          } else {
            _playSong(event.content);
          }
      });
      new Service([#playSound],(Message event) {
        this.playSound(event.content);
      });
    });
  }

  Future init() {

    try {
      audioChannels['soundEffects'] = new AudioChannel("soundEffects")..gain = view.slider.volume / 100;
      audioChannels['music'] = new AudioChannel("music")..gain = view.slider.volume / 100;
    } catch (e) {
      print("browser does not support web audio: $e");
      useWebAudio = false;
    }
    final c = new Completer();

    if (useWebAudio) {
      List<Future> futures = [];
      String extension = "ogg";

      //if canPlayType returns the empty string, that format is not compatible
      if (new AudioElement().canPlayType('audio/ogg') == "") {
        print("ogg not supported, using mp3s instead");
        extension = "mp3";
      }

      try {
        //load the loading music and play when ready
        gameSounds['loading'] = new Sound(channel: audioChannels['music']);
        futures.add(gameSounds['loading'].load("assets/audio/loading.$extension"));

        //load the sound effects
        gameSounds['quoinSound'] = new Sound(channel: audioChannels['soundEffects']);
        futures.add(gameSounds['quoinSound'].load("assets/audio/quoinSound.$extension"));
        gameSounds['mention'] = new Sound(channel: audioChannels['soundEffects']);
        futures.add(gameSounds['mention'].load("assets/audio/mention.$extension"));
        gameSounds['game_loaded'] = new Sound(channel: audioChannels['soundEffects']);
        futures.add(gameSounds['game_loaded'].load("assets/audio/game_loaded.$extension"));

        Asset soundCloudSongs = new Asset('./assets/json/music.json');
        futures.add(soundCloudSongs.load(statusElement: querySelector("#LoadStatus2")));

        return Future.wait(futures);
      } catch (e) {
        print("there was a problem: $e");
        useWebAudio = false;
        return loadNonWebAudio(c);
      }
    } else {
      return loadNonWebAudio(c);
    }

  }


  Future loadNonWebAudio(Completer c) {
    new Message(#toast, 'Loading non-WebAudio');
    // Load all our user interface sounds.
    ui_sounds = new Batch([//iOS/safari/IE doesn't seem to like .ogg files
      //and dartium/Opera/older Firefox doesn't seem to like .mp3 files
      //here's a fix for dartium http://downloadsquad.switched.com/2010/06/24/play-embedded-mp3-audio-files-chromium/
      //also I updated the loadie library to attempt to find both a .mp3 file and a .ogg file at the specified location
      //this should help with browser compatibility
      new Asset('assets/audio/mention.mp3'), new Asset('assets/audio/quoinSound.mp3'), new Asset('assets/audio/game_loaded.mp3')])..load(print, statusElement: querySelector("#LoadStatus2")).then((_) {
        }).catchError((e) //in case audio does not start to load within 2 seconds
        {
          print("error while loading sounds: $e");

        }).whenComplete(() //load SC song data
        {
          // Load the names and track id's of the music.json file but save actually loading the media file
          // until it is requested (whether by street load or by setsong command)
          Asset soundCloudSongs = new Asset('assets/json/music.json');
          soundCloudSongs.load(statusElement: querySelector("#LoadStatus2")).then((_) => c.complete());
        });
    return c.future;
  }

  playSound(String name, {bool asset: true, bool looping: false, Element parentElement: null}) {
    try {
      if (useWebAudio) {
        if (asset) return gameSounds[name].play(looping: looping); else //if we say it's not an asset then load a new sound and play it as music
        {
          Sound music = new Sound(channel: audioChannels['music']);
          music.load(currentSong.streamingUrl).then((Sound music) {
            currentAudioInstance = music.play(looping: looping);
          });
        }
      } else {
        AudioElement loading = ASSET[name].get();
        loading.loop = looping;
        loading.volume = view.slider.volume / 100;
        if (parentElement != null) parentElement.append(loading);
        loading.play();
        return loading;
      }
    } catch (err) {
      print('error playing sound: $err');
    }
  }

  void stopSound(soundObjectToStop) {
    try {
      if (useWebAudio) {
        (soundObjectToStop as AudioInstance).stop();
      } else {
        AudioElement audio = soundObjectToStop as AudioElement;
        audio.pause();
        audio.remove();
      }
    } catch (err) {
      print('error stopping sound: $err');
    }
  }

  Future loadSong(String name) {
    Completer c = new Completer();
    sc.load(ASSET['music'].get()[name]['scid']).then((Scound s) {
      songs[name] = s;
      c.complete();
    });

    return c.future;
  }

  /**
   * Sets the SoundCloud widget's song to [value].  Must be one of the available songs.
   * If [value] is already playing, this method has no effect.
   */
  Future setSong(String value) {
    Completer c = new Completer();

    if (value == view.titleElement.text) {
      c.complete();
      return c.future;
    }

    value = value.replaceAll(' ', '');
    if (songs[value] == null) {
      loadSong(value).then((_) {
        _playSong(value);
        c.complete();
      });
    } else {
      _playSong(value);
      c.complete();
    }

    return c.future;
  }

  _playSong(String name) {

    /*
     * canPlayType should return:
     *    probably: if the specified type appears to be playable.
     *    maybe: if it's impossible to tell whether the type is playable without playing it.
     *    The empty string: if the specified type definitely cannot be played.
     */
    String testResult = new AudioElement().canPlayType('audio/mp3');
    if (testResult == '') {
      print('SoundCloud: Your browser doesnt like mp3s :(');
      //return;
    } else if (testResult == 'maybe') //give warning message but proceed anyway
    print('SoundCloud: Your browser may or may not fully support mp3s');

    //stop any current song
    if (useWebAudio && currentAudioInstance != null) stopSound(currentAudioInstance); else if (currentSong != null) currentSong.pause();

    //play a new song
    currentSong = songs[name];
    if (useWebAudio) {
      playSound(currentSong.streamingUrl, asset: false, looping: true);
    } else {
      currentSong.play();
      currentSong.loop(true);
    }

    // Changes the ui
    view.SCsong = currentSong.meta['title'];
    view.SCartist = currentSong.meta['user']['username'];
    view.SClink = currentSong.meta['permalink_url'];
    view.update();
  }

}
