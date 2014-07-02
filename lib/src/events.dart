part of couclient;
/*
 *  THE CHILDREN OF UR WEBCLIENT
 *  http://www.childrenofur.com
 *  
 *  
 * 
 * 
 * 
 * 
 * 
*/

// EVENT HANDLERS //
// The main Event Bus
Pump EVENT_BUS = new Pump();

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
