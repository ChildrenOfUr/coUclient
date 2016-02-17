part of couclient;

class QuestMakerWindow extends Modal {
	static QuestMakerWindow _instance;
	String id = 'questMakerWindow';
	UListElement pieces;
	DivElement questSteps;
	Dropzone questStepsDrop, placedPieceDrop;

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

		_createDropzone();
		_populatePieces();
	}

	Future _populatePieces() async {
		//in the future, we'll get this list from the server

		pieces.children.clear();

		for (int i = 0; i < 10; i++) {
			LIElement piece = new LIElement()
				..className = 'questPiece'
				..text = 'This is piece $i';

			pieces.append(piece);
		}

		new Draggable(displayElement.querySelectorAll('.questPiece'),
			              avatarHandler: new AvatarHandler.clone());
	}

	void _createDropzone() {
		questStepsDrop?.destroy();
		placedPieceDrop?.destroy();

		questStepsDrop = new Dropzone(querySelector('#questSteps .pieceSlot'),
			                            acceptor: new QuestPieceAcceptor())
			..onDrop.listen((DropzoneEvent dropEvent) => _dropPiece(dropEvent));

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

			//create a new pieceSlot placeholder at the bottom of the list
			questSteps.append(new DivElement()
				                ..className = 'pieceSlot');
			questSteps.scrollTop = questSteps.scrollHeight;

			//tell everything to be a dropzone
			_createDropzone();
		}
	}

	Element _createStepElement(DropzoneEvent dropEvent) {
		DivElement pieceClone = new DivElement()
			..className = 'placedPiece'
			..text = dropEvent.draggableElement.text;

		Element pieceDelete = new Element.tag("i")
			..classes.add("fa")
			..classes.add("fa-times")
			..classes.add("pieceDelete");
		pieceDelete.onClick.first.then((_) => pieceClone.remove());
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
		if(dropzoneElement.classes.contains('pieceSlot')) {
			return draggableElement.classes.contains('questPiece');
		} else {
			return draggableElement.classes.contains('placedPiece');
		}
	}
}