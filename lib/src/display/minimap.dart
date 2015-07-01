part of couclient;

class Minimap {
  DivElement containerE, objectsE, labelE;
  ImageElement imageE;
  Element toggleE;
  bool collapsed = false;
  List<Map> currentStreetExits = new List();
  String mainImgUrl, loadingImgUrl;

  Minimap() {
    containerE = querySelector("#minimap-container");
    imageE = querySelector("#minimap-img");
    objectsE = querySelector("#minimap-objects");
    labelE = querySelector("#minimap-label");
    toggleE = querySelector("#minimap-toggle");

    toggleE.onClick.listen((_) {
      if (collapsed) {
        expand();
      } else {
        collapse();
      }
    });
  }

  void collapse() {
    imageE.src = loadingImgUrl;
    objectsE.hidden = true;
    toggleE.querySelector('i.fa').classes.remove('fa-chevron-up');
    toggleE.querySelector('i.fa').classes.add('fa-chevron-down');
    collapsed = true;
  }

  void expand() {
    imageE.src = mainImgUrl;
    objectsE.hidden = false;
    toggleE.querySelector('i.fa').classes.remove('fa-chevron-down');
    toggleE.querySelector('i.fa').classes.add('fa-chevron-up');
    collapsed = false;
  }

  void changeStreet(Map street) {
    currentStreetExits.clear();
    mainImgUrl = street['main_image']['url'];
    loadingImgUrl = street['loading_image']['url'];
    imageE.src = mainImgUrl;
    labelE.text = street['label'];
    imageE.onLoad.listen((_) {
      objectsE
        ..style.width = imageE.width.toString() + 'px'
        ..style.height = imageE.height.toString() + 'px';
    });

    new Service([#streetLoaded], (_) {
      // enable/disable expanding
      int collapsedHeight = street['loading_image']['h'] / currentStreet.bounds.height;
      int expandedHeight = street['main_image']['h'] / currentStreet.bounds.height;
      if (collapsedHeight > expandedHeight) {
        // street is wider than it is tall
        toggleE.hidden = true;
        expand();
      } else {
        // street is taller than it is wide
        toggleE.hidden = false;
        collapse();
      }
    });

    new Service([#playerLoaded], (_) {
      // load street objects
      updateObjects();
      // update every 10 milliseconds
      new Timer.periodic(new Duration(milliseconds: 10), (_) => updateObjects());
    });
  }

  void updateObjects() {
    // clear old data
    objectsE.setInnerHtml('');

    // new data

    Rectangle streetSize = currentStreet.bounds;
    int minimapWidth = imageE.width;
    int minimapHeight = imageE.height;
    int streetWidth = streetSize.width;
    int streetHeight = streetSize.height;
    num meX = CurrentPlayer.posX;
    num meY = CurrentPlayer.posY;
    num factorWidth = minimapWidth / streetWidth;
    num factorHeight = minimapHeight / streetHeight;

    // exits

    currentStreetExits.forEach((Map data) {
      String title = '';
      int i = 0;
      data["streets"].forEach((String name) {
        if (i != data["streets"].length - 1) {
          title += name + '\n';
        } else {
          title += name;
        }
        i++;
      });

      DivElement exit = new DivElement()
        ..classes.add('minimap-exit')
        ..style.top = ((data["y"] * factorHeight) - 8).toString() + 'px'
        ..style.left = ((data["x"] * factorWidth) - 6).toString() + 'px'
        ..title = title;

      objectsE.append(exit);
    });

    // other players

    otherPlayers.forEach((String name, Player thisPlayer) {
      DivElement player = new DivElement()
        ..classes.add('minimap-player')
        ..style.top = ((thisPlayer.posY * factorHeight) - 6).toString() + 'px'
        ..style.left = (thisPlayer.posX * factorWidth).toString() + 'px'
        ..title = name;

      objectsE.append(player);
    });

    // current player

    DivElement me = new DivElement()
      ..classes.add('minimap-player')
      ..classes.add('minimap-me')
      ..style.top = ((meY * factorHeight) - 6).toString() + 'px'
      ..style.left = (meX * factorWidth).toString() + 'px'
      ..title = game.username;

    objectsE.append(me);
  }
}