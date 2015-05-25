library mailbox;

import 'dart:convert';
import 'dart:html';
import 'dart:async';

import "package:polymer/polymer.dart";
import "package:couclient/configs.dart";
import "package:redstone_mapper/mapper.dart";

import "mail.dart";

@CustomTag("ur-mailbox")
class Mailbox extends PolymerElement {
	@observable List<Mail> messages = toObservable([]);
	@observable String selected = "inbox", toField, toSubject, toBody, fromField, fromSubject, fromBody;
	@observable int fromId;
	String serverAddress;
	@observable bool userHasMessages;

	Mailbox.created() : super.created() {
		serverAddress = 'http://${Configs.utilServerAddress}';
	}

	refresh() async {
		String user = window.sessionStorage['playerName'];
		HttpRequest request = await postRequest(serverAddress + '/getMail', {'user':user});
		messages = decode(JSON.decode(request.responseText), Mail);
		if (messages.isNotEmpty) {
			userHasMessages = true;
			print("User's mailbox is not empty.");
		}
		else {
			userHasMessages = false;
			print("User's mailbox is empty.");
		}
	}

	read(Event event, var detail, Element target) async {
		selected = "read";
		int id = int.parse(target.attributes['data-message-id']);
		Mail message = messages.singleWhere((Mail m) => m.id == id);
		fromField = message.from_user;
		fromSubject = message.subject;
		fromBody = message.body;
		fromId = message.id;

		//mark message read on server
		await postRequest(serverAddress+'/readMail',encode(message));
	}

	reply(Event event, var detail, Element target) {
		int id = int.parse(target.attributes['data-message-id']);
		Mail message = messages.singleWhere((Mail m) => m.id == id);
		toField = message.from_user;
		toSubject = "Re: " + message.subject;
		selected = "compose";
	}

	compose() => selected = "compose";

	closeMessage() => selected = "inbox";

	sendMessage() async {
		Mail message = new Mail();
		message.to_user = toField;
		message.from_user = window.sessionStorage['playerName'];
		message.body = toBody;
		message.subject = toSubject;

		HttpRequest request = await postRequest(serverAddress + '/sendMail', encode(message));
		if(request.responseText == "OK") {
			//clear sending fields (for next message)

			toField = "";
			toBody = "";
			toSubject = "";
			selected = "inbox";
		}
	}

	deleteMessage(Event event, var detail, Element element) async {
		event.stopPropagation(); //don't 'click' on the message and go to the view screen

		int id = int.parse(element.attributes['data-message-id']);
		HttpRequest request = await postRequest(serverAddress + '/deleteMail', {'id':id});

		if(request.responseText == "OK")
			messages.removeWhere((Mail m) => m.id == id);

		messages = toObservable(new List.from(messages)); //list not updating without this
	}

	Future<HttpRequest> postRequest(String url, var data, [Map requestHeaders]) {
		if(requestHeaders == null)
			requestHeaders = {"content-type": "application/json"};
		return HttpRequest.request(url, method: "POST", requestHeaders:requestHeaders, sendData: JSON.encode(data));
	}
}