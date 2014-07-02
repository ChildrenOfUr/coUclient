part of couclient;

// At the moment we output the contents of every event, later we'll only output the contents of ErrorEvents
class DebugManager extends Pump {
  DebugManager() {
    EVENT_BUS > this;
  }
  @override
  process(event) {
    print(event);
    app.print(event);
    return event;
  }
}