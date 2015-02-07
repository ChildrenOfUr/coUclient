part of couclient;

String SLACK_TEAM;
String SLACK_TOKEN;
String SC_TOKEN;

String SESSION_TOKEN;

class AuthManager {
  String _authUrl = 'https://server.childrenofur.com:8383/auth';

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

    Timer tooLongTimer = new Timer(new Duration(seconds: 5),(){
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
      'audience' : 'http://localhost:8080/index.html'
      //'audience':'http://robertmcdermot.com/cou:80'
    }))
      ..then((HttpRequest data) {
      tooLongTimer.cancel();
      Map serverdata = JSON.decode(data.response);
      
      SESSION_TOKEN = serverdata['sessionToken'];
      SLACK_TEAM = serverdata['slack-team'];
      SLACK_TOKEN = serverdata['slack-token'];
      SC_TOKEN = serverdata['sc-token'];
      
      if (serverdata['playerName'].trim() == '') {
        setupNewUser();
        window.location.href = 'http://childrenofur.com/forums/login';
      }
      else startGame(serverdata);
    });
  }

  void logout() {
      _personaNavigator.logout();
      window.location.reload();
  }
  
  
  startGame(Map serverdata) {
    if (serverdata['ok'] == 'no') {
      print('Error:Server refused the login attempt.');
      _loginButton.hidden = false;
      return;
    }

    // Begin Game//
    game = new Game();
    audio = new SoundManager();
    view.loggedIn();
  }
  
  setupNewUser() {
    Element usernameElement = querySelector('#new-user-name');
    Element submitButton = querySelector('#new-user-submit');
    
    submitButton.onClick.listen((_) {
      submitButton.hidden = true;
      HttpRequest.postFormData('https://server.childrenofur.com:8383/auth', {
        'token': SESSION_TOKEN,
        'username' : usernameElement.text
      }).then((HttpRequest request) {
        print(request.responseText);
        submitButton.hidden = false;
      });
    });
    
    

    
  }

}







