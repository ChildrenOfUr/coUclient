part of couclient;

class BugWindow extends Modal {
  String id = 'bugWindow';
  Service debugService;
  String bugLog = "";
  bool sending = false;

  BugWindow() {
    debugService = new Service(['debug'], logMessage);

    prepare();
    String headerDeco = "/////////////"; // prime number of forward slashes
    view.bugReportMeta.text = headerDeco + ' USER AGENT ' + headerDeco + '\n' + window.navigator.userAgent + '\n' + headerDeco + ' CLIENT LOG ' + headerDeco;

    setupUiButton(view.bugButton, openCallback:_prepareReport);
  }

  void _prepareReport() {
    Element w = this.displayElement;
    TextAreaElement input = w.querySelector('textarea');
    input.value = '';

    // Submits the Bug
    w.querySelector('ur-button').onClick.listen((_) async {
      if (!sending) {
        sending = true;
        if (view.bugReportTitle.value.trim() != "") {
          // send to server
          FormData data = new FormData()
            ..append("token", rsToken)
            ..append("title", view.bugReportTitle.value)
            ..append("description", input.value)
            ..append("log", bugLog)
            ..append("useragent", window.navigator.userAgent)
            ..append("username", game.username)
            ..append("category", view.bugReportType.value);
          await HttpRequest.request("http://${Configs.utilServerAddress}/report/add", method: "POST", sendData: data);
          // complete
          w.hidden = true;
          view.bugReportTitle.value = "";
          input.value = "";
        }
        sending = false;
      }
    });
  }

  logMessage(var message) {
    bugLog += message + "\n";
    view.bugReportMeta.text += message + "\n";
  }
}
