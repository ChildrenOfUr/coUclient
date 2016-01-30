part of couclient;
// Handles all the engine's audio needs


class SoundManager {
	Map<String, Sound> gameSounds = {};
	Map<String, AudioChannel> audioChannels = {};
	bool useWebAudio = true, muted = false;
	String extension = 'ogg';

	// Stores all the loaded user interface sounds.
	Batch ui_sounds;

	SC sc = new SC(SC_TOKEN);
	Map songs = new Map();
	Scound currentSong;
	AudioInstance currentAudioInstance, loadingSound;

	SoundManager() {
		logmessage('[SoundManager] Starting up...');
		init().then((_) {
			new Service(['playSong'], (event) {
				event = event.replaceAll(' ', '');
				if (songs[event] == null) {
					loadSong(event).then((_) => _playSong(event));
				} else _playSong(event);
			});

			new Service(['playSound'], (event) => this.playSound(event));

			logmessage('[SoundManager] Registered services');
		});
	}

	init() async {
		try {
			num effectsVolume = 50, musicVolume = 50;
			if(localStorage.containsKey('effectsVolume')) effectsVolume = num.parse(localStorage['effectsVolume']);
			if(localStorage.containsKey('musicVolume')) musicVolume = num.parse(localStorage['musicVolume']);

			audioChannels['soundEffects'] = new AudioChannel("soundEffects")
				..gain = effectsVolume / 100;
			audioChannels['music'] = new AudioChannel("music")
				..gain = musicVolume / 100;
		} catch(e) {
			logmessage("[SoundManager] Browser does not support web audio: $e");
			useWebAudio = false;
		} finally {
			setMute(view.slider.muted);
		}

		if(useWebAudio) {
			//if canPlayType returns the empty string, that format is not compatible
			if(new AudioElement().canPlayType('audio/ogg') == "") {
				logmessage("[SoundManager] Ogg not supported, using mp3s instead");
				extension = "mp3";
			}

			try {
				if(!muted) {
					//load the loading music and play when ready
					gameSounds['loading'] = new Sound(channel: audioChannels['music']);
					await gameSounds['loading'].load("files/audio/loading.$extension");
					loadingSound = gameSounds['loading'].play(looping:true);
				}

				//load the sound effects

				gameSounds['quoinSound'] = new Sound(channel: audioChannels['soundEffects']);
				await gameSounds['quoinSound'].load("files/audio/quoinSound.$extension");

				gameSounds['mention'] = new Sound(channel: audioChannels['soundEffects']);
				await gameSounds['mention'].load("files/audio/mention.$extension");

				gameSounds['game_loaded'] = new Sound(channel: audioChannels['soundEffects']);
				await gameSounds['game_loaded'].load("files/audio/game_loaded.$extension");

				gameSounds['tripleJump'] = new Sound(channel: audioChannels['soundEffects']);
				await gameSounds['tripleJump'].load("files/audio/tripleJump.$extension");

				gameSounds['levelUp'] = new Sound(channel: audioChannels['soundEffects']);
				await gameSounds['levelUp'].load("files/audio/levelUp.$extension");

				gameSounds['newDay'] = new Sound(channel: audioChannels['soundEffects']);
				await gameSounds['newDay'].load("files/audio/newday_rooster.$extension");

				Asset soundCloudSongs = new Asset('./files/json/music.json');
				await soundCloudSongs.load(statusElement: querySelector("#LoadStatus2"));
			} catch(e) {
				logmessage("[SoundManager] There was a problem: $e");
				useWebAudio = false;
				await loadNonWebAudio();
			}
		} else {
			await loadNonWebAudio();
		}
	}

	// Sound Effects ////////////////////////////////////////////////////////////////////////////////

	Future loadNonWebAudio() async {
		logmessage("[SoundManager] Loading non-WebAudio");
		// Load all our user interface sounds.

		//iOS/safari/IE doesn't seem to like .ogg files
		//and dartium/Opera/older Firefox doesn't seem to like .mp3 files
		//here's a fix for dartium http://downloadsquad.switched.com/2010/06/24/play-embedded-mp3-audio-files-chromium/
		//also I updated the loadie library to attempt to find both a .mp3 file and a .ogg file at the specified location
		//this should help with browser compatibility
		try {
			ui_sounds = new Batch([
				new Asset('files/audio/mention.mp3'),
				new Asset('files/audio/quoinSound.mp3'),
				new Asset('files/audio/game_loaded.mp3'),
				new Asset('files/audio/tripleJump.mp3'),
				new Asset('files/audio/levelUp.mp3'),
				new Asset('files/audio/newday_rooster.mp3')
			]);
			await ui_sounds.load(() {
			});
			// Load the names and track id's of the music.json file but save actually loading the media file
			// until it is requested (whether by street load or by setsong command)
			Asset soundCloudSongs = new Asset('files/json/music.json');
			await soundCloudSongs.load(statusElement: querySelector("#LoadStatus2"));
		} catch(e) {
			logmessage("[SoundManager] Error while loading sounds: $e");
		}
	}

	Future playSound(String name, {bool asset: true, bool looping: false, bool fadeIn: false, Duration fadeInDuration, Element parentElement: null}) async {
		try {
			if(useWebAudio) {
				if(asset) {
					AudioInstance audio = gameSounds[name].play(looping: looping);
					if(fadeIn) {
						audio.gain = 0.0;
						if(fadeInDuration == null) {
							fadeInDuration = new Duration(seconds:5);
						}
						double currentPercentOfFade = 0.0;
						//for some reason if(audio.gain >= 1.0) threw errors about int
						//not being a subtype of double. So this steps method instead
						int steps = fadeInDuration.inMilliseconds~/100;
						new Timer.periodic(new Duration(milliseconds:100), (Timer t) {
							currentPercentOfFade += 100 / fadeInDuration.inMilliseconds;
							audio.gain = currentPercentOfFade;
							steps--;
							if(steps <= 0) {
								t.cancel();
							}
						});
					}
					return audio;
				} else {
					//if we say it's not an asset then load a new sound and play it as music
					Sound music = new Sound(channel: audioChannels['music']);
					await music.load(currentSong.streamingUrl);
					currentAudioInstance = music.play(looping: looping);
				}
			} else {
				AudioElement loading = ASSET[name].get();
				loading.loop = looping;
				if(asset) loading.volume = int.parse(localStorage['effectsVolume']) / 100; else loading.volume = int.parse(localStorage['musicVolume']) / 100;

				if(parentElement != null) {
					parentElement.append(loading);
				}

				loading.play();
				return loading;
			}
		} catch(err) {
			logmessage('[SoundManager] Error playing sound: $err');
		}
	}

	void stopSound(soundObjectToStop, {bool fadeOut:false, Duration fadeOutDuration}) {
		try {
			if(useWebAudio) {
				assert (soundObjectToStop is AudioInstance);
				AudioInstance audio = soundObjectToStop as AudioInstance;
				if(fadeOut) {
					if(fadeOutDuration == null) {
						fadeOutDuration = new Duration(seconds:5);
					}
					double currentPercentOfFade = 0.0;
					//for some reason if(audio.gain <=) threw errors about int
					//not being a subtype of double. So this steps method instead
					int steps = fadeOutDuration.inMilliseconds~/100;
					new Timer.periodic(new Duration(milliseconds:100), (Timer t) {
						currentPercentOfFade += 100 / fadeOutDuration.inMilliseconds;
						audio.gain = 1.0 - currentPercentOfFade;
						steps--;
						if(steps <= 0) {
							audio.stop();
							t.cancel();
						}
					});
				} else {
					audio.stop();
				}
			} else {
				AudioElement audio = soundObjectToStop as AudioElement;
				audio.pause();
				audio.remove();
			}
		} catch(err) {
			logmessage('[SoundManager] Error stopping sound: $err');
		}
	}

	void setMute(bool mute) {
		muted = mute;
		audioChannels.forEach((String channelName, AudioChannel channel) {
			channel.mute = mute;
		});
		for(AudioElement audio in querySelectorAll('audio')) {
			audio.muted = mute;
		}
	}

	Future loadSong(String name) async {
		try{
			if(ASSET['music'].get()[name] == null) {
				logmessage('Song "$name" does not exist.');
			} else {
				Scound s = await sc.load(ASSET['music'].get()[name]['scid']);
				songs[name] = s;
			}
		} catch(e) {
			logmessage('[SoundManager] $e');
		}
	}

	// Music ////////////////////////////////////////////////////////////////////////////////////////

	/**
	 * Sets the SoundCloud widget's song to [value].  Must be one of the available songs.
	 * If [value] is already playing, this method has no effect.
	 */
	setSong(String value) async {
		if(currentSong != null &&
		   value.toLowerCase() == currentSong.meta['title'].toLowerCase()) {
			return;
		}

		value = value.replaceAll(' ', '');
		if(songs[value] == null) {
			await loadSong(value);
			_playSong(value);
		} else {
			_playSong(value);
		}
	}

	_playSong(String name) {
		/*
		 * canPlayType should return:
		 * probably: if the specified type appears to be playable.
		 * maybe: if it's impossible to tell whether the type is playable without playing it.
		 * The empty string: if the specified type definitely cannot be played.
		 */
		String testResult = new AudioElement().canPlayType('audio/mp3');
		if(testResult == '') {
			logmessage('[SoundManager] SoundCloud: Your browser doesnt like mp3s :(');
			return;
		} else if(testResult == 'maybe') {
			//give warning message but proceed anyway
			logmessage('[SoundManager] SoundCloud: Your browser may or may not fully support mp3s');
		}

		// Stop the old song
		if(currentSong != null) {
			currentSong.remove();
			currentSong = null;
		}

		//play a new song
		currentSong = songs[name];
		if(useWebAudio) {
			if (currentAudioInstance != null) {
				stopSound(currentAudioInstance);
			}
			playSound(currentSong.streamingUrl, asset: false, looping: true);
		} else {
			currentSong.play();
			currentSong.loop(true);
		}

		// Change the ui
		view.soundcloud.SCsong = currentSong.meta['title'];
		view.soundcloud.SCartist = currentSong.meta['user']['username'];
		view.soundcloud.SClink = currentSong.meta['permalink_url'];
	}
}