part of couclient;

String SLACK_WEBHOOK, SC_TOKEN, SESSION_TOKEN, FORUM_TOKEN;

class AuthManager {
	String _authUrl = '${Configs.http}//${Configs.authAddress}/auth';

	AuthManager() {
		// Starts the game
		document.on['loginSuccess'].first.then((Event e) {
//			print('got success, firing back');
			//fire acknowledgement event
			transmit('loginAcknowledged',null);

			Map<String, dynamic> serverdata = (e as CustomEvent).detail;

			logmessage('[AuthManager] Setting API tokens');
			SESSION_TOKEN = serverdata['sessionToken'];
			SLACK_WEBHOOK = serverdata['slack-webhook'];
			SC_TOKEN = serverdata['sc-token'];

			sessionStorage['playerName'] = serverdata['playerName'];
			sessionStorage['playerEmail'] = serverdata['playerEmail'];
			sessionStorage['playerStreet'] = Metabolics.fromJson(jsonDecode(serverdata['metabolics'])).currentStreet;

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
		}, sendData: jsonEncode(data));
	}

	void logout() async {
		logmessage('[AuthManager] Attempting logout');
		localStorage.remove('username');
		await firebase.auth().signOut();
		window.location.reload();
	}

	startGame(Map<String, dynamic> serverdata) {
		inputManager = new InputManager();
		view.loggedIn();
		audio.sc = new SC(SC_TOKEN);

		// Begin Game//
		game = new Game(Metabolics.fromJson(jsonDecode(serverdata['metabolics'])));
	}

	setupNewUser(Map serverdata) {
//		print('setupNewUser');
		// _loginPanel.newUser = true;
		document.on['setUsername'].listen((Event e) {
//			print('setUsername event');
			String username = (e as CustomEvent).detail;
//			print('setting name to ${e.detail}');

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
					startGame(serverdata);
				} else {
//					print('name change failed');
				}
			});
		});
	}
}