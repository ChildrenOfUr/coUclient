part of couclient;

class BugWindow extends Modal {
  String id = 'bugWindow';

  Service debugService;
  
  BugWindow() {
    debugService = new Service(['debug'], logMessage);
    
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
          slack.Slack s = new slack.Slack(SLACK_BUG_WEBHOOK);
          slack.Message m = new slack.Message('${view.bugReportMeta.text} \n REPORT TYPE:${view.bugReportType.value} \n ${input.value} \n ${view.bugReportEmail.value}',username:game.username);
          s.send(m);
          w.hidden = true;
          toast("Report sent");
        });
      }
    });

    querySelector("#rwc-bugwindow").onClick.listen((_) {
      view.bugButton.click();
    });

    querySelector("#rwc-bugwindow-icon").onClick.listen((_) {
      view.bugButton.click();
    });
  }

  logMessage(var message) {
    log(message);
  }
  
  log(String text) {
    view.bugReportMeta.text += '\n' + text;
  }

}
