part of couclient;

class ShrineWindow extends Modal {
	static ShrineWindow shrineWindow;
	String id = 'shrineWindow', giantName;
	int favor, maxFavor;

	factory ShrineWindow(String giantName, int favor, int maxFavor) {
		if(shrineWindow == null) {
			shrineWindow = new ShrineWindow._(giantName,favor,maxFavor);
		}

		return shrineWindow;
	}

	ShrineWindow._(this.giantName,this.favor,this.maxFavor) {
		prepare();

		List<Element> insertGiantName = querySelectorAll(".insert-giantname").toList();
		insertGiantName.forEach((placeholder) => placeholder.text = giantName);

		int percent = favor ~/ maxFavor;
		Map<String, String> progressAttributes = {
			"percent": percent.toString(),
			"status": favor.toString() + " of " + maxFavor.toString() + " favor towards an Emblem of " + giantName
		};
		querySelector("#shrine-window-favor").attributes = progressAttributes;
	}
}