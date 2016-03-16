part of couclient;

class ImgOverlay extends Overlay {

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
	}

	@override
	open() async {
		// Prepare contents
		await _setupImgBar();
		await _setupSkillsList();

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
		await Skills.loadData();

		skillsList.children.clear();
		Element parent;

		if (Skills.data.length > 0) {
			Skills.data.forEach((Map<String, dynamic> skill) {
				Element progress = new DivElement()
					..classes = ["pm-skill-progress"]
					..style.width = "${(skill["player_points"] / skill["player_nextPoints"]) * 100}%";

				Element icon = new ImageElement(src: skill["player_iconUrl"])
					..classes = ["pm-skill-icon"];

				Element skillTitle = new SpanElement()
					..classes = ["pm-skill-title"]
					..text = skill["name"];

				Element skillLevel = new SpanElement()
					..classes = ["pm-skill-level"]
					..text = skill["player_level"].toString();

				Element text = new DivElement()
					..append(skillTitle)
					..append(skillLevel);

				parent = new DivElement()
					..classes = ["pm-skill"]
					..dataset["skill"] = skill["id"]
					..append(progress)
					..append(icon)
					..append(text);
			});
		} else {
			parent = new DivElement()
				..classes = ["pm-noskills"]
				..text = "No skills :(";
		}

		skillsList.append(parent);
	}
}

ImgOverlay imgMenu;