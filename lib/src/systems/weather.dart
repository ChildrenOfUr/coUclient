part of couclient;

enum WeatherIntensity {
	LIGHT, MEDIUM, HEAVY
}

class WeatherManager {
	static WeatherManager _weatherManager;
	static DivElement _weatherLayer;
	static WeatherIntensity _intensity = WeatherIntensity.MEDIUM;
	static bool _enabled = true;

	WeatherManager.getInstance() {
		_weatherLayer = querySelector("#weatherLayer");

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
			if(hour >= 6 && hour <= 9) {
				//go towards rgba(218,150,45,.15) from 255,255,255,0
				//there's 180 minutes, what minute are we at
				currentMinute = (9-hour)*60+minute;
				num percent = currentMinute/180;
				rgba = _tweenColor([255,255,255,0],[218,150,45,.15],percent);
			} else if(hour >= 9){
				//go towards rgba(17,17,47,.5) from 218,150,45,.15
				currentMinute = (12-hour)*60+minute;
				num percent = currentMinute/180;
				rgba = _tweenColor([218,150,45.15],[17,17,47,.5],percent);
			}
		} else {
			if(hour < 5) {
				rgba = [17,17,47,.5];
			}else if(hour >= 5 && hour <= 7) {
				currentMinute = (7-hour)*60+minute;
				num percent = currentMinute/180;
				rgba = _tweenColor([17,17,47,.5],[218,150,45,.15],percent);
			} else if(hour >= 7 && hour < 9) {
				currentMinute = (9-hour)*60+minute;
				num percent = currentMinute/180;
				rgba = _tweenColor([218,150,45,.15],[255,255,255,0],percent);
			}
		}

		_weatherLayer.style.backgroundColor = 'rgba(${rgba[0]},${rgba[1]},${rgba[2]},${rgba[3]})';
	}

	static List<num> _tweenColor(List<num> start, List<num> end, num percent) {
		num r = percent*((start[0]-end[0]).abs());
		num g = percent*((start[1]-end[1]).abs());
		num b = percent*((start[2]-end[2]).abs());
		num a = percent*((start[3]-end[3]).abs());
		return [r,g,b,a];
	}

	// function to generate drops
	static void _createRain() {
		if(!_enabled) {
			return;
		}
		log('raining: $_intensity');

		//set the sky to cloudy
		if(!_weatherLayer.classes.contains('cloudy')) {
			_weatherLayer.classes.add('cloudy');
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
		_weatherLayer.classes.remove('cloudy');
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