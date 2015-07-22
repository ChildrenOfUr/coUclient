part of couclient;

String SLACK_WEBHOOK, SLACK_BUG_WEBHOOK, SC_TOKEN, SESSION_TOKEN, FORUM_TOKEN;

class AuthManager {
	static String prefix = Configs.baseAddress.contains('localhost')?'http://':'https://';
	String _authUrl = '$prefix${Configs.authAddress}/auth';
	UrLogin _loginPanel;

	AuthManager() {
		// Starts the game
		_loginPanel = querySelector('ur-login');

		_loginPanel.on['loginSuccess'].first.then((e) {
			print('got success, firing back');
			//fire acknowledgement event
			transmit('loginAcknowledged',null);

			inputManager = new InputManager();

			Map serverdata = e.detail;

			logmessage('[AuthManager] Setting API tokens');
			SESSION_TOKEN = serverdata['sessionToken'];
			SLACK_WEBHOOK = serverdata['slack-webhook'];
			SLACK_BUG_WEBHOOK = serverdata['slack-bug-webhook'];
			SC_TOKEN = serverdata['sc-token'];

			sessionStorage['playerName'] = serverdata['playerName'];
			sessionStorage['playerEmail'] = serverdata['playerEmail'];
			sessionStorage['playerStreet'] = decode(serverdata['metabolics'], type:Metabolics).current_street;

			if(serverdata['playerName'].trim() == '') {
				setupNewUser(serverdata);
			} else {
				// Get our username and location from the server.
				logmessage('[AuthManager] Logged in');
				startGame(serverdata);
			}
		});
	}

	Future<HttpRequest> post(String type, Map data) {
		return HttpRequest.request(_authUrl + "/$type", method: "POST", requestHeaders: {
			"content-type": "application/json"
		}, sendData: JSON.encode(data));
	}

	void logout() {
		logmessage('[AuthManager] Attempting logout');
		localStorage.remove('username');
		_loginPanel.firebase.unauth();
		window.location.reload();
	}

	startGame(Map serverdata) {
		view.loggedIn();
		audio.sc = new SC(SC_TOKEN);

		// Begin Game//
		game = new Game(decode(serverdata['metabolics'], type:Metabolics));
	}

	setupNewUser(Map serverdata) {
		print('setupNewUser');
		_loginPanel.newUser = true;
		_loginPanel.on['setUsername'].listen((e) {
			print('setUsername event');
			String username = e.detail;
			print('setting name to ${e.detail}');

			localStorage['username'] = username;
			sessionStorage['playerName'] = username;
			sessionStorage['playerEmail'] = serverdata['playerEmail'];
			Map data = {'type' : 'set-username',
				'token': SESSION_TOKEN,
				'username' : username
			};
			post('setusername', data).then((HttpRequest request) {
				if(request.responseText == '{"ok":"yes"}') {
					// now that the username has been set, start the game
					inputManager = new InputManager();
					startGame(serverdata);
				} else {
					print('name change failed');
				}
			});
		});
	}
}