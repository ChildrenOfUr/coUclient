part of couclient;

class StreetService {
	StreetLoadingScreen streetLoadingScreen;

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

		gpsIndicator.loadingNew = true;

		logmessage('[StreetService] Requesting street "$StreetID"...');

		HttpRequest data = await HttpRequest.request(_dataUrl + "/street", method: "POST",
			requestHeaders: {"content-type": "application/json"},
			sendData: JSON.encode({'street': StreetID, 'sessionToken': SESSION_TOKEN}));

		Map serverdata = JSON.decode(data.response);

		if (serverdata['ok'] == 'no') {
			logmessage('[StreetService] Server refused');

			if (metabolics.lastStreet != null) {
				// Revert to last load success
				requestStreet(metabolics.lastStreet);
			}

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

	Future<bool> _prepareStreet(Map streetJSON) async {
		// Tell the server we're leaving
		try {
			sendGlobalAction('leaveStreet', {
				'street': currentStreet.tsid
			});
		} catch (e) {
			logmessage("Error sending last street to server: $e");
		}

		logmessage('[StreetService] Assembling Street...');
		transmit('streetLoadStarted', streetJSON);

		if (streetJSON['tsid'] == null) {
			return false;
		}

		Map<String, dynamic> streetAsMap = streetJSON;

		String label = streetAsMap['label'];
		String tsid = streetAsMap['tsid'];
		String oldLabel = '';
		String oldTsid = '';

		if (currentStreet != null) {
			oldLabel = currentStreet.label;
			oldTsid = currentStreet.tsid;
		}

		if (loadingCancelled(tsid)) {
			logmessage('[StreetService] Loading of "$tsid" was cancelled during decoding.');
			return false;
		}

		// TODO, this should happen automatically on the Server, since it'll know which street we're on.
		// Send changeStreet to chat server
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

		// Display the loading screen
		streetLoadingScreen = new StreetLoadingScreen(currentStreet?.streetData, streetAsMap);

		// Load the street

		Street street = new Street(streetAsMap);

		if (loadingCancelled(tsid)) {
			logmessage('[StreetService] Loading of "$tsid" was cancelled during preparation.');
			return false;
		}

		// Make street loading take at least 1 second so that the text can be read
		await Future.wait([
			new Future.delayed(new Duration(seconds: 1)),
			street.load()
		]);

		new Asset.fromMap(streetAsMap, label);

		logmessage('[StreetService] Street assembled.');

		// Notify displays to update
		transmit('streetLoaded', streetAsMap);

		removeFromQueue(tsid);
		return true;
	}
}