part of couclient;

class StreetService {
	List<String> _loading = [];

	void addToQueue(String tsid) {
		_loading.add(tsid.substring(1));
	}

	void removeFromQueue(String tsid) {
		_loading.remove(tsid.substring(1));
	}

	bool loadingCancelled(String tsid) {
		return !_loading.contains(tsid.substring(1));
	}

	String _dataUrl = '${Configs.authAddress}/data';

	StreetService() {
		String prefix = Configs.authAddress.contains('localhost') ? 'http://' : 'https://';
		_dataUrl = prefix + _dataUrl;
	}

	Future<bool> requestStreet(String StreetID) async {
		if (_loading.length > 0) {
			// Already loading something, tell it to stop
			_loading.clear();
		}

		// Load this one
		addToQueue(StreetID);

		//hide the minimap if it's showing
		minimap.containerE.hidden = true;
		gpsIndicator.loadingNew = true;

		//make sure loading screen is visible during load
		view.mapLoadingScreen.className = "MapLoadingScreenIn";
		view.mapLoadingScreen.style.opacity = "1.0";

		logmessage('[StreetService] Requesting street "$StreetID"...');

		HttpRequest data = await HttpRequest.request(_dataUrl + "/street", method: "POST",
			requestHeaders: {"content-type": "application/json"},
			sendData: JSON.encode({'street': StreetID, 'sessionToken': SESSION_TOKEN}));

		Map serverdata = JSON.decode(data.response);

		if (serverdata['ok'] == 'no') {
			logmessage('[StreetService] Server refused');
			return false;
		}

		if (loadingCancelled(StreetID)) {
			logmessage('[StreetService] Loading of "$StreetID" was cancelled during download.');
			return false;
		}

		logmessage('[StreetService] "$StreetID" loaded.');
		await _prepareStreet(serverdata['streetJSON']);

		String playerList = '';
		List<String> players = JSON.decode(await HttpRequest.getString(
			'http://' + Configs.utilServerAddress + '/listUsers?channel=' +
				currentStreet.label));
		if (!players.contains(game.username)) {
			players.add(game.username);
		}
		// don't list if it's just you
		if (players.length > 1) {
			for (int i = 0; i != players.length; i++) {
				playerList += players[i];
				if (i != players.length) {
					playerList += ', ';
				}
			}
			playerList = playerList.substring(0, playerList.length - 2);
			new Toast("Players on this street: " + playerList);
		} else {
			new Toast("You're the first one here!");
		}

		return true;
	}

	Future<bool> _prepareStreet(Map streetJSON) async
	{
		logmessage('[StreetService] Assembling Street...');

		if (streetJSON['tsid'] == null) {
			return false;
		}

		Map<String, dynamic> streetAsMap = streetJSON;

		String label = streetAsMap['label'];
		String tsid = streetAsMap['tsid'];
		String oldLabel = "";
		String oldTsid = "";
		if (currentStreet != null) {
			oldLabel = currentStreet.label;
			oldTsid = currentStreet.tsid;
		}

		if (loadingCancelled(tsid)) {
			logmessage('[StreetService] Loading of "$tsid" was cancelled during decoding.');
			return false;
		}

		// TODO, this should happen automatically on the Server, since it'll know which street we're on.
		//send changeStreet to chat server
		Map map = new Map();
		map["statusMessage"] = "changeStreet";
		map["username"] = game.username;
		map["newStreetLabel"] = label;
		map["newStreetTsid"] = tsid;
		map["oldStreetTsid"] = oldTsid;
		map["oldStreetLabel"] = oldLabel;
		transmit('outgoingChatEvent', map);

		if (!mapData.load.isCompleted) {
			await mapData.load.future;
		}

		view.streetLoadingImage.src = streetAsMap['loading_image']['url'];
		await view.streetLoadingImage.onLoad.first;
		String hubName = mapData.hubData[streetAsMap['hub_id']]['name'];
		String lsid = tsid;
		if (lsid.startsWith('G')) {
			lsid = lsid.replaceFirst('G', 'L');
		}
		String currentStreetName = mapData.getLabel(lsid);

		view.mapLoadingContent.style.opacity = "1.0";
		view.nowEntering.children.clear();

		HeadingElement enteringHeader = new HeadingElement.h2()..text = 'Entering';
		HeadingElement streetHeader = new HeadingElement.h1()..text = currentStreetName;
		HeadingElement hubHeader = new HeadingElement.h2()..text = 'in $hubName';
		HeadingElement homeHeader = new HeadingElement.h3()..text = 'Home to: ';
		ParagraphElement entityListElement = new ParagraphElement();

		String url = 'http://${Configs.utilServerAddress}/previewStreetEntities?tsid=$tsid';
		Map<String, int> entityList = JSON.decode(await HttpRequest.getString(url));
		String entityString = '';
		entityList.forEach((String entityType, num count) {
			entityString += '$count $entityType, ';
		});
		if (entityString.endsWith(', ')) {
			entityString = entityString.substring(0, entityString.length - 1);
		}

		entityListElement.text = entityString;

		view.nowEntering..append(enteringHeader)..append(streetHeader)..append(hubHeader)
			..append(homeHeader)..append(entityListElement);

		//wait for 1 second before loading the street (so that the preview text can be read)
		await new Future.delayed(new Duration(seconds: 1));

		Street street = new Street(streetAsMap);

		// send data to minimap
		minimap.changeStreet(streetAsMap);

		new Asset.fromMap(streetAsMap, label);

		if (loadingCancelled(tsid)) {
			logmessage('[StreetService] Loading of "$tsid" was cancelled during preparation.');
			return false;
		}

		await street.load();
		logmessage('[StreetService] Street assembled.');

		// notify displays to update
		transmit('streetLoaded', streetAsMap);

		removeFromQueue(tsid);

		return true;
	}
}
