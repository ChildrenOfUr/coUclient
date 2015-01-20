part of couclient;

String SLACK_TEAM;
String SLACK_TOKEN;
String SC_TOKEN;

String SESSION_TOKEN;

class AuthManager {
  String _authUrl = 'https://robertmcdermot.com:8383/auth';

  Persona _personaNavigator;
  Element _loginButton;

  AuthManager() {
    // Starts the game
    _loginButton = querySelector('#login-button');
    _personaNavigator = new Persona('', verifyWithServer, view.loggedOut);
    _loginButton.onClick.listen((_) {
      _personaNavigator.request({
        'backgroundColor': '#4b2e4c',
        'siteName': 'Children of Ur'
      });
      _loginButton.hidden = true;
    });
  }

  void verifyWithServer(String personaAssertion) {
    _loginButton.hidden = true;

    Timer tooLongTimer = new Timer(new Duration(seconds: 4),(){
      SpanElement greeting = querySelector('#greeting');
      greeting.text = '''
Oh no!
Looks like the server is a bit slow. 
Please check back another time. :(''';
    });

    HttpRequest.request(_authUrl + "/login", method: "POST", requestHeaders: {
      "content-type": "application/json"
    }, sendData: JSON.encode({
      'assertion': personaAssertion,
      //'audience' : 'http://localhost:8080/game.html'
      'audience':'http://robertmcdermot.com/cou:80'
    }))
      ..then((HttpRequest data) {
      tooLongTimer.cancel();

      Map serverdata = JSON.decode(data.response);
      print(serverdata);

      if (serverdata['ok'] == 'no') {
        print('Error:Server refused the login attempt.');
        _loginButton.hidden = false;
        return;
      }

      // Have they registered? TODO: we need a way to register in-game.
      if (serverdata['playerName'].trim() == '') {
        window.location.href = 'http://childrenofur.com/forums/login';
       }

      // Get our username and location from the server.
      sessionStorage['playerName'] = serverdata['playerName'];

      sessionStorage['playerStreet'] = serverdata['playerStreet'];

      SESSION_TOKEN = serverdata['sessionToken'];

      SLACK_TEAM = serverdata['slack-team'];
      SLACK_TOKEN = serverdata['slack-token'];
      SC_TOKEN = serverdata['sc-token'];

      // Begin Game//
      game = new Game();

      audio = new SoundManager();
      view.loggedIn();
    });
  }

  void logout() {
      _personaNavigator.logout();
      window.location.reload();
  }

}
