part of couclient;

class ImgOverlay extends Overlay {
	Element bar, levelNum, imgtonextE, nextlvlE, lifetimeImgE, tooltip;
	ImgOverlay(String id):super(id) {
		bar = querySelector("#pm-level-bar");
		levelNum = querySelector("#pm-level-num");
		imgtonextE = querySelector("#pm-img-req");
		nextlvlE = querySelector("#pm-next-lvlnum");
		lifetimeImgE = querySelector("#pm-lt-img");
		tooltip = querySelector("#pm-level-tooltip");
	}

	open() {
		if (metabolics.lifetime_img < 52184719) {
			// Calculate level/img stats
			int imgToward = metabolics.lifetime_img - metabolics.img_req_for_curr_lvl;
			int imgNeeded = metabolics.img_req_for_next_lvl - metabolics.lifetime_img;
			int section = metabolics.img_req_for_next_lvl - metabolics.img_req_for_curr_lvl;
			num percentOfNext = ((100 / section) * imgToward);
			if (percentOfNext < 25) {
				percentOfNext = 25;
			}

			// Display img bar
			bar.style.height = percentOfNext.toString() + '%';
			levelNum.text = metabolics.level.toString();
			imgtonextE.text = commaFormatter.format(imgNeeded);
			nextlvlE.text = (metabolics.level + 1).toString();
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

		overlay.hidden = false;
		querySelector("#thinkButton").classes.add("pressed");
		inputManager.ignoreKeys = true;
	}

	close() {
		overlay.hidden = true;
		querySelector("#thinkButton").classes.remove("pressed");
		inputManager.ignoreKeys = false;
	}
}

ImgOverlay imgMenu;