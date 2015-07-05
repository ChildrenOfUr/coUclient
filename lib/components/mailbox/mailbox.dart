library mailbox;

import 'dart:convert';
import 'dart:html';
import 'dart:async';

import 'package:intl/intl.dart';
import "package:polymer/polymer.dart";
import 'package:jsonx/jsonx.dart';
import 'package:transmit/transmit.dart';
import 'package:couclient/src/network/metabolics.dart';

import "mail.dart";

@CustomTag("ur-mailbox")
class Mailbox extends PolymerElement {
	@observable List<Mail> messages = toObservable([]);
	@observable String selected = "inbox", toField, toSubject, toBody, fromField, fromSubject, fromBody;
	@observable int fromId, userCurrants, toCurrants = 0, fromCurrants;
	@published String serverAddress;
	@observable bool userHasMessages, currants_taken;
	Element currantDisplay;
	NumberFormat commaFormatter = new NumberFormat("#,###");

	Mailbox.created() : super.created() {
		new Service(['metabolicsUpdated'],(Metabolics metabolics){
			userCurrants = metabolics.currants;
		});
		currantDisplay = shadowRoot.querySelector("#fromCurrants");
	}

	refresh() async {
		String user = window.sessionStorage['playerName'];
		HttpRequest request = await postRequest(serverAddress + '/getMail', {'user':user});
		messages = decode(request.responseText, type: const TypeHelper<List<Mail>>().type);
		if(messages.isNotEmpty) {
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
		fromCurrants = message.currants;
		if(fromCurrants > 0) {
			if (message.currants_taken) {
				currantDisplay.classes.add('taken');
				currants_taken = true;
			} else {
				currants_taken = false;
				currantDisplay.classes.remove('taken');
				currantDisplay.onClick.first.then((_) async {
					await postRequest(serverAddress + '/collectCurrants', encode(message), encode:false);
					currantDisplay.classes.add('taken');
					currants_taken = true;
				});
			}
			currantDisplay.querySelector('#fromCurrantsNum').text = commaFormatter.format(fromCurrants).toString();
			currantDisplay.hidden = false;
		} else {
			currantDisplay.hidden = true;
		}

		//mark message read on server
		await postRequest(serverAddress + '/readMail', encode(message), encode:false);
		refresh();
	}

	reply(Event event, var detail, Element target) {
		int id = int.parse(target.attributes['data-message-id']);
		Mail message = messages.singleWhere((Mail m) => m.id == id);
		toField = message.from_user;
		toSubject = "Re: " + message.subject;
		selected = "compose";
	}

	compose() {
		selected = "compose";
	}

	closeMessage() => selected = "inbox";

	sendMessage() async {
		Mail message = new Mail();
		message.to_user = toField;
		message.from_user = window.sessionStorage['playerName'];
		message.body = toBody;
		message.subject = toSubject;
		message.currants = toCurrants;

		HttpRequest request = await postRequest(serverAddress + '/sendMail', encode(message), encode:false);
		if(request.responseText == "OK") {
			//clear sending fields (for next message)

			toField = "";
			toBody = "";
			toSubject = "";
			toCurrants = 0;
			selected = "inbox";
		}
	}

	deleteMessage(Event event, var detail, Element element) async {
		event.stopPropagation(); //don't 'click' on the message and go to the view screen

		int id = int.parse(element.attributes['data-message-id']);
		HttpRequest request = await postRequest(serverAddress + '/deleteMail', {'id':id});

		if(request.responseText == "OK") {
			messages.removeWhere((Mail m) => m.id == id);
		}

		messages = toObservable(new List.from(messages));
		//list not updating without this
	}

	Future<HttpRequest> postRequest(String url, var data, {Map requestHeaders : null, bool encode : true}) {
		if(requestHeaders == null) {
			requestHeaders = {"content-type": "application/json"};
		}
		if(encode) {
			data = JSON.encode(data);
		}
		return HttpRequest.request(url, method: "POST", requestHeaders:requestHeaders, sendData: data);
	}
}