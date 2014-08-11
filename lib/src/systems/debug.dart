part of couclient;

// Takes DebugEvents and turns them into a visible alert for the player
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