part of couclient;

String SLACK_TEAM;
String SLACK_TOKEN;
String SC_TOKEN;

String SESSION_TOKEN;
String FORUM_TOKEN;

class AuthManager {
  String _authUrl = 'https://server.childrenofur.com:8383/auth';

  Persona _personaNavigator;
  Element _loginPanel;

  AuthManager() {
    // Starts the game
    _loginPanel = querySelector('ur-login');

    _personaNavigator = new Persona('', verifyWithServer, view.loggedOut);
    _loginPanel.on['attemptLogin'].listen((_) {
      _personaNavigator.request({
        'backgroundColor': '#4b2e4c',
        'siteName': 'Children of Ur'
      });
    });
  }


  void verifyWithServer(String personaAssertion) {
    Timer tooLongTimer = new Timer(new Duration(seconds: 5),(){
      Element signinElement = querySelector('ur-login')
          ..attributes['timedout'] = 'true';
    });

    post('login', {
      'assertion': personaAssertion,
      //'audience' : 'http://localhost:8080/index.html'
    })
      ..then((HttpRequest data) {
      tooLongTimer.cancel();
      Map serverdata = JSON.decode(data.response);

      if (serverdata['ok'] == 'no') {
        print('Error:Server refused the login attempt.');
        return;
      }

      SESSION_TOKEN = serverdata['sessionToken'];
      SLACK_TEAM = serverdata['slack-team'];
      SLACK_TOKEN = serverdata['slack-token'];
      SC_TOKEN = serverdata['sc-token'];

      if (serverdata['playerName'].trim() == '') {
        setupNewUser(serverdata);
      }
      else {
        // Get our username and location from the server.
        sessionStorage['playerName'] = serverdata['playerName'];
        sessionStorage['playerEmail'] = serverdata['playerEmail'];
        sessionStorage['playerStreet'] = decode(JSON.decode(serverdata['metabolics']),Metabolics).current_street;
        startGame(serverdata);
      }
    });
  }

  Future post(String type ,Map data) {
    return HttpRequest.request(_authUrl + "/$type", method: "POST", requestHeaders: {
          "content-type": "application/json"
        }, sendData: JSON.encode(data));
  }

  void logout() {
      _personaNavigator.logout();
      window.location.reload();
  }


  startGame(Map serverdata) {
    if (serverdata['ok'] == 'no') {
      print('Error:Server refused the login attempt.');
      return;
    }

    // Begin Game//
    game = new Game(decode(JSON.decode(serverdata['metabolics']),Metabolics));
    audio = new SoundManager();
    inputManager = new InputManager();
    view.loggedIn();
  }

  setupNewUser(Map serverdata) {
    Element signinElement = querySelector('ur-login');
    signinElement.attributes['newuser'] = 'true';
    signinElement.on['setUsername'].listen((_) {

    	post('setusername', {
        'type' : 'set-username',
        'token': SESSION_TOKEN,
        'username' : (signinElement.shadowRoot.querySelector('#new-user-name') as InputElement).value
      }).then((HttpRequest request) {

        if (request.responseText == '{"ok":"yes"}') {
          // now that the username has been set, refresh and auto-login.
          window.location.reload();
          }
      });
    });

  }

}







