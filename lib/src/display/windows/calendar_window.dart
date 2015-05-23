part of couclient;

class CalendarWindow extends Modal {
  String id = 'calendarWindow';

  CalendarWindow() {
    prepare();
    querySelector("#time").onClick.listen((_) {
      this.open();
    });
  }
}