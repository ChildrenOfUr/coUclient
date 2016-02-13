part of couclient;

class ItemWindow extends Modal {
	String id = 'itemWindow' + WindowManager.randomId.toString(),
		itemName;
	static Map<String, ItemWindow> instances = {};

	String priceText, slotText, wearText;

	factory ItemWindow(String itemName) {
		if (instances[itemName] == null) {
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
		ItemDef item = decode(response, type: const TypeHelper<List<ItemDef>>().type).first;

		int newImg = 0;

		if (item.price != -1) {
			if (item.price == 0) {
				// worthless
				priceText = 'This item is priceless.';
			} else if (item.price == 1) {
				// not plural
				priceText = 'This item sells for about <b>${item.price}</b> currant';
			} else {
				// plural
				priceText = 'This item sells for about <b>${item.price}</b> currants';
			}
		} else {
			priceText = 'Vendors will not buy this item';
		}

		slotText = 'Fits up to <b>${item.stacksTo}</b> in a backpack slot';

		if (item.durability != null) {
			wearText = 'Durable for about <b>${item.durability}</b> units of wear';
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
			..text = item.name;

		if (item.name.length >= 24) {
			titleSpan.style.fontSize = "24px";
		}

		Element header = new Element.header()
			..append(icon)..append(titleSpan);

		// Image (Left Column)

		ImageElement leftImage = new ImageElement()
			..classes.add("iw-image")
			..src = item.iconUrl;

		Element imageContainer = new DivElement()
			..classes.add('iw-image-container')
			..append(leftImage);

		// New Item Message (Left Column)

		ImageElement imgIcon = new ImageElement()
			..src = "files/system/icons/interaction_img.svg";

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
		DivElement right = new DivElement()
			..classes.add("iw-info");

		ParagraphElement description = new ParagraphElement()
			..classes.add("iw-desc")
			..text = item.description;

		right.append(description);

		//consume info
		if (item.consumeValues.isNotEmpty) {
			DivElement consumeValues = new DivElement()
				..className = 'cb-content';
			DivElement explain = new DivElement()
				..className = 'consume-explain'
				..text = "Rewards when consumed: ";

			SpanElement awarded = new SpanElement()
				..className = 'awarded';

			awarded.append(explain);
			consumeValues.append(awarded);

			List<String> metabolicRewards = ['energy','mood','img'];
			for(String reward in metabolicRewards) {
				if (item.consumeValues[reward] != null) {
					int amount = item.consumeValues[reward];
					String sign = amount >= 0 ? '+' : '-';
					SpanElement span = new SpanElement()
						..className = reward
						..text = '$sign$amount';

					awarded.append(span);
				}
			}

			right.append(consumeValues);
		}

		// Price

		ImageElement currantIcon = new ImageElement()
			..classes.add("iw-icon-currants")
			..src = "files/system/icons/currant.svg";

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

		DivElement meta = new DivElement()
			..classes.add("iw-meta")
			..append(currantIcon)..append(currantNum)..append(new BRElement())..append(slotIcon)..append(slotNum);

		if (item.durability != null) {
			wearIcon = new DivElement()
				..classes.add("iw-icon-css")
				..classes.add("iw-icon-wear");

			wearNum = new SpanElement()
				..innerHtml = wearText;

			meta..append(new BRElement())..append(wearIcon)..append(wearNum);
		}

		right.append(meta);

		// Container

		Element well = new Element.tag("ur-well")
			..append(left)..append(right);

		DivElement window = new DivElement()
			..id = id
			..classes.add("window")
			..classes.add("itemWindow")
			..append(closeButton)..append(header)..append(well);

		return (window);
	}

	@override
	close() {
		instances[itemName].displayElement.hidden = true;
		super.close();
	}
}
