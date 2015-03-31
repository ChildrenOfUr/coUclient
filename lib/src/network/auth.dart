part of couclient;

String SLACK_TEAM, SLACK_TOKEN, SC_TOKEN, SESSION_TOKEN, FORUM_TOKEN;

class AuthManager
{
	String _authUrl = 'https://${Configs.authAddress}/auth';
	Element _loginPanel;

	AuthManager()
	{
		// Starts the game
		_loginPanel = querySelector('ur-login');
		_loginPanel.on['loginSuccess'].listen((e)
		{
			Map serverdata = e.detail;

			log('Auth: Setting API tokens');
			SESSION_TOKEN = serverdata['sessionToken'];
			SLACK_TEAM = serverdata['slack-team'];
			SLACK_TOKEN = serverdata['slack-token'];
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
				inputManager = new InputManager();
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
		window.location.reload();
	}

	startGame(Map serverdata)
	{
		// Begin Game//
		game = new Game(decode(JSON.decode(serverdata['metabolics']),Metabolics));
		audio.sc = new SC(SC_TOKEN);
		view.loggedIn();
	}

	setupNewUser(Map serverdata)
	{
		_loginPanel.attributes['newUser'] = 'true';
		_loginPanel.on['setUsername'].listen((e)
		{
			String username = e.detail;
			localStorage['username'] = username;
			Map data = {'type' : 'set-username',
						'token': SESSION_TOKEN,
						'username' : username
						};
			post('setusername', data).then((HttpRequest request)
			{
				if(request.responseText == '{"ok":"yes"}')
				{
					// now that the username has been set, start the game
					startGame(serverdata);
				}
			});
		});
	}
}