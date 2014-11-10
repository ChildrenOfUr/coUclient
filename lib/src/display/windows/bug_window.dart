part of couclient;

class BugWindow extends Modal {
  String id = 'bugWindow';

  BugWindow() {
    prepare();
    // BUG REPORT LISTENERS
    bool listening = false;
    view.bugButton.onClick.listen((_) {
      this.open();
      Element w = this.window;
      TextAreaElement input = w.querySelector('textarea');
      view.bugReportMeta.text = 'UserAgent:' + window.navigator.userAgent + '\n////////////////////////////////\n';

      // Submits the Bug
      // TODO someday this should be serverside. Let's not give our keys to the client unless we have to.
      if (listening == false) {
        listening = true;
        w.querySelector('.button').onClick.listen((_) {
          if (input.value.trim() != ''){
          slack.Message m = new slack.Message('${view.bugReportMeta.text} \n REPORT TYPE:${view.bugReportType.value} \n ${input.value} \n ${view.bugReportEmail.value}',username:game.username);
          slack.team = SLACK_TEAM;
          slack.token = SLACK_TOKEN;
          slack.send(m);
          w.hidden = true;
          }
          else{
            new Message(#err,'If you want to submit a bug, please let us know what you find wrong.');
          }
        });
      }
    });
  }


}
