part of couclient;

class ImgOverlay extends Overlay {
	Element bar, levelNum, imgtonextE, nextlvlE;
	ImgOverlay(String id):super(id) {
		bar = querySelector("#pm-level-bar");
		levelNum = querySelector("#pm-level-num");
		imgtonextE = querySelector("#pm-img-req");
		nextlvlE = querySelector("#pm-next-lvlnum");
	}

	open() {
		// Calculate level/img stats
		int imgToward = metabolics.lifetime_img - metabolics.img_req_for_curr_lvl;
		int imgNeeded = metabolics.img_req_for_next_lvl - imgToward;
		int section = metabolics.img_req_for_next_lvl - metabolics.img_req_for_curr_lvl;
		num percentOfNext = ((100 / section) * imgToward);
		if (percentOfNext < 25) {
			percentOfNext = 25;
		}

		print("LT iMG: " + metabolics.lifetime_img.toString());
		print("Current lvl iMG: " + metabolics.img_req_for_curr_lvl.toString());
		print("Next lvl iMG: " + metabolics.img_req_for_next_lvl.toString());
		print("Section width: " + section.toString());
		print("Collected iMG: " + imgToward.toString());
		print("Remaining iMG: " + imgNeeded.toString());
		print("Percent to next lvl: " + ((100 / section) * imgToward).toString());

		// Display img bar
		bar.style.height = percentOfNext.toString() + '%';
		levelNum.text = metabolics.level.toString();
		imgtonextE.text = commaFormatter.format(imgNeeded);
		nextlvlE.text = (metabolics.level + 1).toString();

		// Show
		overlay.hidden = false;
	}
}

Overlay imgMenu;