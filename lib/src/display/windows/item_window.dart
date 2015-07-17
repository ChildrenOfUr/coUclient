part of couclient;

class ItemWindow extends Modal {
  String id = 'itemWindow';
  Map<String, ItemWindow> instances = {};

  Element titleE = querySelector(".iw-title");
  Element imageE = querySelector(".iw-image");
  Element descE = querySelector(".iw-desc");
  Element priceE = querySelector(".iw-currants");
  Element slotE = querySelector(".iw-slot");
  Element imgnumE = querySelector(".iw-imgnum");
  Element discoverE = querySelector(".iw-newItem");
  Element wearContainer = querySelector(".iw-wear-container");
  Element wearE = querySelector(".iw-wear");

  factory ItemWindow(String itemName) {
    if (instances[itemName] == null) {
	    Map<String, ItemWindow> adding = {itemName: new ItemWindow(itemName)};
	    instances.addAll(adding);
    }
    return instances[itemName];
  }

  ItemWindow._(itemName) {
    prepare();
    displayItem(itemName).whenComplete((Element el) {
	    querySelector("#windowHolder").append(el);
    });

  }

  Future<Element> displayItem(itemName) async {
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

    if (price != -1) {
      if (price == 0) {
        // worthless
        priceE.setInnerHtml('This item is priceless.');
      } else if (price == 1) {
        // not plural
        priceE.setInnerHtml('This item sells for about <b>' +
            price.toString() +
            '</b> currant');
      } else {
        // plural
        priceE.setInnerHtml('This item sells for about <b>' +
            price.toString() +
            '</b> currants');
      }
    } else {
      priceE.text = 'Vendors will not buy this item';
    }

    slotE.setInnerHtml(
        'Fits up to <b>' + slot.toString() + '</b> in a backpack slot');

    if (newImg > 0) {
      discoverE.style.display = 'block';
      imgnumE.text = '+' + newImg.toString();
    } else {
      discoverE.style.display = 'none';
    }

    if (showWear) {
      wearContainer.hidden = false;
      wearE.setInnerHtml(
          'Durable for about <b>' + wear.toString() + '</b> units of wear');
    } else {
      wearContainer.hidden = true;
    }

	  // // // // // // // // // // // // // // // // // // // // // // // // //

    bool showWear;
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

    SpanElement title = new SpanElement()
	    ..classes.add("iw-title")
	    ..text = itemName;

    Element header = new Element.header()..append(icon)..append(title);

    // Image (Left Column)

    ImageElement image = new ImageElement()..classes.add("iw-image");

    Element imageContainer = new DivElement()
	    ..classes.add('iw-image-container')
	    ..append(image);

    // New Item Message (Left Column)

    ImageElement imgIcon = new ImageElement()
	    ..src = "../system/icons/interaction_img.svg";

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
	    ..append(imageContainer)
	    ..append(newItem);

    // Information (Right Column)

    ParagraphElement description = new ParagraphElement()
	    ..classes.add("iw-desc")
	    ..text = desc;

    // Price

    ImageElement currantIcon = new ImageElement()
	    ..classes.add("iw-icon-currants")
	    ..src = "../system/icons/currant.svg";

    SpanElement currantNum = new SpanElement()
	    ..classes.add("iw-currants")
	    ..text = price.toString();

    // Fit in slot

    DivElement slotIcon = new DivElement()
	    ..classes.add("iw-icon-css")
	    ..classes.add("iw-icon-slot");

    DivElement slotNum = new DivElement()..text = slot.toString();

    // Wear

    if (json['durability'] != null) {
	    showWear = true;

	    wearIcon = new DivElement()
		    ..classes.add("iw-icon-css")
		    ..classes.add("iw-icon-wear");

	    wearNum = new SpanElement()..text = (json['durability'] as String);
    } else {
	    showWear = false;
    }

    DivElement meta = new DivElement()
	    ..classes.add("iw-meta")
	    ..append(currantIcon)
	    ..append(currantNum)
	    ..append(slotIcon)
	    ..append(slotNum);

    if (showWear) {
	    meta..append(wearIcon)..append(wearNum);
    }

    DivElement right = new DivElement()
	    ..classes.add("iw-info")
	    ..append(description)
	    ..append(meta);

    // Container

    Element well = new Element.tag("ur-well")..append(left)..append(right);

    DivElement window = new DivElement()
	    ..classes.add("itemWindow")
	    ..classes.add("window")
	    ..append(closeButton)
	    ..append(header)
	    ..append(well);

    return(window);
  }

  open() {}

  close() {}
}
