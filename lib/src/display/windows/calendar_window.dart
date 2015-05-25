part of couclient;

class CalendarWindow extends Modal {
  String id = 'calendarWindow';

  CalendarWindow() {
    prepare();

    new Service([#timeUpdate], (Message event) {
        querySelector("#calCurrDay").text = clock.dayofweek;
        querySelector("#calCurrTime").text = clock.time;
        querySelector("#calCurrDate").text = clock.day + ' of ' + clock.month;
    });
    
    querySelector("#time").onClick.listen((_) {
      this.open();
    });
  }
}