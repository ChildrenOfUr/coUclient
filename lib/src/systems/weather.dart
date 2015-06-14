part of couclient;

enum WeatherIntensity {
	LIGHT, MEDIUM, HEAVY
}

enum WeatherState {
	CLEAR, RAINING, SNOWING, WINDY
}

class WeatherManager {
	static WeatherManager _weatherManager;
	static DivElement _weatherLayer, _cloudLayer;
	static WeatherIntensity _intensity = WeatherIntensity.MEDIUM;
	static WeatherState _currentState = WeatherState.CLEAR;
	static bool _enabled = true;
	static var rainSound;
	static String url = 'ws://${Configs.websocketServerAddress}/weather';

	WeatherManager.getInstance() {
		_weatherLayer = querySelector("#weatherLayer");
		_cloudLayer = querySelector("#cloudLayer");

		if(localStorage["WeatherEffectsEnabled"] != null) {
			//if we can't pull out the intensity, that's ok, we have a default
			try {
				String value = localStorage["WeatherEffectsIntensity"];
				_intensity = WeatherIntensity.values[int.parse(value)];
			} catch(err) {
			}

			if(localStorage["WeatherEffectsEnabled"] == "false") {
				_enabled = false;
			}

			//need a service to listen to time events and respond by coloring the
			//weather overlay as needed (possibly change the background gradient?
			new Service([#timeUpdateFake], _changeAmbientColor);

			//update on start
			new Message(#timeUpdateFake, [clock.time, clock.day, clock.dayofweek, clock.month, clock.year]);
		}

		_setupWebsocket();
	}

	factory WeatherManager() {
		if(_weatherManager == null) {
			_weatherManager = new WeatherManager.getInstance();
		}

		return _weatherManager;
	}

	static void _changeAmbientColor(Message m) {
		List<dynamic> timePieces = m.content;
		String time = timePieces[0];
		bool am = time.contains('am');
		List<String> hourmin = time.substring(0, time.length - 2).split(':');
		int hour = int.parse(hourmin[0]);
		int minute = int.parse(hourmin[1]);
		List<num> rgba = [255, 255, 255, 0];

		num percent = 1;
		if(!am) {
			if(hour >= 5 && hour < 7) {
				int currentMinute = (7 - hour) * 60 - minute;
				percent = 1 - currentMinute / 120;
				//daylight to sunset
				rgba = _tweenColor([255, 255, 255, 0], [218, 150, 45, .15], percent);
			} else if(hour >= 7 && hour <= 12) {
				int currentMinute = (12 - hour) * 60 - minute;
				percent = 1 - currentMinute / 240;
				//sunset to night
				rgba = _tweenColor([218, 150, 45, .15], [17, 17, 47, .5], percent);
			} else {
				percent = 0;
			}
			_setStreetGradient(percent);
		} else {
			if(hour < 5 || hour == 12) {
				rgba = [17, 17, 47, .5];
			} else if(hour >= 5 && hour < 7) {
				int currentMinute = (7 - hour) * 60 - minute;
				percent = 1 - currentMinute / 120;
				//night to sunrise
				rgba = _tweenColor([17, 17, 47, .5], [218, 150, 45, .15], percent);
			} else if(hour >= 7 && hour < 9) {
				int currentMinute = (9 - hour) * 60 - minute;
				percent = 1 - currentMinute / 120;
				//sunrise to daylight
				rgba = _tweenColor([218, 150, 45, .15], [255, 255, 255, 0], percent);
			} else {
				percent = 0;
			}
			_setStreetGradient(percent);
		}

		_weatherLayer.style.backgroundColor = 'rgba(${rgba[0]},${rgba[1]},${rgba[2]},${rgba[3]})';
	}

	static void _setStreetGradient(num percent) {
		String streetTop = '#' + currentStreet.streetData['gradient']['top'];
		String streetBottom = '#' + currentStreet.streetData['gradient']['bottom'];

		List topTween = _tweenColor(hex2rgb(streetTop), [19, 0, 5, 1], percent);
		List bottomTween = _tweenColor(hex2rgb(streetBottom), [19, 0, 5, 1], percent);
		String top = rgb2hex(topTween);
		String bottom = rgb2hex(bottomTween);

		DivElement gradientCanvas = querySelector('#gradient');
		gradientCanvas.style.background = "-webkit-linear-gradient(top, $top, $bottom)";
		gradientCanvas.style.background = "-moz-linear-gradient(top, $top, $bottom)";
		gradientCanvas.style.background = "-ms-linear-gradient($top, $bottom)";
		gradientCanvas.style.background = "-o-linear-gradient($top, $bottom)";
	}

	static List<int> hex2rgb(String hex) {
		List result = new List(4);
		result[0] = int.parse(hex.substring(1, 3), radix: 16);
		result[1] = int.parse(hex.substring(3, 5), radix: 16);
		result[2] = int.parse(hex.substring(5, 7), radix: 16);
		result[3] = 1;
		return result;
	}

	static String rgb2hex(List rgb) {
		return '#' + rgb[0].toRadixString(16).padLeft(2, '0') + rgb[1].toRadixString(16).padLeft(2, '0') + rgb[2].toRadixString(16).padLeft(2, '0');
	}

	static List<num> _tweenColor(List<num> start, List<num> end, num percent) {
		num r = start[0] - (percent * (start[0] - end[0])).toInt();
		num g = start[1] - (percent * (start[1] - end[1])).toInt();
		num b = start[2] - (percent * (start[2] - end[2])).toInt();
		num a = start[3] - percent * (start[3] - end[3]);
		return [r, g, b, a];
	}

	// function to generate drops
	static void _createRain() {
		if(!_enabled) {
			return;
		}

		log('raining: $_intensity');

		_playRainSound();

		//set the sky to cloudy if
		if(!_cloudLayer.classes.contains('cloudy')) {
			_cloudLayer.classes.add('cloudy');
		}

		Random random = new Random();
		int numDrops = (500 * ((intensity.index + 1) / WeatherIntensity.values.length)).toInt();

		for(int i = 0; i < numDrops; i++) {
			var dropLeft = random.nextInt(view.worldElementWidth);
			var dropTop = random.nextInt(2400) - 1000;

			DivElement raindrop = new DivElement()
				..className = 'drop'
				..style.left = '${dropLeft}px'
				..style.top = '${dropTop}px';

			_weatherLayer.append(raindrop);
		}
	}

	static _playRainSound() async {
		audio.gameSounds['rainSound'] = new Sound(channel: audio.audioChannels['soundEffects']);
		await audio.gameSounds['rainSound'].load("files/audio/rain.${audio.extension}");
		rainSound = await audio.playSound('rainSound', looping:true, fadeIn:true);
	}

	//clear rain from screen
	static void _clearRain() {
		print('clearing the rain');
		_weatherLayer.children.clear();
		_cloudLayer.classes.remove('cloudy');
		if(rainSound != null) {
			print('stopping the sound');
			audio.stopSound(rainSound, fadeOut:true);
		}
	}

	static bool get enabled => _enabled;

	static void set enabled(bool enabled) {
		localStorage["WeatherEffectsEnabled"] = enabled.toString();
		_enabled = enabled;
		_clearRain();
		if(_enabled && _currentState == WeatherState.RAINING) {
			_createRain();
		}
	}

	static WeatherIntensity get intensity => _intensity;

	static set intensity(WeatherIntensity intensity) {
		_intensity = intensity;
		localStorage["WeatherEffectsIntensity"] = _intensity.index.toString();
		_clearRain();
		if(enabled && _currentState == WeatherState.RAINING) {
			_createRain();
		}
	}

	static void _setupWebsocket() {
		//establish a websocket connection to listen for metabolics objects coming in
		WebSocket socket = new WebSocket(url);
		socket.onOpen.listen((_) => socket.send(JSON.encode({'username':game.username})));
		socket.onMessage.listen((MessageEvent event) {
			Map map = JSON.decode(event.data);

			WeatherState previousState = _currentState;
			_currentState = WeatherState.values[map['state']];

			if(_currentState != WeatherState.RAINING) {
				_clearRain();
			}

			if(previousState != WeatherState.RAINING && _currentState == WeatherState.RAINING) {
				_createRain();
			}
		});
		socket.onClose.listen((CloseEvent e) {
			log('weather socket closed: ${e.reason}');
			//wait 5 seconds and try to reconnect
			new Timer(new Duration(seconds: 5), () => _setupWebsocket());
		});
		socket.onError.listen((ErrorEvent e) {
			log('Weather: error ${e.error}');
		});
	}
}