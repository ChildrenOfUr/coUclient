part of couclient;
// Handles all the engine's audio needs




SoundManager sound = new SoundManager();
class SoundManager {
  Batch ui_sounds;
  SC sc = new SC('7d2a07867f8a3d47d4f059b600b250b1');
  Map songs;

  Future init() {
    app.print('Loading Sounds..');
    final c = new Completer();
    ui_sounds = new Batch([//iOS/safari/IE doesn't seem to like .ogg files
      //and dartium/Opera/older Firefox doesn't seem to like .mp3 files
      //here's a fix for dartium http://downloadsquad.switched.com/2010/06/24/play-embedded-mp3-audio-files-chromium/
      //also I updated the loadie library to attempt to find both a .mp3 file and a .ogg file at the specified location
      //this should help with browser compatibility
      new Asset('./lib/system/loading.mp3'), new Asset('./lib/system/mention.mp3'), new Asset('./lib/system/drop.mp3'), new Asset('./lib/system/game_loaded.mp3'), new Asset('./lib/music.json') // soundcloud json
    ])..load(app.print, app.loadStatus2).then((_) {
          //start the loading music and attach it to the loadingScreen so that when that is removed the music stops
          play('loading', element: app.loadingScreen);

          Map soundcloud = ASSET['music'].get();
          songs = new Map();
          for (String name in soundcloud.keys) songs[name] = sc.load(soundcloud[name]['scid']);

          c.complete();
        }).catchError((e) //in case audio does not start to load within 2 seconds
        {
          app.print(e.toString());
          c.complete(e);
        });
    return c.future;
  }

  play(String name, {Element element}) { // This will play any loaded sound
    if (element == null) element = document.documentElement;
    if (ASSET[name] != null) {
      AudioElement sound = ASSET[name].get();
      sound.volume = app.volume / 100;
      element.append(sound);
      sound.play();
      sound.onEnded.listen((_) => sound.remove());
    } else if (songs[name] != null) {
      Future<Scound> sound = songs[name];
      sound.then((Scound s) {
        app.SCsong = s.meta['title'];
        app.SCartist = s.meta['user']['username'];
        app.SClink = s.meta['permalink_url'];
        s.play();
      });
    } else app.print('$name is not a recognised sound.');
  }
}
