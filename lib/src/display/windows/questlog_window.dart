part of couclient;

class QuestLogWindow extends Modal {
	String id = 'questLogWindow';
	DivElement questDetails;
	UListElement listOfQuests;

	QuestLogWindow() {
		prepare();
		listOfQuests = querySelector('#listOfQuests');
		questDetails = querySelector('#questDetails');

		new Service(['questInProgress', 'questUpdate'], (Quest q) {
			_addQuestToList(q);
		});
		new Service('questComplete', (Quest q) {
			_removeQuestFromList(q);
		});

		setupUiButton(querySelector('#open-quests'));
		setupKeyBinding("QuestLog");
	}

	void _removeQuestFromList(Quest q) {
		if (listOfQuests.querySelector("#${q.id}") != null) {
			listOfQuests.querySelector('#${q.id}').remove();
		}

		if (questDetails.querySelector('[data-quest-id="${q.id}"]') != null) {
			questDetails.querySelector('[data-quest-id="${q.id}"]').remove();
		}
	}

	void _addQuestToList(Quest q) {
		//remove the quest if it already exists
		_removeQuestFromList(q);

		LIElement newQuest = _newQuest(q);
		listOfQuests.append(newQuest);
		newQuest.onClick.listen((_) {
			listOfQuests.children.forEach((Element child) => child.classes.remove('selected'));
			newQuest.classes.add('selected');
			questDetails.children.clear();
			questDetails.append(_newDetails(q));
		});

		super.displayElement.classes.remove("noquests");
	}

	LIElement _newQuest(Quest q) {
		LIElement questE = new LIElement()
			..id = q.id
			..text = q.title
			..classes.add('activeQuest');

		return questE;
	}

	Element _newDetails(Quest q) {
		DivElement detailsE = new DivElement()
			..dataset['quest-id'] = q.id;

		DivElement descriptionE = new DivElement()
			..text = q.description
			..classes.add('questDescription');

		detailsE.append(descriptionE);

		q.requirements.forEach((Requirement r) {
			DivElement requirementE = new DivElement()
				..classes.add("questRequirement");

			if (r.fulfilled) {
				requirementE.classes.add("fulfilled");
			}

			Element icon = new ImageElement()
				..src = r.iconUrl;

			SpanElement completed = new SpanElement()
				..text = '${r.numFulfilled}/${r.numRequired}'
				..classes.add('requirementCompletion');

			requirementE
				..append(icon)
				..append(completed)
				..title = r.text;

			detailsE.append(requirementE);
		});

		return detailsE;
	}
}