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
			} catch(err){}

			if(localStorage["WeatherEffectsEnabled"] == "false") {
				_enabled = false;
			}
		}
	}

	factory WeatherManager() {
		if(_weatherManager == null) {
			_weatherManager = new WeatherManager.getInstance();
		}

		return _weatherManager;
	}

	// function to generate drops
	static void _createRain({WeatherIntensity intensity:WeatherIntensity.MEDIUM}) {
		if(!_enabled) {
			return;
		}
		log('raining: $_intensity');
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

	//clear rain from screen
	static void clearRain() {
		_weatherLayer.children.clear();
	}

	static bool get enabled => _enabled;

	static void set enabled(bool enabled) {
		localStorage["WeatherEffectsEnabled"] = enabled.toString();
		_enabled = enabled;
		clearRain();
		if(_enabled) {
			_createRain(intensity:_intensity);
		}
	}

	static WeatherIntensity get intensity => _intensity;

	static set intensity(WeatherIntensity intensity) {
		_intensity = intensity;
		localStorage["WeatherEffectsIntensity"] = _intensity.index.toString();
		clearRain();
		if(enabled) {
			_createRain(intensity:_intensity);
		}
	}
}