part of couclient;

// The main Event Bus
Pump EVENT_BUS = new Pump();

spawnEvent(BusEvent event){
  EVENT_BUS + event;
}



// Generic Event
class BusEvent {
  var payload;
  BusEvent(this.payload);
  call() => payload;
}