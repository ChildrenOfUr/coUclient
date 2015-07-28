part of couclient;

class BugWindow extends Modal {
  String id = 'bugWindow';
  Service debugService;
  String bugLog = "";

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
    // TODO someday this should be serverside. Let's not give our keys to the client unless we have to.
    w.querySelector('ur-button').onClick.listen((_) async {
      // send to slack
//			slack.Slack s = new slack.Slack(SLACK_BUG_WEBHOOK);
//			slack.Message m = new slack.Message('${view.bugReportMeta.text}\n\nReport Type: ${view.bugReportType.value}\n\nComments: ${input.value}\n\nEmail: ${game.email}\n', username:game.username);
//			s.send(m);
      // send to server
      FormData data = new FormData()
        ..append("title", view.bugReportTitle.value)
        ..append("description", input.value)
        ..append("log", bugLog)
        ..append("useragent", window.navigator.userAgent)
        ..append("username", game.username)
        ..append("email", game.email)
        ..append("category", view.bugReportType.value);
      if (view.bugReportImage.files.isNotEmpty) {
        data.appendBlob("image", view.bugReportImage.files.first, view.bugReportImage.files.first.name);
      } else {
        data.append("image", "");
      }
      await HttpRequest.request("http://${Configs.utilServerAddress}/report/add", method: "POST", sendData: data);
      // complete
      w.hidden = true;
      view.bugReportTitle.value = "";
      input.value = "";
      view.bugReportImage.files.clear();
    });
  }

  logMessage(var message) {
    bugLog += message + "\n";
    view.bugReportMeta.text += message + "\n";
  }
}
