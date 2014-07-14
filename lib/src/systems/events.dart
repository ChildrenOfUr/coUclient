part of couclient;

// The main Event Bus
Pump EVENT_BUS = new Pump();


// Generic Event
class Event {
  var payload;
  Event(this.payload);
  call() => payload;
}