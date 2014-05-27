part of couclient;
// Handles all the engine's audio needs

// Stores all the loaded user interface sounds.
Batch ui_sounds;



// Load all our user interface sounds.
Future loadSounds() {
	final c = new Completer();
	ui_sounds = new Batch
		([
			//iOS/safari/IE doesn't seem to like .ogg files
			//and dartium/Opera/older Firefox doesn't seem to like .mp3 files
			//here's a fix for dartium http://downloadsquad.switched.com/2010/06/24/play-embedded-mp3-audio-files-chromium/
			//also I updated the loadie library to attempt to find both a .mp3 file and a .ogg file at the specified location
			//this should help with browser compatibility
			new Asset('./assets/system/loading.mp3'),
	        new Asset('./assets/system/mention.mp3'),
	        new Asset('./assets/system/drop.mp3'),
	        new Asset('./assets/system/game_loaded.mp3')
        ])
	..load(print,display.loadStatus2).then((_)
	{
		//start the loading music and attach it to the #LoadingScreen so that when that is removed the music stops
		if(display.volume > 0 && display.muted == false)
		{
			AudioElement loading = ASSET['loading'].get();
			loading.volume = display.volume/100;
			display.loadingScreen.append(loading);
			loading.play();
		}
		c.complete();
	})
	.catchError((e) //in case audio does not start to load within 2 seconds
	{
		print(e);
		c.complete(e);
	});
	return c.future;
}