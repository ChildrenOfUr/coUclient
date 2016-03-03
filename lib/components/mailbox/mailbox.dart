library mailbox;

import 'dart:convert';
import 'dart:html';
import 'dart:async';

import 'package:intl/intl.dart';
import "package:polymer/polymer.dart";
import 'package:jsonx/jsonx.dart';
import 'package:transmit/transmit.dart';
import 'package:couclient/src/network/metabolics.dart';
import 'package:dnd/dnd.dart';
import 'package:couclient/src/network/server_interop/itemdef.dart';

import "mail.dart";
import 'dialog.dart';

@CustomTag("ur-mailbox")
class Mailbox extends PolymerElement {
	@observable List<Mail> messages = toObservable([]);
	@observable String selected = "inbox",
		toField,
		toSubject,
		toBody,
		fromField,
		fromSubject,
		fromBody;
	@observable int fromId,
		userCurrants,
		toCurrants = 0,
		fromCurrants;
	@published String serverAddress, darkui;
	@observable bool userHasMessages, currants_taken;
	Element currantDisplay, datalistTo;
	NumberFormat commaFormatter = new NumberFormat("#,###");
	List<Map<ItemDef, int>> itemsList = [];
	List<String> itemSlots = [null, null, null, null, null];
	Dialog actionDialog;

	Mailbox.created() : super.created() {
		actionDialog = new Dialog(shadowRoot.querySelector('#actionDialog'));

		new Service(['metabolicsUpdated'], (Metabolics metabolics) {
			userCurrants = metabolics.currants;
		});
		currantDisplay = shadowRoot.querySelector("#fromCurrants");
		datalistTo = shadowRoot.querySelector('#toList');

		Dropzone dropzone = new Dropzone(shadowRoot.querySelectorAll(".itemBox"));
		dropzone.onDrop.listen((DropzoneEvent dropEvent) {
			ItemDef item = _decodeItemFromElement(dropEvent.draggableElement);
			if (item == null) {
				return;
			}

			//don't allow bags with stuff in them, empty bags are fine
			if (item.isContainer) {
				for (Map slot in item.metadata['slots']) {
					if (slot['itemType'] != '') {
						return;
					}
				}
			}

			String id = dropEvent.dropzoneElement.id;
			int index = int.parse(id.substring(id.length - 1));
			itemSlots[index - 1] = _getSlotStringFromElement(dropEvent.draggableElement);

			itemsList.add({item:1});

			dropEvent.dropzoneElement.append(dropEvent.draggableElement.clone(true));
//			DivElement count = new DivElement()
//				..className='itemCount'
//				..text='1';
//			dropEvent.dropzoneElement.append(count);

		});

		shadowRoot
			.querySelectorAll('input, textarea')
			.onFocus
			.listen((_) {
			transmit('disableChatFocus', true);
			transmit('disableInputKeys', true);
		});
		shadowRoot
			.querySelectorAll('input, textarea')
			.onBlur
			.listen((_) {
			transmit('disableChatFocus', false);
			transmit('disableInputKeys', false);
		});

		// Dark theme
		if (darkui == "true") {
			shadowRoot.host.classes.add("darkui");
			print(shadowRoot.host);
		}
	}

	ItemDef _decodeItemFromElement(Element element) {
		//verify it is a valid item before acting on it
		if (element.attributes['itemMap'] == null) {
			return null;
		}

		Map itemMap = JSON.decode(element.attributes['itemMap']);
		Map metadata = itemMap['metadata'];
		itemMap['metadata'] = {};

		ItemDef item = decode(JSON.encode(itemMap), type: ItemDef);
		item.metadata = metadata;

		return item;
	}

	Future refresh() async {
		String user = window.sessionStorage['playerName'];
		HttpRequest request = await postRequest(serverAddress + '/getMail', {'user':user});
		messages = decode(request.responseText, type: const TypeHelper<List<Mail>>().type);
		messages.forEach((Mail m) {
			if (m.subject
				    .trim()
				    .length == 0) {
				m.subject = "(No Subject)";
			}
		});
		userHasMessages = messages.isNotEmpty;
	}

	Future toChanged(Event event, var detail, Element target) async {
		String sofar = (target as InputElement).value;
		if(sofar.length > 2) {
			String url = '$serverAddress/searchUsers?query=$sofar';
			String response = await HttpRequest.getString(url);
			datalistTo.children.clear();
			List<String> matchingPlayers = JSON.decode(response);
			for(String matching in matchingPlayers) {
				OptionElement option = new OptionElement()..value = matching;
				datalistTo.append(option);
			}
		} else if (sofar.length == 0){
			datalistTo.children.clear();
		}
	}

	Future read(Event event, var detail, Element target) async {
		await refresh();
		selected = "read";
		int id = int.parse(target.attributes['data-message-id']);
		Mail message = messages.singleWhere((Mail m) => m.id == id);
		fromField = message.from_user;
		fromSubject = message.subject;
		fromBody = message.body;
		fromId = message.id;
		fromCurrants = message.currants;
		currants_taken = message.currants_taken;
		if (fromCurrants > 0) {
			// currants sent with message
			if (currants_taken) {
				// server knows currants are already taken
				currantDisplay.classes.add('taken');
				currantDisplay.title = 'Already Taken';
				currants_taken = true;
			} else {
				// not yet taken
				currants_taken = false;
				currantDisplay.classes.remove('taken');
				// take currants on click
				currantDisplay.onClick.first.then((_) async {
					await postRequest(serverAddress + '/collectCurrants', encode(message), encode: false);
					currantDisplay.classes.add('taken');
					currantDisplay.title = 'Already Taken';
					currants_taken = true;
				});
			}
			// taken or not
			currantDisplay
				.querySelector('#fromCurrantsNum')
				.text = commaFormatter.format(fromCurrants).toString();
			currantDisplay.hidden = false;
		} else {
			// no currants sent with message
			currantDisplay.hidden = true;
		}
		List<String> fromItems = [message.item1, message.item2, message.item3,
		message.item4, message.item5
		];
		List<bool> takens = [message.item1_taken, message.item2_taken, message.item3_taken,
		message.item4_taken, message.item5_taken
		];

		int i = 1;
		for (String itemString in fromItems) {
			if (itemString != null) {
				ItemDef item = decode(itemString, type: ItemDef);
				DivElement itemBox = shadowRoot.querySelector('#from_item$i');
				itemBox.style.backgroundImage = "url('${item.iconUrl}')";
				itemBox.hidden = false;

				if (takens[i - 1]) {
					itemBox.classes.add('taken');
					itemBox.title = 'Already Taken';
				} else {
					int index = i;
					StreamSubscription clickListener;
					clickListener = itemBox.onClick.listen((_) => _clickItem(index, message, itemBox, clickListener));
				}
			}
			i++;
		}

		//mark message read on server
		await postRequest(serverAddress + '/readMail', encode(message), encode: false);
		refresh();
	}

	Future _clickItem(int index, Mail message, Element itemBox, StreamSubscription clickListener) async {
		clickListener.cancel();
		if (itemBox.dataset['fake-click'] != null) {
			//this is set to remove the click listener on clean up without trying to get the item
			itemBox.dataset.remove('fake-click');
			return;
		}
		itemBox.classes.add('taken');
		itemBox.title = 'Already Taken';
		String response = await _takeItem(index, message.id, message.to_user);
		if (response != 'Success') {
			//if we failed to take it for some reason, allow the user to try again later
			itemBox.classes.remove('taken');
			itemBox.attributes.remove('title');
			clickListener = itemBox.onClick.listen((_) => _clickItem(index, message, itemBox, clickListener));
		}
	}

	Future<String> _takeItem(int index, int id, String to_user) async {
		return (await postRequest(serverAddress + '/collectItem',
			                          {'index':index, 'id': id, 'to_user' : to_user})).responseText;
	}

	reply(Event event, var detail, Element target) {
		int id = int.parse(target.attributes['data-message-id']);
		Mail message = messages.singleWhere((Mail m) => m.id == id);
		toField = message.from_user;
		toSubject = "Re: " + message.subject;
		selected = "compose";
	}

	compose() => selected = "compose";

	closeMessage() {
		for (int i = 1; i < 6; i++) {
			DivElement itemBox = shadowRoot.querySelector('#from_item$i');
			itemBox.dataset['fake-click'] = 'true';
			itemBox.click();
			itemBox.style.removeProperty('background-image');
			itemBox.hidden = true;
			itemBox.classes.remove('taken');
			itemBox.attributes.remove('title');
		}
		selected = "inbox";
		refresh();
	}

	cleanUp() {
		toField = "";
		toBody = "";
		toSubject = "";
		toCurrants = 0;
		shadowRoot.querySelectorAll(".itemBox").forEach((Element e) => e.children.clear());
		selected = "inbox";
		refresh();
	}

	String _getSlotStringFromElement(Element element) {
		if (element.dataset['from-index'] == null) {
			return null;
		}
		return '${element.dataset['from-index']}.${element.dataset['from-bag-index']}';
	}

	sendMessage() async {
		Mail message = new Mail();
		message.to_user = toField;
		message.from_user = window.sessionStorage['playerName'];
		if (toBody != null) {
			message.body = toBody;
		} else {
			message.body = "";
		}
		message.subject = toSubject;
		message.currants = toCurrants;
		message.item1_slot = itemSlots[0];
		message.item2_slot = itemSlots[1];
		message.item3_slot = itemSlots[2];
		message.item4_slot = itemSlots[3];
		message.item5_slot = itemSlots[4];

		HttpRequest request = await postRequest(serverAddress + '/sendMail',
			                                        encode(message), encode: false);
		if (request.responseText == "OK") {
			//clear sending fields (for next message)
			cleanUp();
		}
	}

	deleteMessage(Event event, var detail, Element element, {bool prompt: true}) async {
		event.stopPropagation(); //don't 'click' on the message and go to the view screen

		int id = int.parse(element.attributes['data-message-id']);
		Mail m = messages.singleWhere((Mail m) => m.id == id);

		if (prompt) {
			//let's make sure the user didn't forget to grab any currants/items
			if ((m.currants > 0 && !m.currants_taken) || (m.item1 != null && !m.item1_taken) ||
			    (m.item2 != null && !m.item2_taken) || (m.item3 != null && !m.item3_taken) ||
			    (m.item4 != null && !m.item4_taken) || (m.item5 != null && !m.item5_taken)) {
				actionDialog.dialogTitle = 'Confirm Delete';
				actionDialog.dialogBody =
				'This message contains uncollected currants or items. Are you sure you want to delete it?';
				actionDialog.open();
				actionDialog.onButtonClick.first.then((ButtonEvent buttonEvent) {
					actionDialog.close();
					if (buttonEvent == ButtonEvent.Affirmative) {
						deleteMessage(event, detail, element, prompt: false);
					} else {
						return;
					}
				});
				return;
			}
		}

		HttpRequest request = await postRequest(serverAddress + '/deleteMail', {'id':id});

		if (request.responseText == "OK") {
			messages.removeWhere((Mail m) => m.id == id);
		}

		//list not updating without this
		messages = toObservable(new List.from(messages));

		//if the list is now empty
		userHasMessages = messages.isNotEmpty;
	}

	Future<HttpRequest> postRequest(String url, var data, {Map requestHeaders: null, bool encode: true}) {
		if (requestHeaders == null) {
			requestHeaders = {"content-type": "application/json"};
		}
		if (encode) {
			data = JSON.encode(data);
		}
		return HttpRequest.request(url, method: "POST", requestHeaders: requestHeaders, sendData: data);
	}
}
