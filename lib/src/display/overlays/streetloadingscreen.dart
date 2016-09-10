part of couclient;

class StreetLoadingScreen extends Overlay {
	static void toggleUi(bool visible) {
		minimap.containerE.hidden = !visible;
		view.inventorySearch.hidden = !visible;
	}

	Map<String, dynamic> oldStreet;
	Map<String, dynamic> newStreet;

	bool splitScreen;

	Element progressBar;

	StreetLoadingScreen(this.oldStreet, this.newStreet) : super('MapLoadingScreen', true) {
		splitScreen = (oldStreet != null) && (oldStreet['hub_id'] != newStreet['hub_id']);

		progressBar = new Element.tag('ur-progress')
			..classes = ['street-load-progress']
			..attributes['percent'] = '0'
			..attributes['status'] = '';

		open();
	}

	@override
	open() {
		// Hide overlapping interface
		toggleUi(false);

		// Remove old elements
		displayElement.children.clear();

		// Display "Leaving" side if changing hubs
		if (splitScreen) {
			displayElement.append(_createSection(oldStreet, leaving: true));
		}

		// Display "Entering" side
		displayElement.append(_createSection(newStreet));

		// Display progress
		displayElement.append(progressBar);

		// Show overlay
		super.open();
	}

	@override
	close() {
		// Unhide overlapping interface
		toggleUi(true);

		// Hide overlay
		super.close();
	}

	set loadingPercent(int percent) {
		// Set width of segment
		progressBar.attributes['percent'] = percent.toString();

		if (percent <= 99) {
			// Still loading
			progressBar.attributes['status'] = 'Reticulating splines... $percent%';
		} else {
			// Done loading
			progressBar.attributes['status'] = '...done!';

			// Hide after 3 seconds (to finish settling entities)
			new Future.delayed(new Duration(seconds: 3)).then((_) => close());
		}
	}

	DivElement _createSection(Map<String, dynamic> street, {bool leaving: false}) {
		HeadingElement actionTitle = new HeadingElement.h2()
			..text = 'Now ${leaving ? 'Leaving' : 'Entering'}';

		HeadingElement streetTitle = new HeadingElement.h1()
			..text = '${street['label']}';

		Map<String, dynamic> hub = mapData.hubData[street['hub_id']];

		HeadingElement hubTitle = new HeadingElement.h2()
			..text = 'in ${hub['name']}';

		String topColor = hub['color_top'];
		topColor = (!topColor.startsWith('#') ? '#$topColor' : topColor);
		String bottomColor = hub['color_btm'];
		bottomColor = (!bottomColor.startsWith('#') ? '#$bottomColor' : bottomColor);

		DivElement section = new DivElement()
			..classes = ['street-load-section']
			..style.background = 'linear-gradient(to bottom, $topColor 0%, $bottomColor 100%)'
			..append(_createLoadingImage(street))
			..append(actionTitle)
			..append(streetTitle)
			..append(hubTitle);

		if (leaving) {
			// This section is the "Leaving" side
			section.classes.add('street-load-section-leaving');
		} else {
			if (splitScreen) {
				section.classes.add('street-load-section-entering');
			}

			// List entities on "Entering" street

			HeadingElement entitiesTitle = new HeadingElement.h3()
				..text = 'Home to: ';

			ParagraphElement entitiesList = new ParagraphElement();
			_listEntities(street, entitiesTitle).then((String list) => entitiesList.setInnerHtml(list));

			section
				..append(entitiesTitle)
				..append(entitiesList);
		}

		return section;
	}

	ImageElement _createLoadingImage(Map<String, dynamic> street) =>
		new ImageElement(src: street['loading_image']['url'])
			..width = street['loading_image']['w']
			..height = street['loading_image']['h']
			..classes = ['street-load-image'];

	Future<String> _listEntities(Map<String, dynamic> street, Element titleDisplay) async {
		String url = 'http://${Configs.utilServerAddress}/previewStreetEntities?tsid=${street['tsid']}';
		Map<String, int> entityList = JSON.decode(await HttpRequest.getString(url));
		String entityString = '';

		if (entityList.keys.length == 0) {
			// No list, no title
			titleDisplay.hidden = true;
		} else if (entityList.keys.length == 1) {
			// Only one entity, just display it without commas
			entityString = '${entityList.values.single} ${entityList.keys.single}';
		} else {
			// Multiple entities, format with commas and a conjunction
			for (int i = 0; i < entityList.keys.length; i++) {
				String entityType = entityList.keys.toList()[i];
				int count = entityList[entityType];

				if (i == entityList.keys.length - 1) {
					// Last entity
					entityString += 'and $count $entityType';
				} else {
					entityString += '$count $entityType, <wbr>';
				}
			}
		}

		return entityString;
	}
}