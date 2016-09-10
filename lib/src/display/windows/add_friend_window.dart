part of couclient;

class AddFriendWindow extends Modal {
	Element buttonInput, output;
	DivElement inputForm;
	TextInputElement textInput;
	DataListElement userList;

	String _lastSubmit;

	AddFriendWindow() {
		id = 'addFriendWindow';
		displayElement = querySelector('#$id');

		prepare();

		output = displayElement.querySelector('#addFriendStatus');

		inputForm = displayElement.querySelector('#addFriendForm');

		buttonInput = inputForm.querySelector('#addFriendBtn')
			..hidden = true;

		textInput = inputForm.querySelector('#addFriendEntry')
			..onInput.listen((_) => _updateFormWithEntry());

		userList = displayElement.querySelector('#addFriendUsers');

		_updateFormWithEntry();

		// Add friend button
		querySelector("#add-friend").onClick.listen((_) {
			open();
		});
	}

	String get friendUsername => textInput.value.trim();

	void _updateFormWithEntry() {
		String input = textInput.value.trim();

		bool empty = (input.length == 0); // Only whitespace
		bool current = (game != null && game.username == input); // Self
		bool invalid = (empty || current);

		// Hide button if invalid
		buttonInput.hidden = invalid;

		if (!invalid) {
			// Update typeahead
			// DISABLED, BECAUSE HOLY HELL, IT IS SLOW
//			HttpRequest.getString(
//				'http://${Configs.utilServerAddress}/searchUsers?query=$friendUsername')
//			.then((String json) {
//				List<String> users = JSON.decode(json);
//				users.sort((String a, String b) => levenshtein(a, b, caseSensitive: false));
//				if (users.length > 5) {
//					users = users.sublist(0, 5);
//				}
//				userList.children.clear();
//				for (String username in users) {
//					userList.append(new OptionElement()..value = username);
//				}
//			});
		}

		if (empty) {
			output.text = 'Enter a username to add them as a friend';
		} else if (current) {
			output.text = 'Liking yourself is fine, but not here, okay?';
		} else {
			output.text = '';
		}
	}

	@override
	void open({bool ignoreKeys: false}) {
		super.open(ignoreKeys: ignoreKeys);

		buttonInput.onClick.listen((_) {
			_addFriend();
		});
	}

	void openWith(String prefill) {
		textInput.value = prefill;
		open();
	}

	Future<bool> _addFriend() async {
		if (_lastSubmit == friendUsername) {
			// Prevent double-clicking the button
			return false;
		}

		_lastSubmit = friendUsername;

		String result = await HttpRequest.getString(
			'http://${Configs.utilServerAddress}/friends/add'
			'?username=${game.username}'
			'&friendUsername=$friendUsername'
			'&rstoken=$rsToken');

		if (result == 'true') {
			output.text = '$friendUsername is now your friend!';
			NetChatManager.refreshOnlinePlayers();
			return true;
		} else {
			output.text = 'There was an error. Try again?';
			return false;
		}
	}

	static Future<bool> removeFriend(String friendUsername) async {
		String result = await HttpRequest.getString(
			'http://${Configs.utilServerAddress}/friends/remove'
			'?username=${game.username}'
			'&friendUsername=$friendUsername'
			'&rstoken=$rsToken');

		return (result == 'true');
	}
}
