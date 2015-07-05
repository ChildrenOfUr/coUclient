part of couclient;

class CalendarWindow extends Modal {
  String id = 'calendarWindow';

  CalendarWindow() {
    prepare();
    Element clockE = querySelector("#calendar-time");
    Element calendarE = querySelector("#calendar-view");

    // display current date and time //

    var daynum;

    new Service(['timeUpdate'], (event) {
      clockE.querySelector("#calCurrDay").text = clock.dayofweek;
      clockE.querySelector("#calCurrTime").text = clock.time;
      clockE.querySelector("#calCurrDate").text = clock.day + ' of ' + clock.month;

      // format day for today checking //
      String daynumtext = clock.day;
      daynumtext = daynumtext.substring(0, daynumtext.length - 2);
      daynum = int.parse(daynumtext);
      assert(daynum is int);
    });

    // get calendar data //

    calendarE.innerHtml = '''
      <div id="cal-nothing">
        <p>Nothing to see here...</p>
        <img src="files/system/windows/piglet.png">
        <p class="italic">...yet.</p>
      </div>
    ''';

    // launch //

    querySelector("#time").onClick.listen((_) {
      this.open();
    });
  }
}