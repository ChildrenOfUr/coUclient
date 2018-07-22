part of couclient;

class MailboxWindow extends Modal {
	String id = 'mailboxWindow';

	List<Mail> messages = [];
	List<String> itemSlots = new List.filled(5, null);

	Mail lastMessage;

	Map<String, Element> tabs = {
		'compose': querySelector('#mb_compose'),
		'read': querySelector('#mb_read'),
		'inbox': querySelector('#mb_inbox')
	};

	Element _inboxList = querySelector('#mb_inbox_list');
	Element _inboxListBody = querySelector('#mb_inbox_list .messageItems');
	Element _emptyInbox = querySelector('#mb_emptyinbox');
	Element _sendItems = querySelector('#mb_sendItems');
	Element _fromDisplay = querySelector('#mb_from');
	Element _subjectDisplay = querySelector('#mb_subject');
	Element _messageDisplay = querySelector('#mb_message');
	Element _currantDisplay = querySelector('#mb_fromCurrants');
	Element _currantNumDisplay = querySelector('#mb_fromCurrantsNum');

	List<Element> _fromItemBoxes = [
		querySelector('#mb_from_item1'),
		querySelector('#mb_from_item2'),
		querySelector('#mb_from_item3'),
		querySelector('#mb_from_item4'),
		querySelector('#mb_from_item5')
	];

	ButtonElement _refreshBtn = querySelector('#mb_refresh_btn');
	ButtonElement _composeBtn = querySelector('#mb_compose_btn');
	ButtonElement _sendBtn = querySelector('#mb_action_send');
	ButtonElement _discardBtn = querySelector('#mb_action_discard');
	ButtonElement _replyBtn = querySelector('#mb_btn_reply');
	ButtonElement _readCloseBtn = querySelector('#mb_btn_close');
	AnchorElement _composeLink = querySelector('#mb_compose_link');

	DataListElement _toList = querySelector('#mb_toList');
	InputElement _inputTo = querySelector('#mb_input_to');
	InputElement _inputSubject = querySelector('#mb_input_subject');
	InputElement _inputMessage = querySelector('#mb_input_message');
	NumberInputElement _inputCurrants = querySelector('#mb_sendCurrants');

	bool busy = false;

	bool _userHasMessages;
	bool get userHasMessages => _userHasMessages;
	set userHasMessages(bool value) {
		_userHasMessages = value;
		_inboxList.hidden = !_userHasMessages;
		_emptyInbox.hidden = _userHasMessages;
	}

	MailboxWindow() {
		prepare();

		_refreshBtn.onClick.listen((Event event) async => await refresh());
		_composeBtn.onClick.listen((_) => switchToTab('compose'));
		_composeLink.onClick.listen((_) => switchToTab('compose'));
		_discardBtn.onClick.listen((_) => switchToTab('inbox'));
		_sendBtn.onClick.listen((_) async => await send());
		_readCloseBtn.onClick.listen((_) => switchToTab('inbox'));
		_replyBtn.onClick.listen((_) => reply());
		_inputTo.onChange.listen((_) => updateFriendsTypeahead());

		Dropzone dropzone = new Dropzone(displayElement.querySelectorAll('.toItem'));
		dropzone.onDrop.listen((DropzoneEvent event) {
			ItemDef item = _decodeItemFromElement(event.draggableElement);
			if (item == null) {
				return;
			}

			// Only allow bags if they are empty
			if (item.isContainer) {
				for (Map slot in jsonDecode(item.metadata['slots'])) {
					if (slot['itemType'] != '') {
						return;
					}
				}
			}

			String id = event.dropzoneElement.id;
			int index = int.parse(id.substring(id.length - 1)) - 1;
			itemSlots[index] = _getSlotStringFromElement(event.draggableElement);

			event.dropzoneElement.append(event.draggableElement.clone(true));

			//			DivElement count = new DivElement()
//				..className='itemCount'
//				..text='1';
//			dropEvent.dropzoneElement.append(count);
		});
	}

	@override
	open({bool ignoreKeys: false}) {
		switchToTab('inbox');
		inputManager.ignoreKeys = true;
		super.open();
	}

	@override
	close() {
		inputManager.ignoreKeys = false;
		super.close();
	}

	void switchToTab(String tab) {
		tabs.forEach((String name, Element host) => host.hidden = tab != name);

		switch (tab) {
			case 'inbox':
				refresh();
				break;
			case 'compose':
				_inputCurrants.max = metabolics.currants.toString();
				break;
		}
	}

	void clearComposeView() {
		_inputTo.value = '';
		_inputSubject.value = '';
		_inputMessage.value = '';
		_sendItems.children.forEach((Element box) => box.children.clear());
	}

	static Future<HttpRequest> postRequest(String endpoint, var data, {Map requestHeaders: null, bool encode: true}) {
		if (requestHeaders == null) {
			requestHeaders = {"content-type": "application/json"};
		}

		if (encode) {
			data = jsonEncode(data);
		}

		return HttpRequest.request(
			'${Configs.http}//${Configs.utilServerAddress}/$endpoint',
			method: "POST",
			requestHeaders: requestHeaders,
			sendData: data);
	}

	Future refresh() async {
		if (busy) {
			return;
		}

		busy = true;
		HttpRequest request = await postRequest('getMail', {'user': game.username});

		messages = jsonDecode(request.responseText).map((Map<String, dynamic> json) => Mail.fromJson(json)).toList();
		_inboxListBody.children.clear();

		messages.forEach((Mail m) {
			if (m.subject.trim().length == 0) {
				m.subject = "(No Subject)";
			}

			_inboxListBody.append(m.display());
		});

		userHasMessages = messages.isNotEmpty;
		busy = false;
	}

	Future read(int id) async {
		await refresh();
		lastMessage = messages.singleWhere((Mail m) => m.id == id);

		// Show message
		_fromDisplay.text = 'A message from ' + lastMessage.from_user;
		_subjectDisplay.text = lastMessage.subject;
		_messageDisplay.text = lastMessage.body;

		// Currants
		if (lastMessage.currants > 0) {
			// Currants sent with message
			if (lastMessage.currants_taken) {
				// Server knows currants are already taken
				_currantDisplay.classes.add('taken');
			} else {
				// Currants not yet taken
				_currantDisplay.classes.remove('taken');
				_currantDisplay.title = 'Already taken';

				// Take currants on click
				_currantDisplay.onClick.first.then((_) async {
					HttpRequest request = await postRequest('collectCurrants', lastMessage.toJson(), encode: false);
					_currantDisplay.classes.add('taken');
					if (request.responseText.trim() == 'Success') {
						_currantDisplay.title = 'Already taken';
					} else {
						_currantDisplay.classes.remove('taken');
					}
					refresh();
				});
			}

			_currantNumDisplay.text = commaFormatter.format(lastMessage.currants);
			_currantDisplay.hidden = false;
		} else {
			// No currants sent with message
			_currantDisplay.hidden = true;
		}

		// Items
		for (int i = 0; i < lastMessage.items.length; i++) {
			String itemStr = lastMessage.items[i];
			Element itemBox = _fromItemBoxes[i];

			if (itemStr != null) {
				ItemDef item = ItemDef.fromJson(jsonDecode(itemStr));
				itemBox.style.backgroundImage = 'url(${item.iconUrl})';
				itemBox.hidden = false;

				if (lastMessage.itemsTaken[i]) {
					itemBox.classes.add('taken');
					itemBox.title = 'Already taken';
				} else {
					itemBox.onClick.listen((_) async {
						itemBox.classes.add('taken');
						HttpRequest request = await postRequest('collectItem',
							{'index': i + 1, 'id': lastMessage.id, 'to_user': lastMessage.to_user});
						if (request.responseText.trim() == 'Success') {
							itemBox.title = 'Already taken';
						} else {
							itemBox.classes.remove('taken');
						}
						refresh();
					});
				}
			} else {
				itemBox.hidden = true;
			}
		}

		// Mark message read
		switchToTab('read');
		await postRequest('readMail', lastMessage.toJson(), encode: false);
	}

	Future send() async {
		if (busy) {
			return;
		}

		busy = true;
		Mail message = new Mail();
		message.to_user = _inputTo.value;
		message.from_user = game.username;
		message.body = _inputMessage.value;
		message.subject = _inputSubject.value;

		try {
			message.currants = int.parse(_inputCurrants.value);
		} catch (_) {
			message.currants = 0;
		}

		message.item1_slot = itemSlots[0];
		message.item2_slot = itemSlots[1];
		message.item3_slot = itemSlots[2];
		message.item4_slot = itemSlots[3];
		message.item5_slot = itemSlots[4];

		HttpRequest request = await postRequest('sendMail', message.toJson(), encode: false);

		if (request.responseText == "OK") {
			// Clear sending fields (for next message)
			clearComposeView();
			switchToTab('inbox');
		}
		busy = false;
	}

	void reply() {
		if (busy) {
			return;
		}

		busy = true;
		_inputTo.value = lastMessage.from_user;
		_inputSubject.value = "Re: " + lastMessage.subject;
		switchToTab('compose');
		busy = false;
	}

	Future updateFriendsTypeahead() async {
		String sofar = _inputTo.value;
		if (sofar.length > 2) {
			String response = await HttpRequest.getString('${Configs.http}//${Configs.utilServerAddress}/friends/list/${game.username}');
			_toList.children.clear();
			jsonDecode(response).forEach((String username, bool online) {
				OptionElement option = new OptionElement()
					..value = username
					..text = (online ? 'Online' : 'Offline');
				_toList.append(option);
			});
		} else if (sofar.length == 0) {
			_toList.children.clear();
		}
	}

	ItemDef _decodeItemFromElement(Element element) {
		//verify it is a valid item before acting on it
		if (element.attributes['itemMap'] == null) {
			return null;
		}

		Map itemMap = jsonDecode(element.attributes['itemMap']);
		Map metadata = itemMap['metadata'];
		itemMap['metadata'] = {};

		ItemDef item = ItemDef.fromJson(itemMap);
		item.metadata = metadata;

		return item;
	}

	String _getSlotStringFromElement(Element element) {
		if (element.dataset['from-index'] == null) {
			return null;
		}
		return '${element.dataset['from-index']}.${element.dataset['from-bag-index']}';
	}
}

@JsonSerializable()
class Mail {
	Mail();
	factory Mail.fromJson(Map<String, dynamic> json) => _$MailFromJson(json);
	Map<String, dynamic> toJson() => _$MailToJson(this);

	int id, currants;
	String to_user, from_user, subject, body;
	bool read, currants_taken, item1_taken, item2_taken, item3_taken, item4_taken, item5_taken;
	String item1, item2, item3, item4, item5;
	String item1_slot, item2_slot, item3_slot, item4_slot, item5_slot;

	List<String> get items => [item1, item2, item3, item4, item5];

	List<bool> get itemsTaken => [item1_taken, item2_taken, item3_taken, item4_taken, item5_taken];

	TableRowElement display() {
		TableCellElement from = new TableCellElement()
			..classes = ['tbody_from']
			..text = this.from_user;

		TableCellElement subject = new TableCellElement()
			..classes = ['tbody_subject']
			..text = this.subject
			..onClick.listen((_) => windowManager.mailboxWindow.read(this.id));

		TableCellElement delete = new TableCellElement()
			..classes = ['tbody_delete']
			..append(new ButtonElement()
				..classes = ['btn-delete']
				..text = 'Delete'
				..onClick.listen((_) => this.delete()));

		TableRowElement row = new TableRowElement()
			..classes = ['inbox_message']
			..append(from)
			..append(subject)
			..append(delete);

		if (!read) {
			row.classes.add('unread');
		}

		return row;
	}

	Future delete({bool prompt: true}) async {
		if (prompt) {
			String question;

			if (!this.read) {
				question = "You haven't read this message yet.";
			} else if (this.hasValue) {
				question = "This message contains currants or items.";
			} else {
				delete(prompt: false);
				return;
			}

			question += " Are you sure you want to delete it?";

			// Let's make sure the user didn't forget to grab any currants/items
			if (window.confirm(question)) {
				delete(prompt: false);
			}
		} else {
			await MailboxWindow.postRequest('deleteMail', {'id': id});
			windowManager.mailboxWindow.refresh();
		}
	}

	bool get hasValue {
		if (this.currants > 0) {
			return true;
		}

		if (this.item1 != null && !this.item1_taken) {
			return true;
		}

		if (this.item2 != null && !this.item2_taken) {
			return true;
		}

		if (this.item3 != null && !this.item3_taken) {
			return true;
		}

		if (this.item4 != null && !this.item4_taken) {
			return true;
		}

		if (this.item5 != null && !this.item5_taken) {
			return true;
		}

		return false;
	}
}
