part of couclient;

String SLACK_TEAM;
String SLACK_TOKEN;
String SC_TOKEN;

String SESSION_TOKEN;

class AuthManager {
  String _authUrl = 'https://robertmcdermot.com:8383/auth';

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
      'assertion': personaAssertion, 'testing':true
    })).then((HttpRequest data) {
      print(data.response);
      Map serverdata = JSON.decode(data.response);

      if (serverdata['ok'] == 'no') {
        print('Error:Server refused the login attempt.');
        return;
      }

      // Get our username and location from the server.
      sessionStorage['playerName'] = serverdata['playerName'];
      sessionStorage['playerStreet'] = serverdata['playerStreet'];
      
      SESSION_TOKEN = serverdata['sessionToken'];

      SLACK_TEAM = serverdata['slack-team'];
      SLACK_TOKEN = serverdata['slack-token'];
      SC_TOKEN = serverdata['sc-token'];

      view.loggedIn();
    });
  }

  void logout() {
  }

}
