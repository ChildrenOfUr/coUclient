part of couclient;

String SLACK_TEAM;
String SLACK_TOKEN;
String SC_TOKEN;

class AuthManager extends Pump {
  WebSocket _connection;
  String _authUrl = 'wss://robertmcdermot.com:8282/auth';

  AuthManager() {
    setupWebsocket(_authUrl);
    EVENT_BUS & this;
  }

  @override
  process(Moment<Map> event) {
    return;
  }

  post(Map data) {
    _connection.sendString(JSON.encoder.convert(data));
  }

  void setupWebsocket(String url) {
    _connection = new WebSocket(url)
        ..onOpen.listen((_) {
          // First event, request our tokens.
          post(new Map()
              ..['request'] = 'tokens');
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
          new Moment('DebugEvent', 'Problem with Websocket, check console');
        });
  }
}
