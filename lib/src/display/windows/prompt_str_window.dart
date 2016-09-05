part of couclient;

class PromptStringWindow extends Modal {
	String prompt;
	String reference;

	ButtonElement submit, cancel;
	TextInputElement input;

	PromptStringWindow(this.prompt, this.reference) {
		submit = new ButtonElement()
			..text = 'Submit'
			..onClick.first.then((_) => send());

		cancel = new ButtonElement()
			..text = 'Cancel'
			..onClick.first.then((_) => close());

		input = new InputElement(type: 'text')
			..required = true
			..placeholder = prompt;

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
		streetSocket.send(JSON.encode({
			'promptRef': reference,
			'promptResponse': input.value.trim()
		}));

		close();
	}
}