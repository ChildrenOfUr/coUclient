part of couclient;

class AvatarWindow extends Modal {
	static final String USERNAME_FILE_URL =
		'http://childrenofur.com/assets/custom_avatar_options.txt';

	Element _choiceSelector, _buttonInput, _statusDisplay;

	bool _loaded = false;

	String selectedAvatarUsername;

	AvatarWindow() {
		id = 'avatarWindow';
		prepare();

		_choiceSelector = displayElement.querySelector('#avatarSelector');
		_buttonInput = displayElement.querySelector('#chgAvatarBtn');
		_statusDisplay = displayElement.querySelector('#chgAvatarStatus');

		new Service(['avatarChoice'], (String username) {
			selectedAvatarUsername = username;

			_choiceSelector.children.forEach((Element element) {
				if (element.dataset['username'] == username) {
					element.classes.add('selected');
				} else {
					element.classes.remove('selected');
				}
			});
		});

		_buttonInput.onClick.first.then((_) {
			_statusDisplay.text = 'Applying changes...';

			HttpRequest.request(
				'http://${Configs.utilServerAddress}/setCustomAvatar'
				'?username=${game.username}&avatar=$selectedAvatarUsername')
			.then((HttpRequest req) {
				if (req.responseText == 'true') {
					_statusDisplay.text = 'Done! Reloading...';
				} else {
					_statusDisplay.text = 'Oh no, something went wrong! Hang on...';
				}
				hardReload();
			});
		});

		querySelector('#changeAvatarFromChatPanel').onClick.listen((_) => open());
	}

	@override
	void open({bool ignoreKeys: false}) {
		super.open(ignoreKeys: ignoreKeys);
		_open();
	}

	Future _open() async {
		if (!_loaded) {
			String usernameFile = await HttpRequest.getString(USERNAME_FILE_URL);
			List<String> choiceUsernames = usernameFile.trim().split('\n')
				..remove(game.username)
				..insert(0, game.username);

			await Future.forEach(choiceUsernames, (String username) async {
				DivElement choice = await _makeAvatarChoice(username);
				_choiceSelector.append(choice);
			});

			_completeLoad();
		}
	}

	Future<DivElement> _makeAvatarChoice(String username) async {
		// Choice button
		DivElement choice = new DivElement()
			..classes = ['avatar-option']
			..dataset['username'] = username
			..onClick.listen((_) {
				transmit('avatarChoice', username);
			});

		// Preview image
		String base64 = await HttpRequest.getString(
			'http://${Configs.utilServerAddress}/trimImage'
			'?username=$username&noCustomAvatars=true&fullHeight=true');
		choice.append(new ImageElement(src: 'data:image/png;base64,$base64'));

		// Username label
		choice.append(new SpanElement()
			..text = username);

		return choice;
	}

	void _completeLoad() {
		displayElement
			..querySelector('.preload').hidden = true
			..querySelector('.postload').hidden = false;
		_loaded = true;
	}
}
