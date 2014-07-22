part of couclient;

// At the moment we output the contents of every event, later we'll only output the contents of ErrorEvents
class DebugManager extends Pump {
  DebugManager() {
    EVENT_BUS & this;
  }
  @override
  process(Moment event) {
    if (event.isType('DebugEvent')) {
      new Moment('ChatEvent',{ 
        'channel':'Global Chat',
        'message':'!:' +event.content.toString()});
    }
  }
}