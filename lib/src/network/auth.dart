part of couclient;

String SLACK_TEAM;
String SLACK_TOKEN;
String SC_TOKEN;

class AuthManager {
  WebSocket _connection;
  String _authUrl = 'wss://robertmcdermot.com:8282/auth';
  
  
  AuthManager() {    
    // Starts the game
    Element loginButton = querySelector('#login-button');
    Persona personaNavigator = new Persona('', setupWebsocket,ui.logout);
    loginButton.onClick.listen((_) {
      personaNavigator.request({'backgroundColor':'#4b2e4c','siteName':'Children of Ur'});
      ;
      
    });
  }

  void setupWebsocket(String personaAssertion) {
    _connection = new WebSocket(_authUrl)
        ..onOpen.listen((_) {
          // First event, request our tokens.
          post(new Map()
              ..['request'] = 'login'
              ..['persona'] = {'assertion':personaAssertion,'audience':window.location.href});
        })
        
        ..onMessage.listen((MessageEvent message) {
          Map data = JSON.decoder.convert(message.data);
          print(data);
          
          ui.login();
        })
        ..onError.listen((message) {
          // Send the Error to the bus.
          new Message(#err, 'Problem with Authentication Socket, check console');
        });
  }
  
  post(Map data) {
    _connection.sendString(JSON.encoder.convert(data));
  }
}
