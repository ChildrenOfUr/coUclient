part of coUclient;
// Handles all the engine's audio needs

//respect previous volume setting (if any)
String prevVolume = localStorage['prevVolume'];
String isMuted = localStorage['isMuted'];

Map<String,Sound> gameSounds = {};
Map<String,AudioChannel> audioChannels = {};
bool useWebAudio = true;

// Stores all the loaded user interface sounds.
Batch ui_sounds;

init_audio()
{
	try
	{
		audioChannels['soundEffects'] = new AudioChannel("soundEffects")..gain = .5;
        audioChannels['music'] = new AudioChannel("music")..gain = .5;
	}
	catch(e)
	{
		print("browser does not support web audio: $e");
		useWebAudio = false;
	}
	
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
	
	if(useWebAudio)
	{
		List<Future> futures = [];
		String extension = "ogg";
        	
    	//if canPlayType returns the empty string, that format is not compatible
    	if(new AudioElement().canPlayType('audio/ogg') == "")
    	{
    		print("ogg not supported, using mp3s instead");
    		extension = "mp3";
    	}
    	
    	try
    	{
			//load the loading music and play when ready
		  	gameSounds['loading'] = new Sound(channel:audioChannels['music']);
		  	futures.add(gameSounds['loading'].load("assets/system/loading.$extension"));
		      	
		  	//load the sound effects
		  	gameSounds['quoinSound'] = new Sound(channel:audioChannels['soundEffects']);
		  	futures.add(gameSounds['quoinSound'].load("assets/system/quoinSound.$extension"));
		  	gameSounds['mention'] = new Sound(channel:audioChannels['soundEffects']);
		  	futures.add(gameSounds['mention'].load("assets/system/mention.$extension"));
		  	gameSounds['game_loaded'] = new Sound(channel:audioChannels['soundEffects']);
		  	futures.add(gameSounds['game_loaded'].load("assets/system/game_loaded.$extension"));
		  	
		  	Asset soundCloudSongs = new Asset('./assets/music.json');
		  	futures.add(soundCloudSongs.load(statusElement:querySelector("#LoadStatus2")));
		  	
		  	return Future.wait(futures);
    	}
    	catch(e)
    	{
    		print("there was a problem: $e");
    		useWebAudio = false;
    		return loadNonWebAudio(c);
    	}
	}
	else
	{
		return loadNonWebAudio(c);
	}
}

Future loadNonWebAudio(Completer c)
{
	// Load all our user interface sounds.
 	ui_sounds = new Batch
			([
				//iOS/safari/IE doesn't seem to like .ogg files
				//and dartium/Opera/older Firefox doesn't seem to like .mp3 files
				//here's a fix for dartium http://downloadsquad.switched.com/2010/06/24/play-embedded-mp3-audio-files-chromium/
				//also I updated the loadie library to attempt to find both a .mp3 file and a .ogg file at the specified location
				//this should help with browser compatibility
				new Asset('./assets/system/loading.mp3'),
		        new Asset('./assets/system/mention.mp3'),
		        new Asset('./assets/system/quoinSound.mp3'),
		        new Asset('./assets/system/game_loaded.mp3')
	        ])
 	..load(print,statusElement:querySelector("#LoadStatus2")).then((_)
 	{ 		
 		//start the loading music and attach it to the #LoadingScreen so that when that is removed the music stops
 		if(int.parse(prevVolume) > 0 && isMuted == '0')
 		{
 			playSound('loading',parentElement:querySelector('#LoadingScreen'),looping:true);
 		}
 	})
 	.catchError((e) //in case audio does not start to load within 2 seconds
 	{
 		print("error while loading sounds: $e");
 	})
 	.whenComplete(() //load SC songs no matter which
 	{
 		// Load the names and track id's of the music.json file but save actually loading the media file
 		// until it is requested (whether by street load or by setsong command)
 		Asset soundCloudSongs = new Asset('./assets/music.json');
 		soundCloudSongs.load(statusElement:querySelector("#LoadStatus2")).then((_) => c.complete());
 	});
	return c.future;
}

playSound(String name, {bool looping : false, Element parentElement : null})
{
	if(useWebAudio)
	{
		return gameSounds[name].play(looping:looping);
	}
	else
	{
		AudioElement loading = ASSET[name].get();
		loading.loop = looping;
		loading.volume = int.parse(prevVolume)/100;
		if(parentElement != null)
			parentElement.append(loading);
		loading.play();
		return loading;
	}
}

void stopSound(soundObjectToStop)
{
	if(useWebAudio)
	{
		(soundObjectToStop as AudioInstance).stop();
	}
	else
	{
		AudioElement audio = soundObjectToStop as AudioElement;
		try
		{
			audio.pause();
			audio.remove();
		}
		catch(e){}
	}
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