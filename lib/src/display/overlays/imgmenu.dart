part of couclient;

class ImgOverlay extends Overlay {
	static final Duration update_frequency = new Duration(seconds: 5);

	String lastSkillsJson;

	// Level indicator bar
	Element levelContainer = querySelector('#pm-level-container');
	Element levelBar = querySelector('#pm-level-bar');
	Element levelNum = querySelector('#pm-level-num');
	Element nextlvlE = querySelector('#pm-next-lvlnum');
	Element levelTooltip = querySelector('#pm-level-tooltip');
	Element imgtonextE = querySelector('#pm-img-req');
	Element lifetimeImgE = querySelector('#pm-lt-img');

	// Quoin limit meter
	Element quoinContainer = querySelector('#pm-quoinlimit-container');
	Element quoinBar = querySelector('#pm-quoinlimit-bar');
	Element quoinPercentE = querySelector('#pm-quoinlimit-num');
	Element quoinTooltip = querySelector('#pm-quoinlimit-tooltip');
	Element quoinLimitE = querySelector('#pm-quoins-limit');
	Element quoinsCollectedE = querySelector('#pm-quoins-collected');
	Element quoinsRemainingE = querySelector('#pm-quoins-remaining');

	// Skill container
	Element skillsList = querySelector('#pm-skills-list');

	// Exit button
	Element exitButton = querySelector('#pm-exit-button');

	ImgOverlay(String id) : super(id) {
		setupKeyBinding('ImgMenu');

		// Show level tooltip on hover
		levelContainer
			..onMouseEnter.listen((_) => levelTooltip.style.opacity = '1')
			..onMouseLeave.listen((_) => levelTooltip.style.opacity = '0');

		// Show quoin tooltip on hover
		quoinContainer
			..onMouseEnter.listen((_) => quoinTooltip.style.opacity = '1')
			..onMouseLeave.listen((_) => quoinTooltip.style.opacity = '0');

		// Repeatedly update
		new Service(['metabolicsUpdated'], (_) {
			if (elementOpen) {
				update();
			}
		});
	}

	Future update() async {
		await Future.wait([
			_setupImgBar(),
			_setupQuoinLimitMeter(),
			_setupSkillsList()
		]);
	}

	@override
	open() async {
		// Prepare contents
		await update();

		// Update button states
		exitButton.onClick.first.then((_) => close());
		querySelector('#thinkButton').classes.add('pressed');

		// Update outside UI
		minimap.containerE.hidden = true;
		transmit('worldFocus', false);

		// Open
		super.open();
	}

	@override
	close() {
		// Update button states
		querySelector('#thinkButton').classes.remove('pressed');

		// Close
		super.close();

		// Update outside UI
		minimap.containerE.hidden = false;
	}

	Future _setupImgBar() async {
		// Refresh from server
		int l_curr = await metabolics.level;

		if (l_curr < 60) {
			// Calculate level/img stats

			int l_imgCurr = await metabolics.img_req_for_curr_lvl;
			int l_imgNext = await metabolics.img_req_for_next_lvl;

			int imgToward = metabolics.lifetime_img - l_imgCurr;
			int imgNeeded = l_imgNext - metabolics.lifetime_img;
			int section = l_imgNext - l_imgCurr;
			num percentOfNext = ((100 / section) * imgToward);
			if (percentOfNext < 25) percentOfNext = 25;

			// Display img bar
			levelBar.style.height = percentOfNext.toString() + '%';
			levelNum.text = l_curr.toString();
			imgtonextE.text = commaFormatter.format(imgNeeded);
			nextlvlE.text = (l_curr + 1).toString();
			lifetimeImgE.text = commaFormatter.format(metabolics.lifetime_img);
			levelBar.classes.remove('done');
			levelTooltip.querySelector('.pm-tt-top').hidden = false;
			levelTooltip.classes.remove('done');
		} else {
			levelBar.classes.add('done');
			levelNum.text = '60';
			lifetimeImgE.text = commaFormatter.format(metabolics.lifetime_img);
			levelTooltip.querySelector('.pm-tt-top').hidden = true;
			levelTooltip.classes.add('done');
		}
	}

	Future _setupQuoinLimitMeter() async {
		int quoinsCollected = metabolics.playerMetabolics.quoinsCollected;
		int remaining = constants.quoinLimit - quoinsCollected;
		int percentCollected = ((quoinsCollected / constants.quoinLimit) * 100).ceil();

		quoinsCollectedE.text = quoinsCollected.toString() + ' quoin${quoinsCollected == 1 ? '' : 's'}';
		quoinLimitE.text = constants.quoinLimit.toString() + ' quoin${constants.quoinLimit == 1 ? '' : 's'}';
		quoinsRemainingE.text = remaining.toString() + ' quoin${remaining == 1 ? '' : 's'}';
		quoinPercentE.text = percentCollected.toString();
		quoinBar.style.height = percentCollected.clamp(25, 100).toString() + '%';
	}

	Future _setupSkillsList() async {
		// Refresh from server
		String newJson = await Skills.loadData();

		if (lastSkillsJson != null && lastSkillsJson == newJson) {
			// Don't re-render the skills elements if the data hasn't changed
			return;
		} else {
			lastSkillsJson = newJson;
		}

		skillsList.children.clear();
		Element parent;

		if (Skills.data.length > 0) {
			Skills.data.forEach((Map<String, dynamic> skill) {
				num levelPercent = ((skill['player_points'] / skill['player_nextPoints']) * 100).clamp(0, 100);

				Element progress = new DivElement()
					..classes = ['pm-skill-progress']
					..style.width = 'calc($levelPercent% - 20px)'
					..style.backgroundImage = 'url(${skill['player_iconUrl']})';

				String levelText = skill['player_level'].toString();
				if (skill['player_level'] == 0) {
					levelText = 'Learning';
				} else if (skill['player_level'] == skill['num_levels']) {
					levelText = 'Complete!';
					progress.classes.add('pm-skill-progress-complete');
				}

				Element icon = new ImageElement(src: skill['player_iconUrl'])
					..classes = ['pm-skill-icon'];

				Element skillTitle = new SpanElement()
					..classes = ['pm-skill-title']
					..text = skill['name'];

				Element skillLevel = new SpanElement()
					..classes = ['pm-skill-level']
					..text = levelText + (levelPercent != 100 ? ' (${levelPercent.toInt()}%)' : '');
					// ^ display percent of level if not complete ^

				Element text = new DivElement()
					..append(skillTitle)
					..append(skillLevel);

				parent = new DivElement()
					..classes = ['pm-skill']
					..dataset['skill'] = skill['id']
					..title = skill['player_description']
					..append(progress)
					..append(icon)
					..append(text);

				skillsList.append(parent);
			});
		} else {
			parent = new DivElement()
				..classes = ['pm-noskills']
				..text = 'No skills :(';

			skillsList.append(parent);
		}
	}
}

ImgOverlay imgMenu;
