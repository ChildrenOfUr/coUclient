part of couclient;

// At the moment we output the contents of every event, later we'll only output the contents of ErrorEvents
class DebugManager extends Pump {
  DebugManager() {
    EVENT_BUS & this;
  }
  @override
  process(EventInstance event) {
    if (event.isType('DebugEvent')) {
      new EventInstance('ChatEvent',{ 
        'channel':'Global Chat',
        'message':'!:' +event.payload.toString()});
      ui.print(event.payload);
    }
  }
}