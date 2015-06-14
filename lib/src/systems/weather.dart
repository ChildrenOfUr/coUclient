part of couclient;

enum WeatherIntensity {
	LIGHT, MEDIUM, HEAVY
}

class WeatherManager {
	static WeatherManager _weatherManager;
	static DivElement _weatherLayer, _cloudLayer;
	static WeatherIntensity _intensity = WeatherIntensity.MEDIUM;
	static bool _enabled = true;

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
			} else if(localStorage["WeatherEffectsEnabled"] == "true") {
				_createRain();
			}

			//need a service to listen to time events and respond by coloring the
			//weather overlay as needed (possibly change the background gradient?
			new Service([#timeUpdate],_changeAmbientColor);

			//update on start
			new Message(#timeUpdate,[clock.time,clock.day,clock.dayofweek,clock.month,clock.year]);
		}
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
		List<String> hourmin = time.substring(0,time.length-2).split(':');
		int hour = int.parse(hourmin[0]);
		int minute = int.parse(hourmin[1]);
		List<num> rgba = [255,255,255,0];

		if(!am) {
			if(hour >= 6 && hour < 8) {
				//go towards rgba(218,150,45,.15) from 255,255,255,0
				//there's 180 minutes, what minute are we at
				int currentMinute = (8-hour)*60-minute;
				num percent = 1-currentMinute/120;
				rgba = _tweenColor([255,255,255,0],[218,150,45,.15],percent);
			} else if(hour >= 8 && hour < 12){
				//go towards rgba(17,17,47,.5) from 218,150,45,.15
				int currentMinute = (12-hour)*60-minute;
				num percent = 1-currentMinute/240;
				rgba = _tweenColor([218,150,45,.15],[17,17,47,.5],percent);
				_setStreetGradient(percent);
			}
		} else {
			if(hour < 5 || hour == 12) {
				rgba = [17,17,47,.5];
				_setStreetGradient(1);
			}else if(hour >= 5 && hour < 7) {
				int currentMinute = (7-hour)*60-minute;
				num percent = 1-currentMinute/120;
				rgba = _tweenColor([17,17,47,.5],[218,150,45,.15],percent);
			} else if(hour >= 7 && hour < 9) {
				int currentMinute = (9-hour)*60-minute;
				num percent = 1-currentMinute/120;
				rgba = _tweenColor([218,150,45,.15],[255,255,255,0],percent);
			}
		}

		_weatherLayer.style.backgroundColor = 'rgba(${rgba[0]},${rgba[1]},${rgba[2]},${rgba[3]})';
	}

	static void _setStreetGradient(num percent) {
		String streetTop = '#'+currentStreet.streetData['gradient']['top'];
		String streetBottom = '#'+currentStreet.streetData['gradient']['bottom'];

		List topTween = _tweenColor(hex2rgb(streetTop),[19,0,5,1],percent);
		List bottomTween = _tweenColor(hex2rgb(streetBottom),[19,0,5,1],percent);
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
		return '#' + rgb[0].toRadixString(16).padLeft(2,'0') + rgb[1].toRadixString(16).padLeft(2,'0') + rgb[2].toRadixString(16).padLeft(2,'0');
	}

	static List<num> _tweenColor(List<num> start, List<num> end, num percent) {
		num r = start[0]-(percent*(start[0]-end[0])).toInt();
		num g = start[1]-(percent*(start[1]-end[1])).toInt();
		num b = start[2]-(percent*(start[2]-end[2])).toInt();
		num a = start[3]-percent*(start[3]-end[3]);
		return [r,g,b,a];
	}

	// function to generate drops
	static void _createRain() {
		if(!_enabled) {
			return;
		}
		log('raining: $_intensity');

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
				//..style.width = '${random.nextInt(2)+1}px'
				//..style.height = '${random.nextInt(30)+20}px'
				..style.left = '${dropLeft}px'
				..style.top = '${dropTop}px';

			_weatherLayer.append(raindrop);
		}
	}

	//clear rain from screen
	static void clearRain() {
		_weatherLayer.children.clear();
		_cloudLayer.classes.remove('cloudy');
	}

	static bool get enabled => _enabled;

	static void set enabled(bool enabled) {
		localStorage["WeatherEffectsEnabled"] = enabled.toString();
		_enabled = enabled;
		clearRain();
		if(_enabled) {
			_createRain();
		}
	}

	static WeatherIntensity get intensity => _intensity;

	static set intensity(WeatherIntensity intensity) {
		_intensity = intensity;
		localStorage["WeatherEffectsIntensity"] = _intensity.index.toString();
		clearRain();
		if(enabled) {
			_createRain();
		}
	}
}