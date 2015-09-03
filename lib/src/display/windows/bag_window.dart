part of couclient;

class BagWindow extends Modal {

	static List<BagWindow> openWindows = [];

	static closeId(String id) {
		openWindows.where((BagWindow w) => w.id == id).first.close();
		openWindows.removeWhere((BagWindow w) => w.id == id);
	}

	String id = 'bagWindow' + random.nextInt(9999999).toString();
	String bagId;
	int numSlots;

	BagWindow(Map sourceItem) {
		DivElement windowElement = load(sourceItem);
		querySelector("#windowHolder").append(windowElement);
		prepare();
		open();
		openWindows.add(this);
	}

	DivElement load(Map sourceItem) {

		// Header

		Element icon = new Element.tag("i")
			..classes.add("fa-li")
			..classes.add("fa")
			..classes.add("fa-info-circle");

		SpanElement titleSpan = new SpanElement()
			..classes.add("iw-title")
			..text = sourceItem["name"];

		if (sourceItem["name"].length >= 24) {
			titleSpan.style.fontSize = "24px";
		}

		Element header = new Element.header()
			..append(icon)
			..append(titleSpan);

		// Content

		Element well = new Element.tag("ur-well");

		List<Map> subSlots = JSON.decode(sourceItem["metadata"]["slots"]);

		if (subSlots.length != sourceItem["subSlots"]) {
			throw new StateError("Number of slots in bag does not match bag size");
		} else {
			subSlots.forEach((Map itemInBag) {
				// Item
				DivElement itemInSlot = new DivElement()
					..classes.addAll(["item-${sourceItem["itemType"]}", "inventoryItem", "bagInventoryItem"])
					..attributes["name"] = sourceItem["name"]
					..attributes["count"] = sourceItem["count"].toString()
					..attributes["itemmap"] = JSON.encode(sourceItem);

				// Slot
				DivElement slot = new DivElement()
					..classes.add("box")
					..append(itemInSlot);

				well.append(slot);
			});
		}

		// Window

		DivElement window = new DivElement()
			..id = id
			..classes.add("window")
			..classes.add("itemWindow")
			..append(header)
			..append(well);

		return window;
	}
}