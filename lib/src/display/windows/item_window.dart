part of couclient;

class ItemWindow extends Modal {
  String id = 'itemWindow';
  int itemId = 0;
  Element titleE = querySelector("#iw-title");
  Element imageE = querySelector("#iw-image");
  Element descE = querySelector("#iw-desc");
  Element priceE = querySelector("#iw-currants");
  Element slotE = querySelector("#iw-slot");
  Element imgnumE = querySelector("#iw-imgnum");
  Element discoverE = querySelector("#iw-newItem");
  String title = 'Meat';
  String image = 'http://placehold.it/200x200';
  String desc = "A simple meat.";
  int price = 10;
  int slot = 60;
  int newImg = 0;

  ItemWindow() {
    prepare();

    titleE.text = title;
    imageE.setAttribute('src', image);
    descE.text = desc;
    if (price != -1) {
      priceE.setInnerHtml('This item sells for about <b>' + price.toString() + '</b> currants');
    } else {
      priceE.text = 'Vendors will not buy this item';
    }
    slotE.setInnerHtml('Fits up to <b>' + slot.toString() + '</b> in a backpack slot');
    if (newImg > 0) {
      discoverE.style.display = 'block';
      imgnumE.text = '+' + newImg.toString();
    } else {
      discoverE.style.display = 'none';
    }
  }
}