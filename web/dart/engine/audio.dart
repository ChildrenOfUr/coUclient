part of coUclient;
// Handles all the engine's audio needs

//respect previous volume setting (if any)
String prevVolume = localStorage['prevVolume'];
String isMuted = localStorage['isMuted'];

// Stores all the loaded user interface sounds.
Batch ui_sounds;

init_audio()
{
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
}

Future load_audio()
{
	final c = new Completer();
  
	// Load all our user interface sounds.

	ui_sounds = new Batch
		([
			new Asset('./assets/system/loading.ogg'),
	        new Asset('./assets/system/mention.ogg'),
	        new Asset('./assets/system/game_loaded.ogg')
        ])
	..load(print).then((_)
	{
		//start the loading music and attach it to the #LoadingScreen so that when that is removed the music stops
		if(int.parse(prevVolume) > 0 && isMuted == '0')
		{
			AudioElement loading = ASSET['loading'].get();
			loading.volume = int.parse(prevVolume)/100;
			querySelector('#LoadingScreen').append(loading);
			loading.play();
		}
		
		// Load the names and track id's of the music.json file but save actually loading the media file
		// until it is requested (whether by street load or by setsong command)
    
		Asset soundCloudSongs = new Asset('./assets/music.json');
		soundCloudSongs.load(querySelector("#LoadStatus2"));
		c.complete('');
	});
    return c.future;
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