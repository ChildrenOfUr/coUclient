part of couclient;

class ItemWindow extends Modal {
	String id = 'itemWindow' + random.nextInt(9999999).toString(), itemName;
	static Map<String, ItemWindow> instances = {};

	String priceText, slotText, wearText;

	factory ItemWindow(String itemName) {
		if(instances[itemName] == null) {
			instances[itemName] = new ItemWindow._(itemName);
		} else {
			instances[itemName].open();
		}
		return instances[itemName];
	}

	ItemWindow._(this.itemName) {
		displayItem().then((Element el) {
			querySelector("#windowHolder").append(el);
			prepare();
			open();
		});
	}

	Future<Element> displayItem() async {
		String response = await HttpRequest.requestCrossOrigin(
			'http://' + Configs.utilServerAddress + '/getItems?name=' + itemName);
		Map<String, String> json = JSON.decode(response)[0];

		String title = json['name'];
		String image = json['iconUrl'];
		String desc = json['description'];
		int price = (json['price'] as int);
		int slot = (json['stacksTo'] as int);
		bool showWear;
		int wear;
		if(json['durability'] != null) {
			showWear = true;
			wear = (json['durability'] as int);
		} else {
			showWear = false;
		}
		int newImg = 0;

		if(price != -1) {
			if(price == 0) {
				// worthless
				priceText = 'This item is priceless.';
			} else if(price == 1) {
				// not plural
				priceText = 'This item sells for about <b>' + price.toString() + '</b> currant';
			} else {
				// plural
				priceText = 'This item sells for about <b>' + price.toString() + '</b> currants';
			}
		} else {
			priceText = 'Vendors will not buy this item';
		}

		slotText = 'Fits up to <b>' + slot.toString() + '</b> in a backpack slot';

		if(showWear) {
			wearText = 'Durable for about <b>' + wear.toString() + '</b> units of wear';
		}

		// // // // // // // // // // // // // // // // // // // // // // // // //

		DivElement wearIcon;
		SpanElement wearNum;

		// Header

		Element closeButton = new Element.tag("i")
			..classes.add("fa-li")
			..classes.add("fa")
			..classes.add("fa-times")
			..classes.add("close");

		Element icon = new Element.tag("i")
			..classes.add("fa-li")
			..classes.add("fa")
			..classes.add("fa-info-circle");

		SpanElement titleSpan = new SpanElement()
			..classes.add("iw-title")
			..text = title;

		Element header = new Element.header()
			..append(icon)
			..append(titleSpan);

		// Image (Left Column)

		ImageElement leftImage = new ImageElement()
			..classes.add("iw-image")
			..src = image;

		Element imageContainer = new DivElement()
			..classes.add('iw-image-container')
			..append(leftImage);

		// New Item Message (Left Column)

		ImageElement imgIcon = new ImageElement()
			..src = "../web/files/system/icons/interaction_img.svg";

		SpanElement imgAward = new SpanElement()
			..classes.add("img")
			..text = ""
			..append(imgIcon);

		ParagraphElement newItem = new ParagraphElement()
			..classes.add("iw-newItem")
			..text = "You discovered a new useful item!"
			..append(imgAward);

		DivElement left = new DivElement()
			..classes.add("iw-left")
			..append(imageContainer);

		if (newImg > 0) {
			left.append(newItem);
		}

		// Information (Right Column)

		ParagraphElement description = new ParagraphElement()
			..classes.add("iw-desc")
			..text = desc;

		// Price

		ImageElement currantIcon = new ImageElement()
			..classes.add("iw-icon-currants")
			..src = "../web/files/system/icons/currant.svg";

		SpanElement currantNum = new SpanElement()
			..classes.add("iw-currants")
			..innerHtml = priceText;

		// Fit in slot

		DivElement slotIcon = new DivElement()
			..classes.add("iw-icon-css")
			..classes.add("iw-icon-slot");

		SpanElement slotNum = new SpanElement()
			..innerHtml = slotText;

		// Wear

		if(json['durability'] != null) {
			showWear = true;

			wearIcon = new DivElement()
				..classes.add("iw-icon-css")
				..classes.add("iw-icon-wear");

			wearNum = new SpanElement()
				..innerHtml = wearText;
		} else {
			showWear = false;
		}

		DivElement meta = new DivElement()
			..classes.add("iw-meta")
			..append(currantIcon)
			..append(currantNum)
			..append(new BRElement())
			..append(slotIcon)
			..append(slotNum);

		if(showWear) {
			meta
				..append(new BRElement())
				..append(wearIcon)
				..append(wearNum);
		}

		DivElement right = new DivElement()
			..classes.add("iw-info")
			..append(description)
			..append(meta);

		// Container

		Element well = new Element.tag("ur-well")
			..append(left)
			..append(right);

		DivElement window = new DivElement()
			..id = id
			..classes.add("window")
			..classes.add("itemWindow")
			..append(closeButton)
			..append(header)
			..append(well);

		return(window);
	}

	@override
	close() {
		instances[itemName].modalWindow.hidden = true;
		super.close();
	}
}
