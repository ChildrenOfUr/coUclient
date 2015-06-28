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
			new Service([#timeUpdate, #timeUpdateFake], _changeAmbientColor);

			//service for debugging weather
			new Service([#setWeatherFake], (Message m) {_processMessage(m.content);});

			//update on start
			new Message(#timeUpdate, [clock.time, clock.day, clock.dayofweek, clock.month, clock.year]);
		}

		_setupWebsocket();

		Timer resizeTimer;
		new Service([#windowResized], (Message m) {
			//we only want to respond to the last event of this in a series
			//so we'll wait until 200ms have gone by without one of these events
			//and then we'll do our real work

			if(resizeTimer != null && resizeTimer.isActive) {
				resizeTimer.cancel();
			}

			resizeTimer = new Timer(new Duration(milliseconds:200), _recalculateRain);
		});
	}

	factory WeatherManager() {
		if(_weatherManager == null) {
			_weatherManager = new WeatherManager.getInstance();
		}

		return _weatherManager;
	}

	static bool get enabled => _enabled;
	static WeatherIntensity get intensity => _intensity;
	static WeatherState get currentState => _currentState;

	static void _recalculateRain() {
		if(enabled && currentState == WeatherState.RAINING) {
			_clearWeather();
			_createWeather(currentState);
		}
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

		//make sure the street has a gradient before trying to modify it
		if(streetTop.length < 7 || streetBottom.length < 7) {
			return;
		}

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
	static void _createWeather(WeatherState createState) {
		if(!_enabled) {
			return;
		}
		
		log('${currentState.toString()}: $_intensity');

		String precipitationClass = '';
		if(createState == WeatherState.RAINING) {
			_playRainSound();
			precipitationClass = 'drop';

			if(!_cloudLayer.classes.contains('cloudy')) {
				_cloudLayer.classes.add('cloudy');
			}
		} else if (createState == WeatherState.SNOWING) {
			precipitationClass = 'flake';

			if(!_cloudLayer.classes.contains('snowy')) {
				_cloudLayer.classes.add('snowy');
			}
		}

		Random random = new Random();
		int numDrops = (500 * ((intensity.index + 1) / WeatherIntensity.values.length)).toInt();

		for(int i = 0; i < numDrops; i++) {
			var dropLeft = random.nextInt(view.worldElementWidth);
			var dropTop = random.nextInt(2400) - 1000;

			DivElement particle = new DivElement()
				..className = precipitationClass
				..style.left = '${dropLeft}px'
				..style.top = '${dropTop}px';

			_weatherLayer.append(particle);
		}
	}

	static _playRainSound() async {
		audio.gameSounds['rainSound'] = new Sound(channel: audio.audioChannels['soundEffects']);
		await audio.gameSounds['rainSound'].load("files/audio/rain.${audio.extension}");
		rainSound = await audio.playSound('rainSound', looping:true, fadeIn:true);
	}

	static void _clearWeather() {
		_weatherLayer.children.clear();
		_cloudLayer.classes
			..remove('cloudy')
			..remove('snowy');
		if(rainSound != null) {
			audio.stopSound(rainSound, fadeOut:true);
		}
	}

	static void set enabled(bool enabled) {
		localStorage["WeatherEffectsEnabled"] = enabled.toString();
		_enabled = enabled;
		_clearWeather();
		if(_enabled && currentState != WeatherState.CLEAR) {
			_createWeather(currentState);
		}
		if(enabled && currentState == WeatherState.SNOWING) {
			_createWeather(currentState);
		}
	}

	static set intensity(WeatherIntensity intensity) {
		_intensity = intensity;
		localStorage["WeatherEffectsIntensity"] = _intensity.index.toString();
		_clearWeather();
		if(enabled && currentState == WeatherState.RAINING) {
			_createWeather(currentState);
		}
		if(enabled && currentState == WeatherState.SNOWING) {
			_createWeather(currentState);
		}
	}

	static void _setupWebsocket() {
		//establish a websocket connection to listen for metabolics objects coming in
		WebSocket socket = new WebSocket(url);
		socket.onOpen.listen((_) => socket.send(JSON.encode({'username':game.username})));
		socket.onMessage.listen((MessageEvent event) {
			Map map = JSON.decode(event.data);

			_processMessage(map);
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

	static void _processMessage(Map map) {
		WeatherState previousState = currentState;
		_currentState = WeatherState.values[map['state']];

		print(map);
		if (currentState != previousState) {
			_clearWeather();
			if(currentState != WeatherState.CLEAR) {
				_createWeather(currentState);
			}
		}
	}
}