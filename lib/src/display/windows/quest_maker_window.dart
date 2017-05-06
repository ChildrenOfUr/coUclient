part of couclient;

class QuestMakerWindow extends Modal {
	static QuestMakerWindow _instance;
	String id = 'questMakerWindow';
	UListElement pieces;
	DivElement questSteps, imgInput, currantInput, questDescription;
	Element makeItButton;
	SpanElement imgTotal, currantTotal;
	Dropzone questStepsDrop, placedPieceDrop;
	int imgCost = 500,
		currantCost = 0,
		numSteps = 0;
	List<String> acceptStrings = [
		'You got it',
		'I\'m on it',
		'Sounds good',
		'Right away',
	];
	List<String> rejectStrings = [
		'Not right now',
		'Maybe later',
		'Let me think about it',
		'Soon, not now'
	];
	List<String> conversationEndStrings = [
		'Hey, ${game.username} wanted you to have this',
		'Great job, I\'m sure ${game.username} will be happy',
		'${game.username} left this for you',
		'Thanks for doing that. ${game.username} wanted you to have this'
	];

	factory QuestMakerWindow() {
		if (_instance == null) {
			_instance = new QuestMakerWindow._();
		}

		return _instance;
	}

	QuestMakerWindow._() {
		prepare();

		pieces = displayElement.querySelector('#pieces');
		questSteps = displayElement.querySelector('#questSteps');
		makeItButton = displayElement.querySelector('#makeItButton');
		imgTotal = makeItButton.querySelector('.img');
		currantTotal = makeItButton.querySelector('.currants');
		imgInput = displayElement.querySelector('#imgReward');
		currantInput = displayElement.querySelector('#currantsReward');
		questDescription = displayElement.querySelector('#questDescription');

		//update the cost to create when the fields are updated
		imgInput.onInput.listen((_) => _calculateCost());
		currantInput.onInput.listen((_) => _calculateCost());

		//make the quest item
		makeItButton.onClick.listen((_) => _makeIt());

		_createDropzone();
		_populatePieces();
		_calculateCost();
	}

	Future _makeIt() async {
		QuestRewards rewards = new QuestRewards()
			..currants = currantCost
			..img = imgCost;

		Conversation conversationStart = new Conversation()
			..screens = [
				new ConvoScreen()
					..paragraphs = [
						'Quest from ${game.username}',
						questDescription.text
					]
					..choices = [
						new ConvoChoice()
							..text = acceptStrings[random.nextInt(acceptStrings.length)]
							..isQuestAccept = true
							..gotoScreen = 2,
						new ConvoChoice()
							..text = rejectStrings[random.nextInt(rejectStrings.length)]
							..isQuestReject = true
							..gotoScreen = 2,
					]
			];

		Conversation conversationEnd = new Conversation()
			..screens = [
				new ConvoScreen()
					..paragraphs = [
						conversationEndStrings[random.nextInt(conversationEndStrings.length)]
					]
					..choices = [
						new ConvoChoice()
							..text = 'Thanks'
							..gotoScreen = 2
					]
			];

		Quest quest = new Quest();
		quest.id = game.email; //this will be changed on the server to be unique
		quest.description = questDescription.text;
		quest.rewards = rewards;
		quest.conversation_start = conversationStart;
		quest.conversation_end = conversationEnd;
		quest.title = 'A favor for ${game.username}';

		String url = '${Configs.http}//${Configs.utilServerAddress}/quest/createQuestItem';
		await HttpRequest.request(url, method: 'POST',
			                    requestHeaders: {'Content-Type':'application/json'},
			                    sendData: encode(quest)
		                    );
	}

	void _calculateCost() {
		//update the data values
		try {
			imgCost = int.parse(imgInput.text) + 300 * numSteps + 500;
		} catch (e) {
			imgCost = -1;
		}
		try {
			currantCost = int.parse(currantInput.text);
		} catch (e) {
			currantCost = -1;
		}

		//update the make it button display
		imgTotal.text = imgCost == -1 ? '?' : imgCost.toString();
		currantTotal.text = currantCost == -1 ? '?' : currantCost.toString();
	}

	Future _populatePieces() async {
		String url = '${Configs.http}//${Configs.utilServerAddress}/quest/pieces';
		Map<String,String> piecesMap = JSON.decode(await HttpRequest.getString(url));

		pieces.children.clear();

		for (String text in piecesMap.values) {
			LIElement piece = new LIElement()
				..className = 'questPiece'
				..text = text;

			pieces.append(piece);
		}

		new Draggable(displayElement.querySelectorAll('.questPiece'),
			              avatarHandler: new AvatarHandler.clone());
	}

	void _createDropzone() {
		questStepsDrop?.destroy();
		placedPieceDrop?.destroy();

		Element pieceSlot = querySelector('#questSteps .pieceSlot');
		if (pieceSlot != null) {
			questStepsDrop = new Dropzone(pieceSlot, acceptor: new QuestPieceAcceptor())
				..onDrop.listen((DropzoneEvent dropEvent) => _dropPiece(dropEvent));
		}

		placedPieceDrop = new Dropzone(querySelectorAll('#questSteps .placedPiece'),
			                               acceptor: new QuestPieceAcceptor())
			..onDrop.listen((DropzoneEvent dropEvent) => _dropPiece(dropEvent));
	}

	void _dropPiece(DropzoneEvent dropEvent) {
		if (dropEvent.dropzoneElement.classes.contains('placedPiece') &&
		    dropEvent.draggableElement.classes.contains('placedPiece')) {
			_swapElements(dropEvent.draggableElement, dropEvent.dropzoneElement);
		} else if (dropEvent.draggableElement.classes.contains('questPiece') &&
		           dropEvent.dropzoneElement.classes.contains('pieceSlot')) {
			//remove the pieceSlot placeholder
			questSteps.children.removeWhere((Element e) => e.classes.contains('pieceSlot'));

			//clone the thing we're dragging and append it to the list
			questSteps.append(_createStepElement(dropEvent));

			numSteps = questSteps.children.length;

			//add to the img cost of creating
			_calculateCost();

			//max of 5 steps
			if (numSteps < 5) {
				//create a new pieceSlot placeholder at the bottom of the list
				questSteps.append(new DivElement()
					                  ..className = 'pieceSlot');
				questSteps.scrollTop = questSteps.scrollHeight;
			}

			//tell everything to be a dropzone
			_createDropzone();
		}
	}

	void _deletePiece(Element piece) {
		piece.remove();
		if (questSteps.querySelector('.pieceSlot') == null) {
			//create a new pieceSlot placeholder at the bottom of the list
			questSteps.append(new DivElement()
				                  ..className = 'pieceSlot');
			numSteps = 4;

			_createDropzone();
		}

		_calculateCost();
	}

	Element _createStepElement(DropzoneEvent dropEvent) {
		DivElement pieceClone = new DivElement()
			..className = 'placedPiece'
			..text = dropEvent.draggableElement.text;

		Element pieceDelete = new Element.tag("i")
			..classes.add("fa")
			..classes.add("fa-times")
			..classes.add("pieceDelete");
		pieceDelete.onClick.first.then((MouseEvent e) => _deletePiece(pieceClone));
		pieceClone.append(pieceDelete);
		new Draggable(pieceClone, avatarHandler: new AvatarHandler.clone());
		return pieceClone;
	}

	void _swapElements(Element elm1, Element elm2) {
		var parent1 = elm1.parent;
		var next1 = elm1.nextElementSibling;
		var parent2 = elm2.parent;
		var next2 = elm2.nextElementSibling;

		parent1.insertBefore(elm2, next1);
		parent2.insertBefore(elm1, next2);
	}
}

class QuestPieceAcceptor extends Acceptor {
	@override
	bool accepts(Element draggableElement, int draggableId, Element dropzoneElement) {
		if (dropzoneElement.classes.contains('pieceSlot')) {
			return draggableElement.classes.contains('questPiece');
		} else {
			return draggableElement.classes.contains('placedPiece');
		}
	}
}