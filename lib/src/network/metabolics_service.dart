part of couclient;

/**
 *
 * This class will be responsible for querying the database and writing back to it
 * with the details of the player (currants, mood, etc.)
 *
 **/

MetabolicsService metabolics = new MetabolicsService();

class MetabolicsService {
	Metabolics playerMetabolics;
	DateTime lastUpdate, nextUpdate;
	String url = '${Configs.ws}//${Configs.websocketServerAddress}/metabolics';
	int webSocketMessages = 0;
	bool loaded = false;
	Completer load = new Completer();

	Future init(Metabolics m) async {
		playerMetabolics = m;
		view.meters.updateAll();

		await setupWebsocket();
	}

	Future setupWebsocket() async {
		//establish a websocket connection to listen for metabolics objects coming in
		WebSocket socket = new WebSocket(url);
		socket.onOpen.listen((_) => socket.send(jsonEncode({'username': game.username})));
		socket.onMessage.listen((MessageEvent event) async {
			Map<String, dynamic> map = jsonDecode(event.data) as Map;
			if (map['collectQuoin'] != null && map['collectQuoin'] as String == "true") {
				collectQuoin(map);
			} else if (map["levelUp"] != null) {
				levelUp.open(map["levelUp"]);
			} else {
				playerMetabolics = Metabolics.fromJson(map);
				if (!load.isCompleted) {
					load.complete();
					transmit("metabolicsLoaded", playerMetabolics);
				}
				transmit('metabolicsUpdated', playerMetabolics);
			}
			update();
			webSocketMessages++;
		});
		socket.onClose.listen((CloseEvent e) {
			logmessage('[Metabolics] Websocket closed: ${e.reason}');
			//wait 5 seconds and try to reconnect
			new Timer(new Duration(seconds: 5), () => setupWebsocket());
		});
		socket.onError.listen((Event e) {
			logmessage('[Metabolics] Error $e');
		});
	}

	void update() => view.meters.update();

	void collectQuoin(Map<String, dynamic> map) {
		Element element = querySelector('#${map['id']}');
		quoins[map['id'] as String].checking = false;

		if (map['success'].toString() == 'false') return;

		num amt = map['amt'];
		if (querySelector("#buff-quoin") != null) {
			amt *= 2;
		}
		String quoinType = map['quoinType'];

		if (quoinType == "energy" && playerMetabolics.energy + amt > playerMetabolics.maxEnergy) {
			amt = playerMetabolics.maxEnergy - playerMetabolics.energy;
		}

		if (quoinType == "mood" && playerMetabolics.mood + amt > playerMetabolics.maxMood) {
			amt = playerMetabolics.maxMood - playerMetabolics.mood;
		}
		quoins[map['id'] as String].collected = true;

		Element quoinText = querySelector("#qq" + element.id + " .quoinString");

		switch (quoinType) {
			case "currant":
				if (amt == 1) quoinText.text = "+" + amt.toString() + " currant";
				else quoinText.text = "+" + amt.toString() + " currants";
				break;

			case "mood":
				if (amt == 0) {
					quoinText.text = "Full mood!";
				} else {
					quoinText.text = "+" + amt.toString() + " mood";
				}
				break;

			case "energy":
				if (amt == 0) {
					quoinText.text = "Full energy!";
				} else {
					quoinText.text = "+" + amt.toString() + " energy";
				}
				break;

			case "quarazy":
			case "img":
				quoinText.text = "+" + amt.toString() + " iMG";
				break;

			case "favor":
				quoinText.text = "+" + amt.toString() + " favor";
				break;

			case "time":
				quoinText.text = "+" + amt.toString() + " time";
				break;

			case "mystery":
				quoinText.text = "quoin multiplier +" + amt.toString();
				break;
		}
	}

	int get currants => playerMetabolics.currants;

	int get energy => playerMetabolics.energy;

	int get maxEnergy => playerMetabolics.maxEnergy;

	int get mood => playerMetabolics.mood;

	int get maxMood => playerMetabolics.maxMood;

	int get img => playerMetabolics.img;

	int get lifetime_img => playerMetabolics.lifetimeImg;

	String get currentStreet => playerMetabolics.currentStreet;

	String get lastStreet => playerMetabolics.lastStreet;

	num get currentStreetX => playerMetabolics.currentStreetX;

	num get currentStreetY => playerMetabolics.currentStreetY;

	List<String> get location_history => (jsonDecode(playerMetabolics.locationHistory) as List).cast<String>();

	Future<int> get level async {
		String lvlStr = await HttpRequest.getString(
			"${Configs.http}//${Configs.utilServerAddress}/getLevel?img=${lifetime_img.toString()}");
		return int.parse(lvlStr);
	}

	Future<int> get img_req_for_curr_lvl async {
		String imgStr = await HttpRequest.getString(
			"${Configs.http}//${Configs.utilServerAddress}/getImgForLevel?level=${(await level).toString()}");
		return int.parse(imgStr);
	}

	Future<int> get img_req_for_next_lvl async {
		String imgStr = await HttpRequest.getString(
			"${Configs.http}//${Configs.utilServerAddress}/getImgForLevel?level=${((await level) + 1).toString()}");
		return int.parse(imgStr);
	}
}
