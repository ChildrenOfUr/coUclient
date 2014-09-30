part of couclient;

String SLACK_TEAM;
String SLACK_TOKEN;
String SC_TOKEN;

class AuthManager {
  WebSocket _connection;
  String _authUrl = 'wss://robertmcdermot.com:8282/auth';
  
  
  AuthManager() {
    setupWebsocket(_authUrl);
  }

  post(Map data) {
    _connection.sendString(JSON.encoder.convert(data));
  }

  void setupWebsocket(String url) {
    _connection = new WebSocket(url)
        ..onOpen.listen((_) {
          // First event, request our tokens.
          post(new Map()
              ..['request'] = 'tokens'
              ..['persona'] = {'assertion':'null','audience':window.location.href});
        })
        
        ..onMessage.listen((MessageEvent message) {
          Map data = JSON.decoder.convert(message.data);
          if (data['statusMessage'] == 'list') new Moment(#chatListEvent, data); else new Moment(#chatEvent, data);
        })
        ..onClose.listen((_) {
          //wait 5 seconds and try to reconnect
          new Timer(new Duration(seconds: 5), () => setupWebsocket(url));
        })
        ..onError.listen((message) {
          // Send the Error to the bus.
          new Moment(#err, 'Problem with Websocket, check console');
        });
  }
}
