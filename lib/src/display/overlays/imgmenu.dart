part of couclient;

class ImgOverlay extends Overlay {

	// Level indicator bar ////////////////////////////////////////////////////////////////////////

	Element bar, levelNum, imgtonextE, nextlvlE, lifetimeImgE, tooltip;

	// Exit button ////////////////////////////////////////////////////////////////////////////////

	Element exitButton;

	// Set up everything on game load /////////////////////////////////////////////////////////////

	ImgOverlay(String id):super(id) {

		// Level indicator bar ////////////////////////////////////////////////////////////////////

		bar = querySelector("#pm-level-bar");
		levelNum = querySelector("#pm-level-num");
		imgtonextE = querySelector("#pm-img-req");
		nextlvlE = querySelector("#pm-next-lvlnum");
		lifetimeImgE = querySelector("#pm-lt-img");
		tooltip = querySelector("#pm-level-tooltip");

		// Exit button ////////////////////////////////////////////////////////////////////////////

		exitButton = querySelector("#pm-exit-button");

		// Key bindings ///////////////////////////////////////////////////////////////////////////

		setupKeyBinding("ImgMenu");
	}

	// Refresh every time it opens ////////////////////////////////////////////////////////////////

	@override
	open() async {

		// Set up level indicator bar /////////////////////////////////////////////////////////////

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

		// Set up exit button /////////////////////////////////////////////////////////////////////

		exitButton.onClick.first.then((_) => close());

		// Update toggle button state /////////////////////////////////////////////////////////////

		querySelector("#thinkButton").classes.add("pressed");

		// Hide the minimap ///////////////////////////////////////////////////////////////////////

		minimap.containerE.hidden = true;

		// Show the menu //////////////////////////////////////////////////////////////////////////

		super.open();

		transmit("worldFocus", false);
	}

	// Reset when closed //////////////////////////////////////////////////////////////////////////

	@override
	close() {

		// Update toggle button state /////////////////////////////////////////////////////////////

		querySelector("#thinkButton").classes.remove("pressed");

		// Hide the menu //////////////////////////////////////////////////////////////////////////

		super.close();

		// Re-show the minimap ////////////////////////////////////////////////////////////////////

		minimap.containerE.hidden = false;
	}
}

ImgOverlay imgMenu;