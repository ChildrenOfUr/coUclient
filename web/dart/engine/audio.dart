part of coUclient;
// Handles all the engine's audio needs

//respect previous volume setting (if any)
String prevVolume = localStorage['prevVolume'];
String isMuted = localStorage['isMuted'];

Map<String,Sound> gameSounds = {};
Map<String,AudioChannel> audioChannels = {};

// Stores all the loaded user interface sounds.
Batch ui_sounds;

init_audio()
{
	audioChannels['soundEffects'] = new AudioChannel("soundEffects")..gain = .5;
	audioChannels['music'] = new AudioChannel("music")..gain = .5;
	
	if(prevVolume != null)
	{
		setVolume(prevVolume,false);
		(querySelector('#VolumeSlider') as InputElement).value = prevVolume;
		querySelector('#rangevalue').text = prevVolume;
	}
	else
	{
		prevVolume = '50';
		localStorage['prevVolume'] = '50';
		setVolume(prevVolume,false);
	}
	
	if(isMuted == null)
	{
		isMuted = '0';
		localStorage['isMuted'] = '0';
	}
	ui._setMute(isMuted);
}

Future load_audio()
{
	final c = new Completer();
	
	List<Future> futures = [];
	
	//load the loading music and play when ready
	gameSounds['loadingMusic'] = new Sound(channel:audioChannels['music']);
	futures.add(gameSounds['loadingMusic'].load("assets/system/loading.ogg"));
    	
	//load the sound effects
	gameSounds['quoinSound'] = new Sound(channel:audioChannels['soundEffects']);
	futures.add(gameSounds['quoinSound'].load("assets/system/drop.ogg"));
	gameSounds['mention'] = new Sound(channel:audioChannels['soundEffects']);
	futures.add(gameSounds['mention'].load("assets/system/mention.ogg"));
	gameSounds['gameLoaded'] = new Sound(channel:audioChannels['soundEffects']);
	futures.add(gameSounds['gameLoaded'].load("assets/system/game_loaded.ogg"));
	
	return Future.wait(futures);
  
	/*/ Load all our user interface sounds.
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
	..load(print,querySelector("#LoadStatus2")).then((_)
	{
		//start the loading music and attach it to the #LoadingScreen so that when that is removed the music stops
		if(int.parse(prevVolume) > 0 && isMuted == '0')
		{
			AudioElement loading = ASSET['loading'].get();
			loading.volume = int.parse(prevVolume)/100;
			querySelector('#LoadingScreen').append(loading);
			loading.play();
		}
		c.complete();
	})
	.catchError((e) //in case audio does not start to load within 2 seconds
	{
		print(e);
		c.complete(e);
	})
	.whenComplete(() //load SC songs no matter which
	{
		// Load the names and track id's of the music.json file but save actually loading the media file
		// until it is requested (whether by street load or by setsong command)
		Asset soundCloudSongs = new Asset('./assets/music.json');
		soundCloudSongs.load(querySelector("#LoadStatus2"));
	});
    return c.future;*/
}

Future loadSong(String name)
{
	Completer c = new Completer();
	
	ui.sc.load(ASSET['music'].get()[name]['scid'])
	.then((Scound s) 
	{
		ui.jukebox[name] = s;
		c.complete();
	});
	
	return c.future;
}