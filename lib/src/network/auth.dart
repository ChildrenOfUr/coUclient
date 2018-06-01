part of couclient;

String SLACK_WEBHOOK, SC_TOKEN, SESSION_TOKEN, FORUM_TOKEN;

class AuthManager {
	static final String base = 'blinding-fire-920'; //TODO have the server provide this
	fb.Firebase firebase;

	String _authUrl = '${Configs.http}//${Configs.authAddress}/auth';
	String server, websocket;

	Element _loginContainer = querySelector('#login');
	Element _loginGreeting = querySelector('#login_greeting');
	Element _loginMain = querySelector('#login_loggingin');
	Element _loginNewUser = querySelector('#login_new_user');
	Element _loginConfirmPassword = querySelector('#login_confirm_pass');
	Element _loginServicesContainer = querySelector('#login_services');
	Element _loginResetStage1 = querySelector('#login_password_reset_stage_1');
	Element _loginResetStage2 = querySelector('#login_password_reset_stage_2');
	Element _loginTimedOut = querySelector('#login_timedout');
	Element _loginWaitingOnEmail = querySelector('#login_waiting_email');
	Element _loginWarning = querySelector('#login_warning');
	Element _loginPasswordWarning = querySelector('#login_password_reset_warning');
	Element _loginAvatarPreview = querySelector('#login_avatar_preview_img');

	InputElement _loginNewUserUsername = querySelector('#login_new_username');
	InputElement _loginConfirmPasswordInput = querySelector('#login_password_cf');
	InputElement _loginEmail = querySelector('#login_email');
	InputElement _loginPassword = querySelector('#login_password');
	InputElement _loginNewPassword = querySelector('#login_password_reset_new_pw');
	InputElement _loginNewPasswordConfirm = querySelector('#login_password_reset_new_cf');
	InputElement _loginTempPassword = querySelector('#login_password_reset_temp_pw');

	ButtonElement _loginSubmit = querySelector('#login_submit_btn');
	ButtonElement _loginSignup = querySelector('#login_signup_btn');
	ButtonElement _loginResetPassword = querySelector('#login_trigger_forgot_pw');
	ButtonElement _loginNewUserBtn = querySelector('#login_new_user_btn');

	bool invalidEmail = false;
	bool passwordTooShort = false;

	bool _existingUser = false;
	bool get existingUser => _existingUser;
	set existingUser(bool value) {
		_existingUser = value;
		_loginNewUserUsername.disabled = _existingUser;
	}

	bool _forgotPassword = false;
	bool get forgotPassword => _forgotPassword;
	set forgotPassword(bool value) {
		_forgotPassword = value;
		updateLoginMainVisibility();
	}

	bool _loggedIn = false;
	bool get loggedIn => _loggedIn;
	set loggedIn(bool value) {
		_loggedIn = value;
		updateLoginMainVisibility();
		_loginGreeting.hidden = !loggedIn && !serviceLoggedIn;
	}

	bool _newSignup = false;
	bool get newSignup => _newSignup;
	set newSignup(bool value) {
		_newSignup = value;
		updateLoginMainVisibility();
	}

	bool _newUser = false;
	bool get newUser => _newUser;
	set newUser(bool value) {
		_newUser = value;
		updateLoginMainVisibility();
	}

	bool _passwordConfirmation = false;
	bool get passwordConfirmation => _passwordConfirmation;
	set passwordConfirmation(bool value) {
		_passwordConfirmation = value;
		_loginConfirmPassword.hidden = !_passwordConfirmation;
	}

	bool _resetStageTwo = false;
	bool get resetStageTwo => _resetStageTwo;
	set resetStageTwo(bool value) {
		_resetStageTwo = value;
		_loginResetStage1.hidden = _resetStageTwo;
		_loginResetStage2.hidden = !_resetStageTwo;
	}

	bool _serviceLoggedIn = false;
	bool get serviceLoggedIn => _serviceLoggedIn;
	set serviceLoggedIn(bool value) {
		_serviceLoggedIn = value;
		updateLoginMainVisibility();
		_loginGreeting.hidden = !loggedIn && !serviceLoggedIn;
	}

	bool _timedout = false;
	bool get timedout => _timedout;
	set timedout(bool value) {
		_timedout = value;
		_loginTimedOut.hidden = !_timedout;
	}

	bool _waiting = false;
	bool get waiting => waiting;
	set waiting(bool value) {
		_waiting = value;

		if (_waiting) {
			_loginContainer.classes.add('waiting');
		} else {
			_loginContainer.classes.remove('waiting');
		}
	}

	bool _waitingOnEmail = false;
	bool get waitingOnEmail => _waitingOnEmail;
	set waitingOnEmail(bool value) {
		_waitingOnEmail = value;
		_loginWaitingOnEmail.hidden = !_waitingOnEmail;
	}

	void updateLoginMainVisibility() {
		_loginMain.hidden = !(!newUser && !forgotPassword && !newSignup && !loggedIn && !serviceLoggedIn);
	}

	String _avatarUrl;
	String get avatarUrl => _avatarUrl;
	set avatarUrl(String value) {
		_loginAvatarPreview.style.backgroundImage = 'url($value)';
	}

	static final List<String> GREETING_PREFIXES = [
		'Good to see you',
		'Greetings',
		'Hello',
		'Hello there',
		'Have fun',
		'Hi',
		'Hi there',
		'It\'s good to see you',
		'Nice of you to join us',
		'Thanks for joining us',
		'Welcome',
		'Welcome back'
	];

	static String makeGreeting(String username) {
		String greeting = GREETING_PREFIXES[random.nextInt(GREETING_PREFIXES.length)];

		if (username != null) {
			greeting += ', $username';
		}

		return greeting;
	}

	AuthManager() {
		server = '${Configs.http}//${Configs.authAddress}';
		websocket = '${Configs.ws}//${Configs.authWebsocket}';
		firebase = new fb.Firebase('https://$base.firebaseio.com');
		_loginMain.hidden = true;

		if (window.localStorage.containsKey('username')) {
			// Let's see if our firebase auth is current
			Map auth = firebase.getAuth();
			DateTime expires = new DateTime.now();

			if (auth != null) {
				expires = new DateTime.fromMillisecondsSinceEpoch(auth['expires'] * 1000);
			}

			String username = window.localStorage['username'] ?? '';

			if (expires.compareTo(new DateTime.now()) > 0) {
				// Log in with username
				_loginGreeting.text = makeGreeting(username);
				loggedIn = true;
				new Timer(new Duration(seconds: 1), () => relogin());
			} else {
				// It has expired already
				window.localStorage.remove('username');
			}
		} else {
			// Prompt for login
			_loginMain.hidden = false;
		}

		_loginSubmit.onClick.listen((Event event) => loginAttempt(event));
		_loginServicesContainer.children.forEach((ButtonElement element) {
			element.onClick.listen((Event event) => oauthLogin(event));
		});
		_loginResetPassword.onClick.listen((_) => resetPassword());
		_loginSignup.onClick.listen((_) => newSignup = true);

		avatarUrl = 'files/system/player_unknown.png';
	}

	Future loginAttempt(Event event) async {
		_loginWarning.text = '';

		if (!_enterKey(event)) {
			return;
		}

		if (passwordConfirmation) {
			verifyEmail(event);
			return;
		}

		waiting = true;

		Map<String, String> credentials = {'email': _loginEmail.value, 'password': _loginPassword.value};

		try {
			await firebase.authWithPassword(credentials);
			Map sessionMap = await getSession(_loginEmail.value);

			onLoggedIn(sessionMap);
		} catch (err) {
			try {
				// Check to see if they have already verified their email (game window was closed when they clicked the link)
				HttpRequest request = await HttpRequest.request(
					server + '/auth/isEmailVerified',
					method: 'POST',
					requestHeaders: {'content-type': 'application/json'},
					sendData: JSON.encode({'email': _loginEmail.value}));
				Map map = JSON.decode(request.response);
				if (map['result'] == 'success') {
					await _createNewUser(map);
				} else {
					throw(err);
				}
			} catch (err) {
				// We've never seen them before or they haven't yet verified their email
				String error = err.toString();
				if (error.contains('Error: ')) {
					error = error.replaceFirst('Error: ', '');
				}
				_loginWarning.text = error;
				logmessage('[AuthManager] $err');
			}
		} finally {
			waiting = false;
		}
	}

	Future relogin() async {
		try {
			String token = window.localStorage['authToken'];
			String email = window.localStorage['authEmail'];
			await firebase.authWithCustomToken(token);

			HttpRequest request = await HttpRequest.request(
				server + '/auth/getSession',
				method: 'POST',
				requestHeaders: {'content-type': 'application/json'},
				sendData: JSON.encode({'email': email})
			);

			onLoggedIn(JSON.decode(request.response));
		} catch (err) {
			logmessage('Error relogin: $err');

			// Maybe the auth token has expired, present the prompt again
			loggedIn = false;
			window.localStorage.remove('username');
		}
	}

	void onLoggedIn(Map<String, dynamic> serverdata) {
		logmessage('[AuthManager] Setting API tokens');
		SESSION_TOKEN = serverdata['sessionToken'];
		SLACK_WEBHOOK = serverdata['slack-webhook'];
		SC_TOKEN = serverdata['sc-token'];

		sessionStorage['playerName'] = serverdata['playerName'];
		sessionStorage['playerEmail'] = serverdata['playerEmail'];
		sessionStorage['playerStreet'] = decode(serverdata['metabolics'], type: Metabolics).currentStreet;

		if (serverdata['playerName'].trim() == '') {
			setupNewUser(serverdata);
		} else {
			// Get our username and location from the server.
			logmessage('[AuthManager] Logged in');
			startGame(serverdata);
		}
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
		game = new Game(decode(serverdata['metabolics'], type: Metabolics));
	}

	void setupNewUser(Map serverdata) {
		_loginMain.hidden = true;
		_loginNewUser.hidden = false;
		_loginNewUserBtn.onClick.listen((e) {
			String username = _loginNewUserUsername.value;

			localStorage['username'] = username;
			sessionStorage['playerName'] = username;
			sessionStorage['playerEmail'] = serverdata['playerEmail'];
			Map data = {'type': 'set-username',
				'token': SESSION_TOKEN,
				'username': username
			};
			post('setusername', data).then((HttpRequest request) {
				if (request.responseText == '{"ok":"yes"}') {
					// now that the username has been set, start the game
					startGame(serverdata);
				}
			});
		});
	}

	bool _enterKey(Event event) {
		// Detect enter key
		if (event is KeyboardEvent) {
			int code = event.keyCode;

			if (code != 13) {
				return false;
			}
		}

		return true;
	}

	Future verifyEmail(Event event) async {
		_loginWarning.text = '';

		// Not an email
		if (!_loginEmail.value.contains('@')) {
			_loginWarning.text = 'Invalid email';
			return;
		}

		// Password too short
		if (_loginPassword.value.length < 6) {
			_loginWarning.text = 'Password too short';
			return;
		}

		// Display password confirmation
		if (!passwordConfirmation) {
			passwordConfirmation = true;
			return;
		}

		// Passwords don't match
		if (_loginPassword.value != _loginConfirmPasswordInput.value) {
			_loginWarning.text = 'Passwords don\'t match';
			return;
		}

		if (!_enterKey(event)) {
			return;
		}

		if (_loginEmail.value == '') {
			return;
		}

		waiting = true;
		waitingOnEmail = true;

		// Timer tooLongTimer = new Timer(new Duration(seconds: 5), () => timedout = true);

		HttpRequest request = await HttpRequest.request(
			server + '/auth/verifyEmail',
			method: 'POST',
			requestHeaders: {'content-type': 'application/json'},
			sendData: JSON.encode({'email': _loginEmail.value}));
		// tooLongTimer.cancel();

		Map result = JSON.decode(request.response);
		if (result['result'] != 'OK') {
			waiting = false;
			return;
		}

		WebSocket ws = new WebSocket(websocket + '/awaitVerify');

		ws.onOpen.first.then((_) {
			Map map = {'email': _loginEmail.value};
			ws.send(JSON.encode(map));
		});

		ws.onMessage.first.then((MessageEvent event) async {
			Map map = JSON.decode(event.data);
			if (map['result'] == 'success') {
				await _createNewUser(map);
			} else {
				logmessage('[AuthManager] problem verifying email address: ${map['result']}');
			}

			waiting = false;
		});
	}

	Future _createNewUser(Map map) async {
		try {
			// Create the user in firebase
			await firebase.createUser({'email': _loginEmail.value, 'password': _loginPassword.value});

			if (map['serverdata']['playerName'].trim() != '') {
				String username = map['serverdata']['playerName'].trim();
				window.localStorage['username'] = username;

				// Email already exists, make them choose a password
				existingUser = true;
			} else {
				newUser = true;
				Map<String, String> credentials = {'email': _loginEmail.value, 'password': _loginPassword.value};
				window.localStorage['authToken'] = (await firebase.authWithPassword(credentials))['token'];
				window.localStorage['authEmail'] = map['serverdata']['playerEmail'];
			}

			onLoggedIn(map['serverdata']);
		} catch (err) {
			logmessage('[AuthManager] couldn\'t create user on firebase: $err');
		}
	}

	Future<Map> getSession(String email) async {
		HttpRequest request = await HttpRequest.request(
			server + '/auth/getSession',
			method: 'POST',
			requestHeaders: {'content-type': 'application/json'},
			sendData: JSON.encode({'email':email}));

		window.localStorage['authToken'] = firebase.getAuth()['token'];
		window.localStorage['authEmail'] = email;

		Map sessionMap = JSON.decode(request.response);
		if (sessionMap['playerName'] != '') {
			window.localStorage['username'] = sessionMap['playerName'];
		}

		return sessionMap;
	}

	Future oauthLogin(Event event) async {
		String provider = (event.target as Element).dataset['provider'];
		String scope = 'email';

		if (provider == 'github') {
			scope = 'user:email';
		}

		waiting = true;

		try {
			Map response = await firebase.authWithOAuthPopup(provider, scope:scope);
			logmessage('[AuthManager] user logged in with $provider');

			String email = response[provider]['email'];
			Map sessionMap = await getSession(email);
			onLoggedIn(sessionMap);
		} catch (err) {
			logmessage('[AuthManager] failed login with $provider: $err');
		} finally {
			waiting = false;
			serviceLoggedIn = true;
		}
	}

	void resetPassword() {
		if (!resetStageTwo) {
			firebase.resetPassword({'email': _loginEmail.value});
			resetStageTwo = true;
			return;
		} else {
			if (_loginNewPassword.value != _loginNewPasswordConfirm.value) {
				_loginPasswordWarning.text = 'Passwords don\'t match';
				return;
			}

			String tempPass = _loginTempPassword.value;
			String newPass = _loginNewPassword.value;

			firebase.changePassword({
				'email': _loginEmail.value,
				'oldPassword': tempPass,
				'newPassword': newPass
			}).catchError(logmessage);

			togglePassword();
		}
	}

	void togglePassword() {
		forgotPassword = !forgotPassword;
		resetStageTwo = false;
	}

	void updateAvatarPreview() {
		// Read input
		String getUsername = _loginNewUserUsername.value;

		// Provide a default
		if (getUsername == '') {
			getUsername = 'Hectaku';
		}

		// $server = http|//hostname|8383 (| = split point)
		//           ^  +     ^    (-  ^)
		HttpRequest.getString('${Configs.http}//${Configs.utilServerAddress}/getSpritesheets?username=$getUsername').then((String json) {
			avatarUrl = JSON.decode(json)['base'];

			// Used for sizing
			ImageElement avatarData = new ImageElement()
				..src = avatarUrl;

			// Resize elements to fit image
			avatarData.onLoad.listen((_) {
				querySelector('#avatar-container').style
					..width = (avatarData.naturalWidth / 15).toString() + 'px';
				querySelector('#avatar-img').style
					..width = (avatarData.naturalWidth).toString() + 'px'
					..height = (avatarData.naturalHeight).toString() + 'px';
			});
		});
	}
}
