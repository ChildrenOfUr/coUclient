part of couclient;

class MapWindow extends Modal {
	String id = 'mapWindow';
	Element trigger = querySelector("#mapButton");
	InputElement searchBox = querySelector("#mapwindow-search");
	Element searchResultsContainer = querySelector("#map-window-search-results");
	UListElement searchResults = querySelector("#map-window-search-results ul");

	MapWindow() {
		prepare();

		setupUiButton(view.mapButton,openCallback:_drawWorldMap);
		setupKeyBinding("Map",openCallback:_drawWorldMap);

		new Service(['teleportByMapWindow'], (event) {
			this.close();
		});

		searchBox.onInput.listen((_) => filter(searchBox.value));
    searchBox.onFocus.listen((_) => inputManager.ignoreKeys = ignoreShortcuts = true);
    searchBox.onBlur.listen((_) {
      inputManager.ignoreKeys = ignoreShortcuts = false;
      filter("");
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

		// Limit the list to 13 items
		int streetsLimit = 0;
		for (String streetname in streetContentsData.keys.where((String streetname) => streetname.toLowerCase().contains(entry.toLowerCase()))) {
			if (streetsLimit < 13) {

				// Display hub to the right
				SpanElement hubName = new SpanElement()
					..text = "Hub Name Here";

				// Bold matching parts
				String outName;
				outName = streetname.replaceAll(entry, "<b>$entry</b>");

				// Mark if current street
				if (currentStreet.label == streetname) {
					outName = "<i>$outName</i>";
				}

				// Selectable item
				LIElement result = new LIElement()
					..setInnerHtml(outName)
					..append(hubName)
					..onClick.listen((_) => print("clicked $streetname"));

				// Add to list
				searchResults.append(result);

				streetsLimit++;
			} else {
				// Stop the loop, no need to waste time
				break;
			}
		}
	}
}