part of couclient;

// The main Event Bus
Pump EVENT_BUS = new Pump();

/// Events in the lifecycle of the game.
class Moment<T> {
  String type;
  T content;
  bool detected = false;
  /// Set source when you want to track where an event came from.
  var source;
  /// Events automatically add themselves to the Bus when created.
  Moment(this.type, this.content, [this.source]) {
    // automatically add itself to the BUS
    EVENT_BUS + this;
    // After 3 seconds consume the event and print a warning.
    new Timer(new Duration(seconds: 3), () {
      if (detected == false) {
        new Moment('DebugEvent', '$type from $source not Consumed!');
        this.detected = true;
      }
    });
  }

  /// Checks to see if the event is the proper type, automatically flags it as detected if so.
  isType(String type) {
    if (this.type == type) {
      this.detected = true;
      return true;
    } else return false;
  }
  @override
  String toString() {
    return '';
  }
  @override
  noSuchMethod(var err) {
    new Moment('DebugEvent', 'noSuchMethod on $type from $source!');
  }
}
