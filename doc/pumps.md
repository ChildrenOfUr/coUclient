
A Pump operates on a subscribe/publish sort of model. When one Pump subscribes to another it receives whatever the other Pump publishes, and by default, republishes the event itself.  This 'republishing' can be overridden, but it's a useful feature for the Event Bus design pattern.

---

In order to make working with these classes easier, their syntax is simplified by overriding operators. 

For example, if you want Pump A to subscribe to Pump B you can:

    A > B; // or,
    B < A; // or,
    A.listen(B);

When using the greater than or less than operators, it's important to remember that events travel in the direction of the sign.

    >  points right,  <  points left

If both Pumps need to subscribe to each other, it's simpler to write:

    A & B; // simpler than 'A>B;B>A;'

_However, two 'natural' Pumps should never be mutually subscribed as this would cause an infinite loop. Instead, extend the Pump class into your own, and override the 'process' method. Your event bus should be the only standard Pump in your code. We'll be discussing the process method a little later on._

Adding data or events to a Pump is just as easy as subscribing to one, you simply '+' the event:

    //Example
    Pump A = new Pump();
    Pump B = new Pump();
    // print whatever events B receives 
    B.events.listen(print);
    // link Pumps
    A > B;
    // Add event to A
    A + 'Hello World';
    //B prints => 'Hello World'

---

The 'process' method of an extended Pump is special. Whenever a Pump receives any data, it is processed and returned back to the Pump by the process method (By default, no actual processing occurs, it's just re-published). The ability to override this method is handy because you can use it to transform data when it passes through a pump, as well as trigger functions.

    // This pump will capitalize any strings that pass through it.
    class LoudPump extends Pump {
        @override
        String process(String event) {
            return event.toUpperCase();
        }
    }

    // This pump will run opendoor() when it encounters it's key.
    class LockedPump extends Pump {
        String key = 'password';
         @override
         process(String event) {
         if (event == key) // password
             opendoor();
        // notice the lack of 'return'. This Pump doesn't republish data.
        }
    }

---