part of couclient;

String SLACK_TEAM;
String SLACK_TOKEN;
String SC_TOKEN;

class AuthManager {
  String _authUrl = 'http://robertmcdermot.com:8181/auth';

  AuthManager() {
    // Starts the game
    Element loginButton = querySelector('#login-button');
    Persona personaNavigator = new Persona('', verifyWithServer, logout);
    loginButton.onClick.listen((_) {
      personaNavigator.request({
        'backgroundColor': '#4b2e4c',
        'siteName': 'Children of Ur'
      });
    });
  }

  void verifyWithServer(String personaAssertion) {
    HttpRequest.request(_authUrl + "/login", method: "POST", requestHeaders: {
      "content-type": "application/json"
    }, sendData: JSON.encode({
      'assertion': personaAssertion
    })).then((HttpRequest data) {
      print(data.response);
      ui.login();
    });
  }

  void logout() {
    /*
    HttpRequest.request(_authUrl + "/logout", method: "POST", requestHeaders: {
      "content-type": "application/json"
    }, sendData: JSON.encode({
      'session-key': 'fake'
    })).then((HttpRequest data) {
      print(data.response);
      ui.logout();
    });
    */
  }

}
