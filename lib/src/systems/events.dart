part of couclient;

// The main Event Bus
Pump EVENT_BUS = new Pump();

/// Events in the lifecycle of the game.
class EventInstance<T> {
  String type;
  T payload;
  bool consumed = false;
  /// Set source when you want to track where an event came from.
  var Source;
  /// Events automatically are added to the Bus on creation.
  EventInstance(this.type, this.payload, [this.Source]) {
    // automatically add itself to the BUS
    EVENT_BUS + this;
    // After 3 seconds consume the event and print a warning.
    new Timer(new Duration(seconds: 3), () {
      if (consumed == false) {
        new EventInstance('DebugEvent', '$type from $Source not Consumed!');
        this.consumed = true;
      }
    });
  }
  /// Directly calling the Event will give us it's contents.
  call() => payload;

  /// Checks to see if the event is the proper type, automatically consumes it.
  isType(String type) {
    if (this.type == type) {
      this.consume();
      return true;
    } else return false;
  }
  /// Alerts the DebugSystem that the event was properly consumed
  consume() {
    consumed = true;
  }
}
