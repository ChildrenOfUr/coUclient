library slack_html;

import 'dart:html';
import 'package:slack/src/slacksrc.dart';
export 'package:slack/src/slacksrc.dart';


/**
 *  Posts a Slack message to the properly authenticated Slack token.
 *  The messages will go to whatever channel the token was set up for.
 */
send(Message m) {
  String outurl = 'https://' + team + '.slack.com/services/hooks/incoming-webhook?token=' + token; 
  String payload = m.toString();  
  HttpRequest.postFormData(outurl,{'payload' : payload});
}







