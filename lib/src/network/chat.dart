part of couclient;


// TODO Add documentation to the doc folder that outlines the format outgoing chat messages must adhere to.
class NetChatManager extends Pump {
  WebSocket _connection;
  String _chatServerUrl = 'ws://robertmcdermot.com:8282';

  NetChatManager() {
    //assign temporary chat handle
    if (localStorage["username"] != null) ui.username = localStorage["username"]; else {
      Random rand = new Random();
      ui.username += rand.nextInt(10000).toString();
    }

    setupWebsocket(_chatServerUrl);

    EVENT_BUS & this;
  }

  @override
  process(Moment<Map> event) {
    // Only accepts 'OutgoingChatEvent's
    if (event.isType('OutgoingChatEvent')) {
      if (_connection.readyState == WebSocket.OPEN) {
        post(event.content);
      }
      return;
    }
  }

  post(Map data) {
    _connection.sendString(JSON.encoder.convert(data));
  }

  void setupWebsocket(String url) {
    _connection = new WebSocket(url)
        ..onOpen.listen((_) {
          // First event, tells the server who we are.
          post(new Map()
              ..['username'] = ui.username
              ..['statusMessage'] = 'join');

          // Get a List of the other players online
          post(new Map()
              ..['hide'] = 'true'
              ..['username'] = ui.username
              ..['statusMessage'] = 'list'
              ..['channel'] = 'Global Chat');
        })
        ..onMessage.listen((MessageEvent message) {
          Map data = JSON.decoder.convert(message.data);
          if (data['statusMessage'] == 'list') new Moment('ChatListEvent', data, 'incoming Chat message'); else new Moment('ChatEvent', data, 'incoming Chat message');
        })
        ..onClose.listen((_) {
          //wait 5 seconds and try to reconnect
          new Timer(new Duration(seconds: 5), () => setupWebsocket(url));
        })
        ..onError.listen((message) {
          // Send the Error to the bus.
          new Moment('ErrorEvent', 'Problem with Websocket, check console');
        });
  }
}
