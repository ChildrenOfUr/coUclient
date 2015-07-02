part of couclient;

class StreetService {
	String _dataUrl = '${Configs.authAddress}/data';

	StreetService() {
		String prefix = Configs.authAddress.contains('localhost') ? 'http://' : 'https://';
		_dataUrl = prefix + _dataUrl;
	}

	requestStreet(String StreetID) async {
		log('[StreetService] Requesting street "$StreetID"...');

		HttpRequest data = await HttpRequest.request(_dataUrl + "/street", method: "POST",
		                                             requestHeaders: {"content-type": "application/json"},
		                                             sendData: JSON.encode({'street': StreetID, 'sessionToken': SESSION_TOKEN}));

		Map serverdata = JSON.decode(data.response);

		if(serverdata['ok'] == 'no')
			print('Error: Server refused.');

		log('[StreetService] "$StreetID" loaded.');
		await prepareStreet(serverdata['streetJSON']);
		String playerList = '';
		List<String> otherPlayers = JSON.decode(await HttpRequest.getString('http://' + Configs.utilServerAddress + '/listUsers?channel=' + currentStreet.label));
		if(otherPlayers.length > 0) {
			for(int i = 0; i != otherPlayers.length; i++) {
				playerList += otherPlayers[i];
				if(i != otherPlayers.length) {
					playerList += ', ';
				}
			}
			playerList = playerList.substring(0, playerList.length - 2);
			toast("Players on this street: " + playerList);
		}
	}

	prepareStreet(Map streetJSON) async
	{
		log('[StreetService] Assembling Street...');

		if(streetJSON['tsid'] == null)
			return;

		Map<String, dynamic> streetAsMap = streetJSON;
		String label = streetAsMap['label'];
		String tsid = streetAsMap['tsid'];
		String oldLabel = "";
		String oldTsid = "";
		if(currentStreet != null) {
			oldLabel = currentStreet.label;
			oldTsid = currentStreet.tsid;
		}

		// send data to minimap
		minimap.changeStreet(streetAsMap);

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

		String hubName = new DataMaps().data_maps_hubs[streetAsMap['hub_id']]()['name'];
		view.mapLoadingContent.style.opacity = "1.0";
		view.nowEntering.setInnerHtml('<h2>Entering</h2><h1>' + label + '</h1><h2>in ' + hubName/* + '</h2><h3>Home to: <ul><li>A <strong>Generic Goods Vendor</strong></li></ul>'*/);

		//wait for 1 second before loading the street (so that the preview text can be read)
		await new Future.delayed(new Duration(seconds: 1));
		new Asset.fromMap(streetAsMap, label);
		await new Street(streetAsMap).load();
		log('[StreetService] Street assembled.');
		// notify minimap to update
		transmit('streetLoaded', null);
	}
}