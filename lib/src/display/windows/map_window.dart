part of couclient;

class MapWindow extends Modal {
  String id = 'mapWindow';
  Element trigger = querySelector("#mapButton");
  InputElement searchBox = querySelector("#mapwindow-search");
  Element searchResultsContainer = querySelector("#map-window-search-results");
  UListElement searchResults = querySelector("#map-window-search-results ul");

  MapWindow() {
    prepare();

    setupUiButton(view.mapButton, openCallback:_drawWorldMap);
    setupKeyBinding("Map", openCallback:_drawWorldMap);

    new Service(['teleportByMapWindow'], (event) {
      this.close();
    });

    searchBox.onInput.listen((_) => filter(searchBox.value));
    searchBox.onFocus.listen((_) => inputManager.ignoreKeys = ignoreShortcuts = true);
    searchBox.onBlur.listen((_) {
      new Timer(new Duration(milliseconds: 100), () {
        inputManager.ignoreKeys = ignoreShortcuts = false;
        filter("");
      });
    });
  }

  _drawWorldMap() {
    worldMap = new WorldMap(currentStreet.hub_id);
  }

  @override
  open() {
    super.open();
    trigger.classes.remove('closed');
    trigger.classes.add('open');
  }

  @override
  close() {
    super.close();
    trigger.classes.remove('open');
    trigger.classes.add('closed');
  }

  filter(String entry) {
    // Toggle list showing
    if (entry == "") {
      searchResultsContainer.hidden = true;
      return;
    } else {
      searchResultsContainer.hidden = false;
    }

    // Clear previous results
    searchResults.children.clear();

    int streetsLimit = 0;
    streetContentsData.forEach((String streetname, Map data) {

      // Format TSID
      String tsid = data["tsid"];
      if (tsid == null) {
        tsid = "NULL_TSID";
      } else {
        tsid = tsid.substring(1);
      }

      // Check if street matches search
      if (streetname.toLowerCase().contains(entry.toLowerCase()) || tsid.toLowerCase().contains(entry.substring(1).toLowerCase())) {
        if (streetsLimit < 13) {

          // Mark if current street
          String streetOut;
          if (currentStreet.label == streetname) {
            streetOut = "<i>$streetname</i>";
          } else {
            streetOut = streetname;
          }

          // Selectable item
          LIElement result = new LIElement()
            ..setInnerHtml(streetOut);

          // Link to hub
          if (streetContentsData[streetname] != null) {
            String hub_id = streetContentsData[streetname]["hub_id"].toString();
            result.onClick.listen((Event e) {
              e.preventDefault();
              worldMap.loadhubdiv(hub_id);
              searchBox.value = "";
            });
          } else {
            logmessage("[WorldMap] Could not find the hub_id for $streetname");
          }

          // Add to list
          searchResults.append(result);

          streetsLimit++;
        }
      }
    });
  }
}