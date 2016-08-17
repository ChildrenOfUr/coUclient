part of couclient;

class AddFriendWindow extends Modal {
	Element buttonInput, output;
	DivElement inputForm;
	TextInputElement textInput;
	DataListElement userList;

	String _lastAdded;

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

	Future _updateFormWithEntry() async {
		String input = textInput.value.trim();

		bool empty = (input.length == 0); // Only whitespace
		bool current = (game != null && game.username == input); // Self
		bool invalid = (empty || current);

		// Hide button if invalid
		buttonInput.hidden = invalid;

		if (!invalid) {
			// Update typeahead
			String json = await HttpRequest.getString(
				'http://${Configs.utilServerAddress}/searchUsers?query=$friendUsername');
			List<String> users = JSON.decode(json);
			userList.children.clear();
			for (String username in users) {
				userList.append(new OptionElement()..value = username);
			}
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
		if (_lastAdded == friendUsername) {
			// Prevent double-clicking the button
			return false;
		}

		String result = await HttpRequest.getString(
			'http://${Configs.utilServerAddress}/friends/add'
			'?username=${game.username}'
			'&friendUsername=$friendUsername'
			'&rstoken=$rsToken');

		if (result == 'true') {
			_lastAdded = friendUsername;
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
