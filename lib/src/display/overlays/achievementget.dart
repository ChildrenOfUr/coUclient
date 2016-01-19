part of couclient;

class AchievementOverlay extends Overlay {
	Element overlay;
	String id;

	AchievementOverlay(Map achvData) : super("achv-template") {
		id = "achv-" + achvData["achv_id"];

		overlay = querySelector("#achv-template").clone(true);
		overlay
			..id = id
			..querySelector(".achv-name").text = achvData["achv_name"]
			..querySelector(".achv-desc").text = achvData["achv_description"]
			..querySelector(".achv-icon").style.backgroundImage = "url(${achvData["achv_imageUrl"]})";

		querySelector("#achv-template").parent.append(overlay);

		open();
	}

	open() {
		overlay.hidden = false;
		audio.playSound("levelUp");
		inputManager.ignoreKeys = true;
		overlay.querySelector(".closeButton").onClick.first.then((_) => close());
		transmit("worldFocus", false);
	}

	close() {
		super.close();
		overlay.remove();
	}
}