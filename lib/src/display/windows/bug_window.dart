part of couclient;

class BugWindow extends Modal {
  String id = 'bugWindow';

  Service debugService;
  
  BugWindow() {
    debugService = new Service([#debug], logMessage);
    
    prepare();
    String headerDeco = "/////////////"; // prime number of forward slashes
    view.bugReportMeta.text = headerDeco + ' USER AGENT ' + headerDeco + '\n' + window.navigator.userAgent + '\n' + headerDeco + ' CLIENT LOG ' + headerDeco;
    
    // BUG REPORT LISTENERS
    bool listening = false;
    view.bugButton.onClick.listen((_) {
      this.open();
      Element w = this.window;
      TextAreaElement input = w.querySelector('textarea');
      input.value = '';
      
      // Submits the Bug
      // TODO someday this should be serverside. Let's not give our keys to the client unless we have to.
      if (listening == false) {
        listening = true;
        w.querySelector('ur-button').onClick.listen((_) {
          slack.Message m = new slack.Message('${view.bugReportMeta.text} \n REPORT TYPE:${view.bugReportType.value} \n ${input.value} \n ${view.bugReportEmail.value}',username:game.username);
          slack.team = SLACK_TEAM;
          slack.token = SLACK_TOKEN;
          slack.send(m);
          w.hidden = true;
        });
      }
    });
  }

  logMessage(Message message) {
    log(message.content);
  }
  
  log(String text) {
    view.bugReportMeta.text += '\n' + text;
  }

}
