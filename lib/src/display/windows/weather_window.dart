part of couclient;

class WeatherWindow extends Modal {
	String id = 'weatherWindow';
	Element well, title;
	List<String> weekStartingToday;

	WeatherWindow() {
		{
			well = new Element.tag('ur-well');

			Element closeButton = new Element.tag('i')
				..classes = ['fa-li', 'fa', 'fa-times', 'close'];

			Element icon = new Element.tag('i')
				..classes = ['fa', 'fa-li', 'fa-cloud'];

			title = new SpanElement();

			Element header = new Element.header()
				..append(icon)
				..append(title);

			DivElement window = new DivElement()
				..id = id
				..classes = ['window', 'weatherWindow']
				..hidden = true
				..append(closeButton)
				..append(header)
				..append(well);

			querySelector('#windowHolder').append(window);
			prepare();
		}

		// Open button
		querySelector('#weatherGlyph').onClick.listen((_) => open());

		// Update on new game day
		new Service(['newDay'], (_) => refresh());
	}

	bool refresh() {
		if (WeatherManager.weatherData == null) {
			new Toast('Weather data is still loading...');
			close();
			return false;
		}

		if (WeatherManager.weatherData['error'] == 'no_weather') {
			new Toast("There's no weather here");
			close();
			return false;
		}

		// Update location name
		title.text = 'Weather in ' + (currentStreet.hub_name ?? 'Ur');

		// Remove old data
		well.children.clear();

		// Current conditions
		well.append(_makeDayElement(WeatherManager.weatherData['current'], 0));

		// List days starting with today
		int today = clock._Days_of_Week.indexOf(clock._dayofweek);
		weekStartingToday = clock._Days_of_Week.sublist(today)
			..addAll(clock._Days_of_Week.sublist(0, today));

		// Forecast conditions
		for (int i = 0; i < WeatherManager.weatherData['forecast'].length;) {
			well.append(_makeDayElement(WeatherManager.weatherData['forecast'][i], ++i));
		}

		return true;
	}

	DivElement _makeDayElement(Map<String, dynamic> weather, int index) {
		DivElement day = new DivElement()
			..classes = ['day'];

		{
			DivElement title = new DivElement()
				..classes = ['title'];

			if (index == 0) {
				title.text = 'Now';
			} else {
				title.text = weekStartingToday[index];
			}

			day.append(title);
		}

		{
			ImageElement icon = new ImageElement(src: weather['weatherIcon'])
				..classes = ['icon'];

			day.append(icon);
		}

		{
			DivElement description = new DivElement()
				..classes = ['description']
				..text = weather['weatherMain'];

			day.append(description);
		}

		{
			DivElement temp = new DivElement()
				..classes = ['temp']
				..text = ((weather['temp'] as num) ~/ 1).toString()
				..appendHtml('&nbsp;<sup>&deg;F</sup>');

			day.append(temp);
		}

		{
			DivElement humidity = new DivElement()
				..classes = ['humidity']
				..title = 'Humidity'
				..appendHtml('<i class="fa fa-tint"></i>&nbsp;')
				..appendText('${weather['humidity']}%');

			day.append(humidity);
		}

		return day;
	}

	@override
	void open({bool ignoreKeys: false}) {
		if (refresh()) {
			super.open();
		}
	}
}
