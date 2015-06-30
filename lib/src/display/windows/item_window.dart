part of couclient;

class ItemWindow extends Modal {
	String id = 'itemWindow';
	static ItemWindow instance;

	Element titleE = querySelector("#iw-title");
	Element imageE = querySelector("#iw-image");
	Element descE = querySelector("#iw-desc");
	Element priceE = querySelector("#iw-currants");
	Element slotE = querySelector("#iw-slot");
	Element imgnumE = querySelector("#iw-imgnum");
	Element discoverE = querySelector("#iw-newItem");
  Element wearContainer = querySelector("#iw-wear-container");
  Element wearE = querySelector("#iw-wear");

	factory ItemWindow() {
		if(instance == null) {
			instance = new ItemWindow._();
		}

		return instance;
	}

	ItemWindow._() {
		prepare();
	}

	displayItem(itemName) async {
		String response = await HttpRequest.requestCrossOrigin('http://' + Configs.utilServerAddress + '/getItems?name=' + itemName);
		Map<String, String> json = JSON.decode(response)[0];

		String title = json['name'];
		String image = json['iconUrl'];
		String desc = json['description'];
		int price = (json['price'] as int);
		int slot = (json['stacksTo'] as int);
    bool showWear;
    int wear;
    if (json['durability'] != null) {
      showWear = true;
      wear = (json['durability'] as int);
    } else {
      showWear = false;
    }
		int newImg = 0;

		titleE.text = title;
		imageE.setAttribute('src', image);
		descE.text = desc;

		if(price != -1) {
      if (price == 1) {
        // not plural
        priceE.setInnerHtml('This item sells for about <b>' + price.toString() + '</b> currant');
      } else {
        // plural
        priceE.setInnerHtml('This item sells for about <b>' + price.toString() + '</b> currants');
      }
		} else {
			priceE.text = 'Vendors will not buy this item';
		}

		slotE.setInnerHtml('Fits up to <b>' + slot.toString() + '</b> in a backpack slot');

		if(newImg > 0) {
			discoverE.style.display = 'block';
			imgnumE.text = '+' + newImg.toString();
		} else {
			discoverE.style.display = 'none';
		}

    if (showWear) {
      wearContainer.hidden = false;
      wearE.setInnerHtml('Durable for about <b>' + wear.toString() + '</b> units of wear');
      descE.classes.add('withWear');
    } else {
      wearContainer.hidden = true;
      descE.classes.remove('withWear');
    }

		this.open();
	}
}