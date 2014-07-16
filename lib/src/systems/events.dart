part of couclient;

// The main Event Bus
Pump EVENT_BUS = new Pump();


/// Events in the lifecycle of the game.
class EventInstance {
  String type;
  var payload;
  
  /// Events automatically are added to the Bus on creation.
  EventInstance(this.type,this.payload) {
    // automatically add itself to the BUS
    EVENT_BUS + this;
  }
  /// Directly calling the Event will give us it's contents.
  call() => payload;
  
  /// Alerts the DebugSystem that the event was properly consumed
  consume(){
    
  }
}