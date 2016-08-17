part of couclient;

class ChangeUsernameWindow extends Modal {
	static Completer<String> response;

	Element buttonInput, output;
	SpanElement currantDisplay, currantCost;
	DivElement inputForm;
	TextInputElement textInput;

	ChangeUsernameWindow() {
		id = 'changeUsernameWindow';
		displayElement = querySelector('#$id');

		prepare();

		currantDisplay = displayElement.querySelector('#chgUsernameCurrants');

		output = displayElement.querySelector('#chgUsernameStatus');

		currantCost = displayElement.querySelector('#chgUsernameCost')
			..text = commaFormatter.format(constants['changeUsernameCost']) + ' ';

		inputForm = displayElement.querySelector('#chgUsernameForm');

		buttonInput = inputForm.querySelector('#chgUsernameBtn')
			..hidden = true;

		textInput = inputForm.querySelector('#chgUsernameEntry')
			..onInput.listen((_) => _updateFormWithEntry());

		_updateFormWithEntry();

		// Change username button
		querySelector("#changeUsernameFromChatPanel").onClick.listen((_) {
			open();
		});
	}

	void _updateFormWithEntry() {
		String input = textInput.value.trim();

		bool empty = (input.length == 0); // Only whitespace
		bool current = (game != null && game.username == input); // No change
		bool invalid = (empty || current);

		// Hide button if invalid
		buttonInput.hidden = invalid;

		if (empty) {
			output.text = 'Choose a new username';
		} else if (current) {
			output.text = 'You already have that username';
		} else {
			output.text = '';
		}
	}

	@override
	void open({bool ignoreKeys: false}) {
		super.open(ignoreKeys: ignoreKeys);
		currantDisplay.text = commaFormatter.format(metabolics.currants) + ' ';
		setFormDisabled(metabolics.currants < constants['changeUsernameCost']);
		buttonInput.onClick.first.then((_) {
			_changeUsername();
		});
	}

	void setFormDisabled(bool disabled) {
		inputForm.attributes['disabled'] = disabled.toString();
	}

	Future _changeUsername() async {
		Future _wait() => new Future.delayed(new Duration(seconds: 3));

		setFormDisabled(true);

		switch (await _makeRequest()) {
			case 'OK':
				output.text = 'Username changed!\nLogging out to apply changes...';
				await _wait();
				auth.logout();
				break;
			case 'TAKEN':
				output.text = 'That username is already taken.';
				textInput.value = '';
				break;
			case 'ERR':
				output.text = 'Something went wrong.\nTry again after I reload...';
				await _wait();
				hardReload();
				break;
		}

		setFormDisabled(false);
	}

	Future<String> _makeRequest() async {
		sendAction('changeClientUsername', 'global_action_monster', {
			'oldUsername': game.username,
			'newUsername': textInput.value
		});

		response = new Completer();
		return await response.future;
	}
}
