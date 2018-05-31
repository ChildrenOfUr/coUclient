part of couclient;

String SLACK_WEBHOOK, SC_TOKEN, SESSION_TOKEN, FORUM_TOKEN;

class AuthManager {
	String _authUrl = '${Configs.http}//${Configs.authAddress}/auth';

	Element _loginPanel = querySelector('#login');
	Element _loginGreeting = querySelector('#login_greeting');
	Element _loginMain = querySelector('#login_loggingin');
	Element _loginTimeout = querySelector('#login_timedout');
	Element _loginNewUser = querySelector('#login_new_user');
	InputElement _loginNewUserUsername = querySelector('#login_new_username');
	Element _loginForgotPassword = querySelector('#login_password_reset');

	AuthManager() {
		// Starts the game

//		_loginPanel.host.on['loginSuccess'].first.then((e) {
////			print('got success, firing back');
//			//fire acknowledgement event
//			transmit('loginAcknowledged',null);
//
//			Map serverdata = e.detail;
//
//			logmessage('[AuthManager] Setting API tokens');
//			SESSION_TOKEN = serverdata['sessionToken'];
//			SLACK_WEBHOOK = serverdata['slack-webhook'];
//			SC_TOKEN = serverdata['sc-token'];
//
//			sessionStorage['playerName'] = serverdata['playerName'];
//			sessionStorage['playerEmail'] = serverdata['playerEmail'];
//			sessionStorage['playerStreet'] = decode(serverdata['metabolics'], type:Metabolics).currentStreet;
//
//			if(serverdata['playerName'].trim() == '') {
//				setupNewUser(serverdata);
//			} else {
//				// Get our username and location from the server.
//				logmessage('[AuthManager] Logged in');
//				startGame(serverdata);
//			}
//		});
	}

	Future<HttpRequest> post(String type, Map data) {
		return HttpRequest.request(_authUrl + "/$type", method: "POST", requestHeaders: {
			"content-type": "application/json"
		}, sendData: JSON.encode(data));
	}

	void logout() {
		logmessage('[AuthManager] Attempting logout');
		localStorage.remove('username');
		// TODO _loginPanel.firebase.unauth();
		window.location.reload();
	}

	void startGame(Map serverdata) {
		inputManager = new InputManager();
		view.loggedIn();
		audio.sc = new SC(SC_TOKEN);

		// Begin Game//
		game = new Game(decode(serverdata['metabolics'], type:Metabolics));
	}

	void setupNewUser(Map serverdata) {
		hideAllSections();
		_loginNewUser.hidden = false;
		querySelector('#login_new_user_btn').onClick.listen((e) {
			String username = _loginNewUserUsername.value;

			localStorage['username'] = username;
			sessionStorage['playerName'] = username;
			sessionStorage['playerEmail'] = serverdata['playerEmail'];
			Map data = {'type' : 'set-username',
				'token': SESSION_TOKEN,
				'username' : username
			};
			post('setusername', data).then((HttpRequest request) {
				if (request.responseText == '{"ok":"yes"}') {
					// now that the username has been set, start the game
					startGame(serverdata);
				}
			});
		});
	}

	void hideAllSections() {
		_loginPanel.children.forEach((Element child) => child.hidden = true);
	}
}
