part of couclient;

class BugWindow extends Modal {
  String id = 'bugWindow';
  String messagesLogged = "";
  Service debugService;
  Element component = querySelector("user-feedback");

  BugWindow() {
    debugService = new Service(['debug'], logMessage);

    prepare();
	setupUiButton(view.bugButton, openCallback: open());

	new Service(["gameLoaded"], (_) {
		component.attributes
			..["username"] = game.username
			..["useragent"] = browser.toString() + "\n" + window.navigator.userAgent
			..["log"] = messagesLogged;
	});

	new Service(["REPORT_SENT"], (Map data) {
		close();
		toast("Report, uh, reported!");
	});
  }

  void logMessage(var message) {
	  messagesLogged += message + "\n";
  }
}