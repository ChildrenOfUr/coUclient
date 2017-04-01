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
			if(collapsed) {
				expand();
			} else {
				collapse();
			}
		});

		new Service(['streetLoaded'], (street) {
			_changeStreet(street);

			// enable/disable expanding
//			num collapsedHeight = street['loading_image']['h'] / currentStreet.bounds.height;
//			num expandedHeight = street['main_image']['h'] / currentStreet.bounds.height;
//			if((collapsedHeight < expandedHeight) || mapData.getMinimapExpandOverride(street["label"])) {
//				// street is taller than it is wide
//				// (or overridden)
//				// allow expansion
//				toggleE.hidden = false;
//				collapse();
//			} else if(collapsedHeight > expandedHeight) {
//				// street is wider than it is tall
//				// disallow expansion
//				toggleE.hidden = true;
//				expand();
//			}

			collapse();
		});
	}

	void collapse() {
		imageE.src = loadingImgUrl;
		imageE.onLoad.listen((_) {
			objectsE.hidden = true;
			toggleE.querySelector('i.fa').classes.remove('fa-chevron-up');
			toggleE.querySelector('i.fa').classes.add('fa-chevron-down');
			collapsed = true;
		});
	}

	void expand() {
		imageE.src = mainImgUrl;
		imageE.onLoad.listen((_) {
			updateObjects();
			objectsE.hidden = false;
			toggleE.querySelector('i.fa').classes.remove('fa-chevron-down');
			toggleE.querySelector('i.fa').classes.add('fa-chevron-up');
			collapsed = false;
		});
	}

	void _changeStreet(Map street) {
		mainImgUrl = street['main_image']['url'];
		loadingImgUrl = street['loading_image']['url'];
		imageE.src = mainImgUrl;
		labelE.text = currentStreet.label;
		imageE.onLoad.listen((_) {
			objectsE
				..style.width = imageE.width.toString() + 'px'
				..style.height = imageE.height.toString() + 'px';
		});
		if(mapData.getMinimapOverride() == true) {
			objectsE.hidden = true;
		} else if (mapData.getMinimapOverride() == false) {
			objectsE.hidden = false;
		}
	}

	Future updateObjects() async {
		if(CurrentPlayer == null) {
			return;
		}

		objectsE.children.clear();

		// new data

		Rectangle streetSize = currentStreet.bounds;
		int minimapWidth = imageE.width;
		int minimapHeight = imageE.height;
		int streetWidth = streetSize.width;
		int streetHeight = streetSize.height;
		num meX = CurrentPlayer.left;
		num meY = CurrentPlayer.top;
		num factorWidth = minimapWidth / streetWidth;
		num factorHeight = minimapHeight / streetHeight;

		// exits

		currentStreetExits.forEach((Map data) {
			String title = '';
			int i = 0;
			data["streets"].forEach((String name) {
				if(i != data["streets"].length - 1) {
					title += name + '\n';
				} else {
					title += name;
				}
				i++;
			});

			DivElement exit = new DivElement()
				..classes.add('minimap-exit')
				..style.top = ((data["y"] * factorHeight) - 6).toString() + 'px'
				..style.left = ((data["x"] * factorWidth) - 4).toString() + 'px'
				..title = title;

			objectsE.append(exit);
		});

		// other players

		await otherPlayers.forEach((String name, Player thisPlayer) async {
			DivElement player = new DivElement()
				..classes.add('minimap-player')
				..style.top = ((thisPlayer.top * factorHeight) - 6).toString() + 'px'
				..style.left = (thisPlayer.left * factorWidth).toString() + 'px'
				..title = name
				..style.backgroundColor = await getColorFromUsername(name);

			objectsE.append(player);
		});

		// current player

		DivElement me = new DivElement()
			..classes.add('minimap-player')
			..classes.add('minimap-me')
			..style.top = ((meY * factorHeight) - 6).toString() + 'px'
			..style.left = (meX * factorWidth).toString() + 'px'
			..title = game.username
			..style.backgroundColor = await getColorFromUsername(game.username);

		objectsE.append(me);
	}
}
