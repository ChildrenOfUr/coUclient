part of couclient;

class ImgOverlay extends Overlay {
	static final Duration update_frequency = new Duration(seconds: 5);
	String lastSkillsJson;

	// Level indicator bar
	Element bar = querySelector("#pm-level-bar"),
		levelNum = querySelector("#pm-level-num"),
		imgtonextE = querySelector("#pm-img-req"),
		nextlvlE = querySelector("#pm-next-lvlnum"),
		lifetimeImgE = querySelector("#pm-lt-img"),
		tooltip = querySelector("#pm-level-tooltip");

	// Skill container
	Element skillsList = querySelector("#pm-skills-list");

	// Exit button
	Element exitButton = querySelector("#pm-exit-button");

	ImgOverlay(String id):super(id) {
		setupKeyBinding("ImgMenu");

		// Repeatedly update
		new Service(["metabolicsUpdated"], (_) {
			if (elementOpen) {
				update();
			}
		});
	}

	Future update() async {
		await _setupImgBar();
		await _setupSkillsList();
	}

	@override
	open() async {
		// Prepare contents
		await update();

		// Update button states
		exitButton.onClick.first.then((_) => close());
		querySelector("#thinkButton").classes.add("pressed");

		// Update outside UI
		minimap.containerE.hidden = true;
		transmit("worldFocus", false);

		// Open
		super.open();
	}

	@override
	close() {
		// Update button states
		querySelector("#thinkButton").classes.remove("pressed");

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
			bar.style.height = percentOfNext.toString() + '%';
			levelNum.text = l_curr.toString();
			imgtonextE.text = commaFormatter.format(imgNeeded);
			nextlvlE.text = (l_curr + 1).toString();
			lifetimeImgE.text = commaFormatter.format(metabolics.lifetime_img);
			bar.classes.remove("done");
			tooltip.querySelector("#pm-tt-top").hidden = false;
			tooltip.classes.remove("done");
		} else {
			bar.classes.add("done");
			levelNum.text = "60";
			lifetimeImgE.text = commaFormatter.format(metabolics.lifetime_img);
			tooltip.querySelector("#pm-tt-top").hidden = true;
			tooltip.classes.add("done");
		}
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
				num levelPercent = ((skill["player_points"] / skill["player_nextPoints"]) * 100).clamp(0, 100);

				Element progress = new DivElement()
					..classes = ["pm-skill-progress"]
					..style.width = "calc($levelPercent% - 20px)"
					..style.backgroundImage = "url(${skill["player_iconUrl"]})";

				String levelText = skill["player_level"].toString();
				if (skill["player_level"] == 0) {
					levelText = "Learning";
				} else if (skill["player_level"] == skill["num_levels"]) {
					levelText = "Complete!";
					progress.classes.add("pm-skill-progress-complete");
				}

				Element icon = new ImageElement(src: skill["player_iconUrl"])
					..classes = ["pm-skill-icon"];

				Element skillTitle = new SpanElement()
					..classes = ["pm-skill-title"]
					..text = skill["name"];

				Element skillLevel = new SpanElement()
					..classes = ["pm-skill-level"]
					..text = '$levelText (${levelPercent.toInt()}%)';

				Element text = new DivElement()
					..append(skillTitle)
					..append(skillLevel);

				parent = new DivElement()
					..classes = ["pm-skill"]
					..dataset["skill"] = skill["id"]
					..title = skill["player_description"]
					..append(progress)
					..append(icon)
					..append(text);

				skillsList.append(parent);
			});
		} else {
			parent = new DivElement()
				..classes = ["pm-noskills"]
				..text = "No skills :(";

			skillsList.append(parent);
		}
	}
}

ImgOverlay imgMenu;
