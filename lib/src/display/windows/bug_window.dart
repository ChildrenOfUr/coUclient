part of couclient;

class BugWindow extends Modal {
  String id = 'bugWindow';
  String messagesLogged = "";
  Service debugService;
  bool sending = false;
  Element component = querySelector("user-feedback");

  BugWindow() {
	  debugService = new Service(['debug'], logMessage);

	  prepare();
	  String headerDeco = "/////////////"; // prime number of forward slashes
	  view.bugReportMeta.text = headerDeco + ' USER AGENT ' + headerDeco + '\n' + window.navigator.userAgent + '\n' + headerDeco + ' CLIENT LOG ' + headerDeco;

	  setupUiButton(view.bugButton, openCallback: _prepareReport);
  }

  void _prepareReport() {
	  Element w = this.displayElement;
	  TextAreaElement input = w.querySelector("textarea");
	  input.value = "";

	  // Submits the bug
	  w.querySelector("ur-button").onClick.listen((_) async {
		  if (!sending) {
			  sending = true;
			  if (view.bugReportTitle.value.trim() != "") {
				  // Send to server
				  FormData data = new FormData()
					  ..append("token", rsToken)
					  ..append("title", view.bugReportTitle.value)
					  ..append("description", input.value)
					  ..append("log", messagesLogged)
					  ..append("useragent", window.navigator.userAgent)
					  ..append("username", game.username)
					  ..append("category", view.bugReportType.value);
				  await HttpRequest.request("http://${Configs.utilServerAddress}/report/add", method: "POST", sendData: data);
				  // Complete
				  w.hidden = true;
				  view.bugReportTitle.value = "";
				  input.value = "";
			  }
			  sending = false;
		  }
	  });
  }

  void logMessage(var message) {
	  messagesLogged += message + "\n";
	  view.bugReportMeta.text += message + "\n";
  }
}