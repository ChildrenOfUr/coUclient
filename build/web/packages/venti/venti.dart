library venti;
import 'dart:async';

/**
 *  EventRouters direct traffic among themselves.
 *  It emits everyting it consumes. Can funciton as an Event Bus.
 *  override the 'process' method to modify the returned data.
*/
class EventRouter {
  // Stream Management
  StreamController _internal = new StreamController.broadcast();
  Stream get events => _internal.stream;
  List _listeners = [];
  int get listeners =>_listeners.length;
  
  
  /// emits an event, which is detected by anyone listening to this object.
  emit(Event event) {
    if (event != null && listeners > 0)
      _internal.add(event);
  }
  /// Adds an event to the Router, equivalent to saying 'emit(event)'
  operator +(Event event) { // Shorthand
    emit(event);
  }
  /// Detects the events emitted by the 'other' EventRouter
  listen(EventRouter other) {
    other._listeners.add(this);
    other.events.listen((Event event) => emit(process(event))); // Emit the processed event
  }
  /// equivalent to saying 'listen(other)'
  operator <(EventRouter other) { // Shorthand
    listen(other);
  }
  /// Events are readonly, so a new one may have to be made.
  Event process(Event event) {
    return event; // By default, no processing is actually done
  }

  /// Closes the internal StreamController.
  destroy() {
    _internal.close();
  }
}


class Event {
  var _payload;
  get payload => _payload;
  toString() => '${this.runtimeType}:"$payload":' + this.hashCode.toString();
  Event(this._payload);
}
