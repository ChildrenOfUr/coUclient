part of couclient;

class PromptStringWindow extends Modal {
	String prompt;
	String reference;
	int charLimit;

	ButtonElement submit, cancel;
	TextInputElement input;

	PromptStringWindow(this.prompt, this.reference, this.charLimit) {
		submit = new ButtonElement()
			..text = 'Submit'
			..onClick.first.then((_) => send());

		cancel = new ButtonElement()
			..text = 'Cancel'
			..onClick.first.then((_) => close());

		input = new InputElement(type: 'text')
			..required = true
			..placeholder = prompt
			..maxLength = charLimit;

		displayElement = new DivElement()
			..classes = ['prompt-str-window']
			..append(input)
			..append(cancel)
			..append(submit);

		open(ignoreKeys: true);
	}

	@override
	open({bool ignoreKeys: false}) {
		document.body.append(displayElement);
		super.open(ignoreKeys: ignoreKeys);
	}

	@override
	close() {
		super.close();
		displayElement.remove();
	}

	void send() {
		String value = input.value.trim();

		if (charLimit > 0 && value.length > charLimit) {
			value = value.substring(0, charLimit);
		}

		streetSocket.send(jsonEncode({
			'promptRef': reference,
			'promptResponse': value
		}));

		close();
	}
}