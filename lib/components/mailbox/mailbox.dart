library mailbox;

import 'dart:convert';
import 'dart:html';

import "package:polymer/polymer.dart";
import "package:couclient/configs.dart";
import "package:redstone_mapper/mapper.dart";

@CustomTag("ur-mailbox")
class Mailbox extends PolymerElement {
	@observable List<Message> messages = toObservable([]);
	@observable String selected="inbox", toField, toSubject, toBody, fromField, fromSubject, fromBody;
	String serverAddress;

	Mailbox.created() : super.created()
	{
		serverAddress = 'http://${Configs.utilServerAddress}';
	}

	refresh() async {
		String user = window.sessionStorage['playerName'];
		HttpRequest request = await HttpRequest.request(serverAddress + "/getMail", method: "POST",
		                                                requestHeaders: {"content-type": "application/json"},
		                                                sendData: JSON.encode({'user':user}));
		messages = decode(JSON.decode(request.responseText), Message);
	}

	read(Event event, var detail, Element target){
		selected = "read";
		int id = int.parse(target.attributes['data-message-id']);
		Message message = messages.singleWhere((Message m) => m.id == id);
		fromField = message.from_user;
		fromSubject = message.subject;
		fromBody = message.body;
	}

	compose() => selected = "compose";

	closeMessage() => selected = "inbox";

	sendMessage() async
	{
		Message message = new Message();
		message.to_user = toField;
		message.from_user = window.sessionStorage['playerName'];
		message.body = toBody;
		message.subject = toSubject;
		print(encode(message));

		HttpRequest request = await HttpRequest.request(serverAddress + "/sendMail", method: "POST",
		                                                requestHeaders: {"content-type": "application/json"},
		                                                sendData: JSON.encode(encode(message)));

		if(request.responseText == "OK")
			selected = "inbox";
	}
}

class Message {
	@Field()
	int id;
	@Field()
	String to_user;
	@Field()
	String from_user;
	@Field()
	String subject;
	@Field()
	String body;
}