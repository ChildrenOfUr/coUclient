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
		new Service('questBegin', (Quest q) {
			_addQuestToList(q, questBegin: true);
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

		//if we aren't on any more quests, update the display to say so
		if(listOfQuests.children.length == 0) {
			displayElement.classes.add("noquests");
		}

	}

	void _addQuestToList(Quest q, {bool questBegin: false}) {
		//if it's already on the list, just update the details
		if (listOfQuests.querySelector("#${q.id}") != null) {
			questDetails.children.clear();
			questDetails.append(_newDetails(q));
			return;
		}

		LIElement newQuest = _newQuest(q);
		listOfQuests.append(newQuest);
		newQuest.onClick.listen((_) {
			listOfQuests.children.forEach((Element child) => child.classes.remove('selected'));
			newQuest.classes.add('selected');
			questDetails.children.clear();
			questDetails.append(_newDetails(q));
		});

		displayElement.classes.remove("noquests");

		//if this is a brand new quest, open the window
		//and highlight the quest
		if(questBegin) {
			open();
			newQuest.click();
		}
	}

	LIElement _newQuest(Quest q) {
		LIElement questE = new LIElement()
			..id = q.id
			..text = q.title
			..classes.add('activeQuest');

		return questE;
	}

	Element _newDetails(Quest q) {
		// Generate info box (for requirements & rewards)
		Element _infoBox({String imageUrl, String imageClass, dynamic text: ""}) {
			Element imageE;
			if (imageUrl != null) {
				imageE = new ImageElement(src: imageUrl);
			} else {
				imageE = new DivElement()
					..classes = (imageClass != null ? ["quest-info-icon", imageClass] : ["quest-info-icon"]);
			}

			SpanElement textE = new SpanElement()
				..text = text.toString();

			DivElement boxE = new DivElement()
				..append(imageE)
				..append(textE);

			return boxE;
		}

		// Containers

		// Completion requirements
		DivElement requirementsE = new DivElement()
			..classes = ["quest-reqs"]
			..append(new SpanElement()
				..text = "Requirements");

		// Completion rewards
		DivElement rewardsE = new DivElement()
			..classes = ["quest-rewards"]
			..append(new SpanElement()
				..text = "Rewards");

		// Description text
		DivElement descriptionE = new DivElement()
			..text = q.description
			..classes.add('questDescription');

		// Details container (parent of all above)
		DivElement detailsE = new DivElement()
			..dataset['quest-id'] = q.id
			..append(descriptionE)..append(requirementsE)..append(rewardsE);

		// Fill in requirements
		q.requirements.forEach((Requirement r) {
			DivElement reqE = _infoBox(imageUrl: r.iconUrl, text: "${r.numFulfilled}/${r.numRequired}")
				..classes.add("questRequirement")
				..title = r.text;

			if (r.fulfilled) {
				reqE.classes.add("fulfilled");
			}

			requirementsE.append(reqE);
		});

		// Fill in rewards
		if (q.rewards.currants > 0)
			rewardsE.append(_infoBox(imageClass: "currant", text: q.rewards.currants));
		if (q.rewards.energy > 0)
			rewardsE.append(_infoBox(imageClass: "energy", text: q.rewards.energy));
		if (q.rewards.img > 0)
			rewardsE.append(_infoBox(imageClass: "img", text: q.rewards.img));
		if (q.rewards.mood > 0)
			rewardsE.append(_infoBox(imageClass: "mood", text: q.rewards.mood));
		q.rewards.favor.forEach((QuestFavor giant) {
			if (giant.favAmt > 0)
				rewardsE.append(_infoBox(text: "${giant.favAmt} favor with ${giant.giantName}"));
		});

		return detailsE;
	}
}