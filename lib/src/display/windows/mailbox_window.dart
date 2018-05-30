part of couclient;

class MailboxWindow extends Modal {
	String id = 'mailboxWindow';

	MailboxWindow() {
		prepare();
	}

	@override
	open({bool ignoreKeys: false}) {
		refresh();
		inputManager.ignoreKeys = true;
		super.open();
	}

	@override
	close() {
		inputManager.ignoreKeys = false;
		super.close();
	}

	Future refresh() async {

	}
}