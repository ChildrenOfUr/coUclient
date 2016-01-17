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

		setupUiButton(querySelector('#questLogButton'));
		setupKeyBinding("QuestLog");
	}

	void _removeQuestFromList(Quest q) {
		listOfQuests.querySelector('#${q.id}')?.remove();
		questDetails.querySelector('[data-quest-id="${q.id}"')?.remove();
	}

	void _addQuestToList(Quest q) {
		//remove the quest if it already exists
		_removeQuestFromList(q);

		DivElement newQuest = _newQuest(q);
		listOfQuests.append(newQuest);
		newQuest.onClick.listen((_) {
			questDetails.children.clear();
			questDetails.append(_newDetails(q));
		});
	}

	Element _newQuest(Quest q) {
		DivElement questE = new DivElement()
			..id = q.id
			..text = q.title;

		return questE;
	}

	Element _newDetails(Quest q) {
		DivElement detailsE = new DivElement()
			..text = q.description
			..dataset['quest-id'] = q.id;

		q.requirements.forEach((Requirement r) {
			DivElement requirementE = new DivElement();

			SpanElement completed = new SpanElement()
				..text = '${r.numFulfilled}/${r.numRequired}';

			SpanElement requirementText = new SpanElement()
				..text = '${r.text}';

			requirementE.append(completed);
			requirementE.append(requirementText);

			detailsE.append(requirementE);
		});

		return detailsE;
	}
}