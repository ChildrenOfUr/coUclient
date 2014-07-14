part of couclient;

String channelName = 'Global Chat';// TODO temporary

// TODO Add documentation to the doc folder that outlines the format outgoing chat messages must adhere to.
class ChatManager extends Pump {
  WebSocket _connection;
  ChatManager() {
    _connection = new WebSocket('ws://vps.robertmcdermot.com:8080')
        ..onOpen.listen((_) {
          // First event, tells the server who we are.
          post([null,
                new Map()
              ..['message'] = 'userName=' + 'TestingPaul'
              ..['channel'] = channelName]);

          // Get a List of the other players online
          post([null,
                new Map()
              ..['hide'] = 'true'
              ..['username'] = 'TestingPaul'
              ..['statusMessage'] = 'list'
              ..['channel'] = channelName]);
        })
        ..onMessage.listen((MessageEvent message) {
          this +  JSON.decoder.convert(message.data); // Turns the data into a Map or List, processes it..
        })
        ..onClose.listen((_) {
          //wait 5 seconds and try to reconnect
          new Timer(new Duration(seconds: 5), () {
            ;
          });
        })
        ..onError.listen((message) {
          this + ['ErrorEvent','Problem with Websocket, check console']; // Send the Error to the bus.
        });
    EVENT_BUS & this;
  }
  @override 
  process(List event) {// Only accepts 'OutgoingChatEvent's
    if (event is OutgoingChatEvent)
      //TODO transmit those events
      return event;
  }
  post(var data) {
      _connection.sendString(JSON.encoder.convert(data[1]));
    }  
}

class OutgoingChatEvent extends Event {
  OutgoingChatEvent(String payload) : super(payload);
}

class ChatEvent extends Event {
  ChatEvent(String payload) : super(payload);
}