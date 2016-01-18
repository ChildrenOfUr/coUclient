part of couclient;

class QuestLogWindow extends Modal {
	String id = 'questLogWindow';
	DivElement listOfQuests, questDetails;

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
		listOfQuests.querySelector('#${q.id}')?.remove();
		questDetails.querySelector('[data-quest-id="${q.id}"')?.remove();
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
			DivElement requirementE = new DivElement();

			SpanElement completed = new SpanElement()
				..text = '${r.numFulfilled}/${r.numRequired}'
				..classes.add('requirementCompletion');

			SpanElement requirementText = new SpanElement()
				..text = '${r.text}'
				..classes.add('requirementDescription');

			requirementE.append(completed);
			requirementE.append(requirementText);

			detailsE.append(requirementE);
		});

		return detailsE;
	}
}