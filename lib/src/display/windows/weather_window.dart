part of couclient;

class WeatherWindow extends Modal {
	String id = 'weatherWindow';
	Element well, title;

	WeatherWindow() {
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

		querySelector('#weatherGlyph').onClick.listen((_) => open());
	}

	bool refresh() {
		if (WeatherManager.weatherData == null) {
			new Toast('Weather data is still loading...');
			return false;
		}

		// Update location name
		title.text = 'Weather in ' + (currentStreet.hub_name ?? 'Ur');

		// Remove old data
		well.children.clear();

		// Current conditions
		well.append(_makeDayElement(WeatherManager.weatherData['current']));

		// Forecast conditions
		(WeatherManager.weatherData['forecast']).forEach((Map<String, dynamic> weather) {
			well.append(_makeDayElement(weather));
		});

		return true;
	}

	DivElement _makeDayElement(Map<String, dynamic> weather) {
		DivElement day = new DivElement()
			..classes = ['day'];

		{
			DivElement title = new DivElement()
				..classes = ['title'];

			DateTime date = DateTime.parse(weather['calcDateTxt']).toLocal();

			if (date.day == new DateTime.now().day) {
				title.text = 'Now';
			} else {
				title.text = {
					1: 'Mon',
					2: 'Tues',
					3: 'Wed',
					4: 'Thurs',
					5: 'Fri',
					6: 'Sat',
					7: 'Sun'
				}[date.weekday];
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
				..text = ((weather['mainTemp'] as num) ~/ 1).toString()
				..appendHtml('&nbsp;<sup>&deg;F</sup>');

			day.append(temp);
		}

		{
			DivElement humidity = new DivElement()
				..classes = ['humidity']
				..title = 'Humidity'
				..appendHtml('<i class="fa fa-tint"></i>&nbsp;')
				..appendText('${weather['mainHumidity']}%');

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
