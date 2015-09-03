part of couclient;

findNewSlot(Element item, Map map, ImageElement img) {
  bool found = false;
  Map i = map['item'];

  //find first free item slot
  for (Element barSlot in view.inventory.children) {
    if (barSlot.children.length == 0) {
      String cssName = i['itemType'].replaceAll(" ", "_");
      item = new DivElement();

      //determine what we need to scale the sprite image to in order to fit
      num scale = 1;
      if (img.height > img.width / i['iconNum']) {
        scale = (barSlot.contentEdge.height - 10) / img.height;
      } else {
        scale = (barSlot.contentEdge.width - 10) / (img.width / i['iconNum']);
      }

      item.style.width = (barSlot.contentEdge.width - 10).toString() + "px";
      item.style.height = (barSlot.contentEdge.height - 10).toString() + "px";
      item.style.backgroundImage = 'url(${i['spriteUrl']})';
      item.style.backgroundRepeat = 'no-repeat';
      item.style.backgroundSize = "${img.width * scale}px ${img.height * scale}px";
      item.style.backgroundPosition = "0 50%";
      item.style.margin = "auto";
      item.className = 'item-$cssName inventoryItem';

      item.attributes['name'] = i['name'].replaceAll(' ', '');
      item.attributes['count'] = "1";
      item.attributes['itemMap'] = JSON.encode(i);

      item.onContextMenu.listen((MouseEvent event) {
        List<List> actions = [];
        if (i['actions'] != null) {
          List<Action> actionsList = decode(JSON.encode(i['actions']), type: const TypeHelper<List<Action>>().type);
          bool enabled = false;
          actionsList.forEach((Action action) {
            String error = "";
            List<Map> requires = [];
            action.itemRequirements.all.forEach((String item, int num) => requires.add({'num':num, 'of':[item]}));
            if (action.itemRequirements.any.length > 0) {
              requires.add({'num':1, 'of':action.itemRequirements.any});
            }
            enabled = hasRequirements(requires);
            if (enabled) {
              error = action.description;
            } else {
              error = getRequirementString(requires);
            }
            actions.add([
              capitalizeFirstLetter(action.name) + '|' +
              action.name + '|${action.timeRequired}|$enabled|$error',
              i['itemType'],
              "sendAction ${action.name} ${i['id']}",
              getDropMap(i, 1)
            ]);
          });
        }
        Element menu = RightClickMenu.create(event, i['name'], i['description'], actions, itemName: i['name']);
        document.body.append(menu);
      });
      barSlot.append(item);

      item.classes.add("bounce");
      //remove the bounce class so that it's not still there for a drag and drop event
      //also enable bag opening at this time
      new Timer(new Duration(seconds: 1), () {
        item.classes.remove("bounce");

        // Containers
        DivElement containerButton;
        String bagWindowId;
        if (i["isContainer"] == true) {
          containerButton = new DivElement()
            ..classes.addAll(["fa", "fa-fw", "fa-plus", "item-container-toggle", "item-container-closed"])
            ..onClick.listen((_) {
            if (containerButton.classes.contains("item-container-closed")) {
              // Container is closed, open it

              // Open the bag window
              bagWindowId = new BagWindow(i).id;

              // Update the button
              containerButton.classes
                ..remove("item-container-closed")
                ..remove("fa-plus")
                ..add("item-container-open")
                ..add("fa-times");

              // Disable the bag until it is closed again
              item.classes.add("inv-item-disabled");
            } else {
              // Container is open, close it

              // Close the bag window
              BagWindow.closeId(bagWindowId);

              // Update the button
              containerButton.classes
                ..remove("item-container-open")
                ..remove("fa-times")
                ..add("item-container-closed")
                ..add("fa-plus");

              // Enable the bag until it is opened
              item.classes.remove("inv-item-disabled");
            }
          });
          item.parent.append(containerButton);
        }
      });

      found = true;
      break;
    }
  }

  //there was no space in the player's pack, drop the item on the ground instead
  if (!found) {
    sendAction("drop", i['itemType'], getDropMap(i, 1));
  }
}

void putInInventory(ImageElement img, Map map) {
  Map i = map['item'];
  String name = i['itemType'];
  int stacksTo = i['stacksTo'];
  Element item;
  bool found = false;

  String cssName = name.replaceAll(" ", "_");
  for (Element item in view.inventory.querySelectorAll(".item-$cssName")) {
    int count = int.parse(item.attributes['count']);

    if (count < stacksTo) {
      count++;
      int offset = count;
      if (i['iconNum'] != null && i['iconNum'] < count) {
        offset = i['iconNum'];
      }

      item.style.backgroundPosition = "calc(100% / ${i['iconNum'] - 1} * ${offset - 1}";
      item.attributes['count'] = count.toString();

      Element itemCount = item.parent.querySelector(".itemCount");
      if (itemCount != null) {
        itemCount.text = count.toString();
      }
      else {
        SpanElement itemCount = new SpanElement()
          ..text = count.toString()
          ..className = "itemCount";
        item.parent.append(itemCount);
      }

      found = true;
      break;
    }
  }
  if (!found) {
    findNewSlot(item, map, img);
  }
}

void addItemToInventory(Map map) {
  ImageElement img = new ImageElement(src: map['item']['spriteUrl']);
  img.onLoad.first.then((_) {
    //do some fancy 'put in bag' animation that I can't figure out right now
    //animate(img,map).then((_) => putInInventory(img,map));

    putInInventory(img, map);
  });
}

void subtractItemFromInventory(Map map) {
  String cssName = map['itemType'].replaceAll(" ", "_");
  int remaining = map['count'];
  for (Element item in view.inventory.querySelectorAll(".item-$cssName")) {
    if (remaining < 1) break;

    int count = int.parse(item.attributes['count']);
    if (count > map['count']) {
      item.attributes['count'] = (count - map['count']).toString();
      item.parent
      .querySelector('.itemCount').text = (count - map['count']).toString();
    } else item.parent.children.clear();

    remaining -= count;
  }
}

Map getDropMap(Map item, int count) {
  Map dropMap = new Map()
    ..['dropItem'] = item
    ..['count'] = count
    ..['x'] = CurrentPlayer.posX
    ..['y'] = CurrentPlayer.posY + CurrentPlayer.height / 2
    ..['streetName'] = currentStreet.label
    ..['tsid'] = currentStreet.streetData['tsid'];

  return dropMap;
}