part of couclient;

class StreetService {
	List<String> _loading = [];

	bool loadingCancelled(String tsid) => !_loading.contains(tsid);

	String _dataUrl = '${Configs.authAddress}/data';

	StreetService() {
		String prefix = Configs.authAddress.contains('localhost') ? 'http://' : 'https://';
		_dataUrl = prefix + _dataUrl;
	}

	Future requestStreet(String StreetID) async {
		if (_loading.length > 0) {
			// Already loading something, tell it to stop
			_loading.clear();
		}

		// Load this one
		_loading.add(StreetID);

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

		if(serverdata['ok'] == 'no') {
			logmessage('[StreetService] Server refused');
		} else {
			if (loadingCancelled(StreetID)) {
				logmessage('[StreetService] Loading of "$StreetID" was cancelled during download.');
			} else {
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
					toast("Players on this street: " + playerList);
				} else {
					toast("You're the first one here!");
				}
			}
		}

		_loading.remove(StreetID);
	}

	Future _prepareStreet(Map streetJSON) async
	{
		logmessage('[StreetService] Assembling Street...');

		if(streetJSON['tsid'] == null) {
			return;
		}

		Map<String, dynamic> streetAsMap = streetJSON;

		String label = streetAsMap['label'];
		String tsid = streetAsMap['tsid'];
		String oldLabel = "";
		String oldTsid = "";
		if(currentStreet != null) {
			oldLabel = currentStreet.label;
			oldTsid = currentStreet.tsid;
		}

		if (loadingCancelled(tsid)) {
			logmessage('[StreetService] Loading of "$tsid" was cancelled during decoding.');
			return;
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

		view.streetLoadingImage.src = streetAsMap['loading_image']['url'];
		await view.streetLoadingImage.onLoad.first;
		DataMaps maps = new DataMaps();
		String hubName = maps.data_maps_hubs[streetAsMap['hub_id']]()['name'];
		Map<int,Map<String,String>> moteInfo = maps.data_maps_streets['9']();
		String lsid = tsid;
		if(lsid.startsWith('G')) {
			lsid = lsid.replaceFirst('G','L');
		}
		String currentStreetName = moteInfo[streetAsMap['hub_id']][lsid];
		view.mapLoadingContent.style.opacity = "1.0";
		view.nowEntering.setInnerHtml('<h2>Entering</h2><h1>' + currentStreetName + '</h1><h2>in ' + hubName/* + '</h2><h3>Home to: <ul><li>A <strong>Generic Goods Vendor</strong></li></ul>'*/);

		//wait for 1 second before loading the street (so that the preview text can be read)
		await new Future.delayed(new Duration(seconds: 1));

		Street street = new Street(streetAsMap);

		// send data to minimap
		minimap.changeStreet(streetAsMap);

		new Asset.fromMap(streetAsMap, label);

		if (loadingCancelled(tsid)) {
			logmessage('[StreetService] Loading of "$tsid" was cancelled during preparation.');
			return;
		}

		await street.load();
		logmessage('[StreetService] Street assembled.');

		// notify displays to update
		transmit('streetLoaded', streetAsMap);
	}
}