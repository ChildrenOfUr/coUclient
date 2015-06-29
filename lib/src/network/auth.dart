part of couclient;

String SLACK_WEBHOOK, SLACK_BUG_WEBHOOK, SC_TOKEN, SESSION_TOKEN, FORUM_TOKEN;

class AuthManager
{
	String _authUrl = 'https://${Configs.authAddress}/auth';
	UrLogin _loginPanel;

	AuthManager()
	{
		// Starts the game
		_loginPanel = querySelector('ur-login');

		_loginPanel.on['loginSuccess'].listen((e)
		{
			inputManager = new InputManager();

			Map serverdata = e.detail;

			log('Auth: Setting API tokens');
			SESSION_TOKEN = serverdata['sessionToken'];
			SLACK_WEBHOOK = serverdata['slack-webhook'];
			SLACK_BUG_WEBHOOK = serverdata['slack-bug-webhook'];
			SC_TOKEN = serverdata['sc-token'];

			sessionStorage['playerName'] = serverdata['playerName'];
			sessionStorage['playerEmail'] = serverdata['playerEmail'];
			sessionStorage['playerStreet'] = decode(JSON.decode(serverdata['metabolics']),Metabolics).current_street;

			if(serverdata['playerName'].trim() == '')
			{
				setupNewUser(serverdata);
			}
			else
			{
				// Get our username and location from the server.
				log('Auth: Logged in');
				startGame(serverdata);
			}
		});
	}

	Future post(String type ,Map data)
	{
		return HttpRequest.request(_authUrl + "/$type", method: "POST", requestHeaders: {
          "content-type": "application/json"
		}, sendData: JSON.encode(data));
	}

	void logout()
	{
 		log('Auth: Attempting logout');
		localStorage.remove('username');
		_loginPanel.firebase.unauth();
		window.location.reload();
	}

	startGame(Map serverdata)
	{
		view.loggedIn();
		audio.sc = new SC(SC_TOKEN);

		// Begin Game//
		game = new Game(decode(JSON.decode(serverdata['metabolics']),Metabolics));
	}

	setupNewUser(Map serverdata)
	{
		print('setupNewUser');
		_loginPanel.newUser = true;
		_loginPanel.on['setUsername'].listen((e)
		{
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
			post('setusername', data).then((HttpRequest request)
			{
				if(request.responseText == '{"ok":"yes"}')
				{
					// now that the username has been set, start the game
					inputManager = new InputManager();
					startGame(serverdata);
				}
				else {
					print('name change failed');
				}
			});
		});
	}
}