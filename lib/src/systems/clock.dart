part of couclient;

class ClockManager {
	ClockManager() {
		// Take each of the 'clock's streams, and when there is an event, broadcast this to the manager's subscribers.
		clock.onUpdate.listen((List timedata) {
			transmit('timeUpdate', timedata);
		});
		clock.onNewDay.listen((_) {
			clock.updateHolidays();
			transmit('newDay', null);
			// The fact the event fires is all that's important here.
		});
	}
}

// Everything below this is for ^that^ //

Clock clock = new Clock();
/// You can make a new clock, but one's already made. It's 'clock'
class Clock {
	StreamController _newdayController, _timeupdateController;
	Stream onUpdate, onNewDay, onHoliday;
	String _dayofweek, _year, _day, _month, _time;
	int _dayInt, _monthInt;
	List _dPM = [29, 3, 53, 17, 73, 19, 13, 37, 5, 47, 11, 1];
	List<String> _currentHolidays = [];

	// Getters, so they can only be written by the Clock
	String get dayofweek => _dayofweek;

	String get year => _year;

	String get day => _day;

	String get month => _month;

	String get time => _time;

	List<int> get daysPerMonth => _dPM;

	List<String> get currentHolidays => _currentHolidays;

	// Integer versions
	int get dayInt => _dayInt;

	int get monthInt => _monthInt;

	Clock() {
		_newdayController = new StreamController.broadcast();
		_timeupdateController = new StreamController.broadcast();
		onUpdate = _timeupdateController.stream;
		onNewDay = _newdayController.stream;

		_sendEvents();
		// Time update Timer.
		new Timer.periodic(new Duration(seconds: 10), (_) => _sendEvents());
	}

	Future <List <String>> getHolidays(int month, int day) async {
		String url = 'http://' + Configs.utilServerAddress + '/getHolidays?month=${month}&day=${day}';
		List<String> currentHolidays = JSON.decode(await HttpRequest.requestCrossOrigin(url));
		return currentHolidays;
	}

	// timer has updated, send out required events and update interfaces.
	void _sendEvents() {

		// Year, month, day, week, time
		List data = _getDate();

		_dayofweek = data[3];
		_time = data[4];
		_day = data[2];
		_month = data[1];
		_year = data[0];

		_dayInt = data[5];
		_monthInt = data[6];

		// Clock update stream
		_timeupdateController.add([time, day, dayofweek, month, year, dayInt, monthInt]);

		// New Day update stream
		if(time == '6:00am') {
			_newdayController.add('new day!');
		}
	}

	Future updateHolidays() async {
		List updatedHolidays = await getHolidays(clock.monthInt, clock.dayInt);
		// Alert for new Holidays
		for(String holiday in updatedHolidays) {
			if(!_currentHolidays.contains(holiday)) {

			}
		}

		// Alert for left Holidays
		for(String holiday in _currentHolidays) {
			if(!updatedHolidays.contains(holiday)) {

			}
		}

		_currentHolidays = updatedHolidays;
	}

	List _Months = const ['Primuary', 'Spork', 'Bruise', 'Candy', 'Fever', 'Junuary', 'Septa', 'Remember', 'Doom', 'Widdershins', 'Eleventy', 'Recurse'];
	List _Days_of_Week = const ['Hairday', 'Moonday', 'Twoday', 'Weddingday', 'Theday', 'Fryday', 'Standday', 'Fabday'];

	List _getDate() {
		//
		// there are 4435200 real seconds in a game year
		// there are 14400 real seconds in a game day
		// there are 600 real seconds in a game hour
		// there are 10 real seconds in a game minute
		//

		//
		// how many real seconds have elapsed since game epoch?
		//
		int ts = (new DateTime.now().millisecondsSinceEpoch * 0.001).floor();
		int sec = ts - 1238562000;

		int year = (sec / 4435200).floor();
		sec -= year * 4435200;

		int day_of_year = (sec / 14400).floor();
		sec -= day_of_year * 14400;

		int hour = (sec / 600).floor();
		sec -= hour * 600;

		int minute = (sec / 10).floor();
		sec -= minute * 10;


		//
		// turn the 0-based day-of-year into a day & month
		//

		List MonthAndDay = _day_to_md(day_of_year);


		//
		// get day-of-week
		//

		int days_since_epoch = day_of_year + (307 * year);

		int day_of_week = days_since_epoch % 8;


		//
		// Append to our day_of_month
		//
		String suffix;
		if(MonthAndDay[1].toString().endsWith('1')) suffix = 'st'; else if(MonthAndDay[1].toString().endsWith('2')) suffix = 'nd'; else if(MonthAndDay[1].toString().endsWith('3')) suffix = 'rd'; else suffix = 'th';

		//
		// Fix am pm times
		//

		String h = hour.toString();
		String m = minute.toString();
		String ampm = 'am';
		if(minute < 10) m = '0' + minute.toString();
		if(hour >= 12) {
			ampm = 'pm';
			if(hour > 12) h = (hour - 12).toString();
		}
		if(h == '0') h = (12).toString();
		String CurrentTime = (h + ':' + m + ampm);

		return ['Year ' + year.toString(), _Months[MonthAndDay[0] - 1], MonthAndDay[1].toString() + suffix, _Days_of_Week[day_of_week], CurrentTime, MonthAndDay[1], MonthAndDay[0]];
	}

	List _day_to_md(id) {

		int cd = 0;

		int daysinMonths = daysPerMonth[0] + daysPerMonth[1] + daysPerMonth[2] + daysPerMonth[3] + daysPerMonth[4] + daysPerMonth[5] + daysPerMonth[6] + daysPerMonth[7] + daysPerMonth[8] + daysPerMonth[9] + daysPerMonth[10] + daysPerMonth[11];

		for(int i = 0; i < (daysinMonths); i++) {
			cd += daysPerMonth[i];
			if(cd > id) {
				int m = i + 1;
				int d = id + 1 - (cd - daysPerMonth[i]);
				return [m, d];
			}
		}

		return [0, 0];
	}
}