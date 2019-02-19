part of couclient;

enum WeatherIntensity {
	LIGHT, NORMAL
}

enum WeatherState {
	CLEAR, RAINING, SNOWING, WINDY
}

class WeatherManager {
	static WeatherManager _weatherManager;
	static DivElement _weatherLayer, _cloudLayer, _raindrops, _snowflakes;
	static WeatherIntensity _intensity = WeatherIntensity.NORMAL;
	static WeatherState _currentState = WeatherState.CLEAR;
	static bool _enabled = true, _gradientEnabled = true;
	static var rainSound;
	static String url = '${Configs.ws}//${Configs.websocketServerAddress}/weather';
	static Map<String, dynamic> _weatherData;
	static Map<String, dynamic> get weatherData => new Map.from(_weatherData);
	static WebSocket socket;
	static Map<String, Completer<Map<String, dynamic>>> requests = {};

	WeatherManager.getInstance() {
		_weatherLayer = querySelector("#weatherLayer");
		_cloudLayer = querySelector("#cloudLayer");
		_raindrops = _weatherLayer.querySelector("#weather-raindrops");
		_snowflakes = _weatherLayer.querySelector("#weather-snowflakes");

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
			new Service(['timeUpdate', 'timeUpdateFake'], _changeAmbientColor);

			new Service(['streetLoaded'], (m) {
				_gradientEnabled = true;
				transmit('timeUpdate', [clock.time, clock.day, clock.dayofweek, clock.month, clock.year]);
			});

			//service for debugging weather
			new Service(['setWeatherFake'], (m) {_processMessage(m);});

			//update on start
			transmit('timeUpdate', [clock.time, clock.day, clock.dayofweek, clock.month, clock.year]);
		}

		_setupWebsocket();

		Timer resizeTimer;
		new Service(['windowResized'], (m) {
			//we only want to respond to the last event of this in a series
			//so we'll wait until 200ms have gone by without one of these events
			//and then we'll do our real work

			if(resizeTimer != null && resizeTimer.isActive) {
				resizeTimer.cancel();
			}

			resizeTimer = new Timer(new Duration(milliseconds:200), _recalculateRain);
		});

		new Service(['streetLoaded'], (_) {
			socket.send(jsonEncode({
				'update': 'location',
				'username': game.username,
				'tsid': currentStreet.tsid
			}));
		});
	}

	factory WeatherManager() {
		if(_weatherManager == null) {
			_weatherManager = new WeatherManager.getInstance();
		}

		return _weatherManager;
	}

	static Future<Map<String, dynamic>> requestHubWeather(String hubId) {
		requests[hubId] = new Completer();

		socket.send(jsonEncode({
			'update': 'request',
			'username': game.username,
			'hub_id': hubId
		}));

		return requests[hubId].future;
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

	static void _changeAmbientColor(m) {
		if (!enabled) {
			return;
		}

		List<dynamic> timePieces = m;
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
				percent = (1 - currentMinute / 120)/2;
				//daylight to sunset
				rgba = _tweenColor([255, 255, 255, 0], [218, 150, 45, .15], percent);
			} else if(hour >= 7 && hour < 12) {
				int currentMinute = (12 - hour) * 60 - minute;
				percent = 1 - currentMinute / 240;
				//sunset to night
				rgba = _tweenColor([218, 150, 45, .15], [17, 17, 47, .5], percent);
				percent = percent/2 +.5;
			} else {
				percent = 0;
			}
			_setStreetGradient(percent);
		} else {
			if(hour < 5 || hour == 12) {
				rgba = [17, 17, 47, .5];
			} else if(hour >= 5 && hour < 7) {
				int currentMinute = (7 - hour) * 60 - minute;
				percent = (1 - currentMinute / 120)/2;
				//night to sunrise
				rgba = _tweenColor([17, 17, 47, .5], [218, 150, 45, .15], percent);
				percent = 1-percent;
			} else if(hour >= 7 && hour < 9) {
				int currentMinute = (9 - hour) * 60 - minute;
				percent = 1 - currentMinute / 120;
				//sunrise to daylight
				rgba = _tweenColor([218, 150, 45, .15], [255, 255, 255, 0], percent);
				percent = .5-percent/2;
			} else {
				percent = 0;
			}
			_setStreetGradient(percent);
		}

		_weatherLayer.style.backgroundColor = 'rgba(${rgba[0]},${rgba[1]},${rgba[2]},${rgba[3]})';
	}

	static void _setStreetGradient(num percent) {
		if (!_gradientEnabled) {
			return;
		}

		DivElement gradientCanvas = querySelector('#gradient');
		if(gradientCanvas == null) {
			return;
		}

		String streetTop, streetBottom;

		try {
			streetTop = '#' + currentStreet.streetData['gradient']['top'];
			streetBottom = '#' + currentStreet.streetData['gradient']['bottom'];
		} catch(e) {
			_gradientEnabled = false;
			logmessage("[Weather] Could not create street gradient: $e");
			return;
		}

		//make sure the street has a gradient before trying to modify it
		if(streetTop.length < 7 || streetBottom.length < 7) {
			return;
		}

		List topTween = _tweenColor(hex2rgb(streetTop), [19, 0, 5, 1], percent);
		List bottomTween = _tweenColor(hex2rgb(streetBottom), [19, 0, 5, 1], percent);
		String top = rgb2hex(topTween);
		String bottom = rgb2hex(bottomTween);
		gradientCanvas.style.background = 'linear-gradient(to bottom, $top, $bottom)';
	}

	static List<int> hex2rgb(String hex) {
		List<int> result = new List<int>(4);
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

		logmessage('[Weather] ${currentState.toString()}: $_intensity');

		if(createState == WeatherState.RAINING && !mapData.snowyWeather()) {
			// Rain

			if (_intensity == WeatherIntensity.LIGHT) {
				_raindrops.classes.add("light");
			} else {
				_raindrops.classes.remove("light");
			}

			// Sound effect
			_playRainSound();

			// Graphical effects
			if (!mapData.forceDisableWeather()) {
				// Enable rain display
				if (!_cloudLayer.classes.contains('cloudy')) {
					_cloudLayer.classes.add('cloudy');
				}
				_raindrops.style.opacity = '0.5';
			} else {
				_cloudLayer.classes.remove('cloudy');
				_raindrops.style.opacity = '0';
			}
		} else if (createState == WeatherState.SNOWING || mapData.snowyWeather()) {
			// Snow

			// Graphical effects
			if (!mapData.forceDisableWeather()) {
				// Enable snow display
				if (!_cloudLayer.classes.contains('snowy') && _intensity != WeatherIntensity.LIGHT) {
					_cloudLayer.classes.add('snowy');
				}
				_snowflakes.style.opacity = '0.7';
			} else {
				_cloudLayer.classes.remove('snowy');
				_snowflakes.style.opacity = '0';
			}
		}
	}

	static _playRainSound() async {
		audio.gameSounds['rainSound'] = new Sound(channel: audio.audioChannels['weather']);
		await audio.gameSounds['rainSound'].load("files/audio/rain.${audio.extension}");
		rainSound = await audio.playSound('rainSound', looping:true, fadeIn:true);
	}

	static void _clearWeather() {
		_raindrops.style.opacity = '0';
		_snowflakes.style.opacity = '0';
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
		//establish a websocket connection to listen for weather data coming in
		socket = new WebSocket(url);
		socket.onOpen.listen((_) => socket.send(jsonEncode({
			'username': game.username,
			'tsid': currentStreet.tsid.toString()
		})));
		socket.onMessage.listen((MessageEvent event) {
			Map map = jsonDecode(event.data);

			_processMessage(map);
		});
		socket.onClose.listen((CloseEvent e) {
			logmessage('[Weather] Socket closed: ${e.reason}');
			// wait and then try to reconnect
			new Timer(new Duration(seconds: 2), () => _setupWebsocket());
		});
		socket.onError.listen((Event e) {
			logmessage('[Weather] Error $e');
		});
	}

	static void _processMessage(Map<String, dynamic> map) {
		if (windowManager.weather.elementOpen && !windowManager.weather.remoteViewing) {
			windowManager.weather.refresh();
		}

		WeatherState previousState = _currentState;

		if (map['error'] != null) {
			_weatherData = map;
			_currentState = WeatherState.CLEAR;
		} else if (map['hub_id'] != null) {
			requests[map['hub_id']].complete(map);
		} else {
			_weatherData = map;
			String weatherMain = _weatherData['current']['weatherMain'].toLowerCase();
			if (weatherMain.contains('clear')) {
				_currentState = WeatherState.CLEAR;
			} else if (weatherMain.contains('rain')) {
				_currentState = WeatherState.RAINING;
			} else if (weatherMain.contains('snow')) {
				_currentState = WeatherState.SNOWING;
			} else if (weatherMain.contains('wind')) {
				_currentState = WeatherState.WINDY;
			} else {
				_currentState = previousState;
			}
		}

		if (_currentState != previousState) {
			_clearWeather();
			if (_currentState != WeatherState.CLEAR) {
				_createWeather(_currentState);
			}
		}
	}
}
