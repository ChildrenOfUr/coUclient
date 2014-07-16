part of couclient;


// TODO Add documentation to the doc folder that outlines the format outgoing chat messages must adhere to.
class NetChatManager extends Pump {
  WebSocket _connection;
  NetChatManager() {
    _connection = new WebSocket('ws://vps.robertmcdermot.com:8080')
        ..onOpen.listen((_) {
          // First event, tells the server who we are.
          post(new Map()
              ..['message'] = 'userName=' + ui.username
              ..['channel'] = 'Global Chat');
  
          // Get a List of the other players online
          post(new Map()
              ..['hide'] = 'true'
              ..['username'] = ui.username
              ..['statusMessage'] = 'list'
              ..['channel'] = 'Global Chat');
        
        })
        ..onMessage.listen((MessageEvent message) {
          new EventInstance('ChatEvent',JSON.decoder.convert(message.data));
        })
        ..onClose.listen((_) {
          //wait 5 seconds and try to reconnect
          new Timer(new Duration(seconds: 5), () {
          });
        })
        ..onError.listen((message) {
          this + ['ErrorEvent','Problem with Websocket, check console']; // Send the Error to the bus.
        });
    EVENT_BUS & this;
  }
  @override 
  process(var event) {// Only accepts 'OutgoingChatEvent's
    if (event.type == 'OutgoingChatEvent') {
      event.payload['username'] = ui.username;
      post(event.payload);
      return;
    }
  }
  post(Map data) {
      _connection.sendString(JSON.encoder.convert(data));
    }  
}