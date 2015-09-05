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
	String url = 'ws://${Configs.websocketServerAddress}/metabolics';
	int webSocketMessages = 0;
	bool loaded = false;
	Completer load = new Completer();

	Future init(Metabolics m) async {
		playerMetabolics = m;
		view.meters.updateAll();

		await setupWebsocket();
	}

	setupWebsocket() async {
		//establish a websocket connection to listen for metabolics objects coming in
		WebSocket socket = new WebSocket(url);
		socket.onOpen.listen((_) => socket.send(JSON.encode({'username': game.username})));
		socket.onMessage.listen((MessageEvent event) async {
			Map map = JSON.decode(event.data);
			if (map['collectQuoin'] != null && map['collectQuoin'] == "true") {
				collectQuoin(map);
			} else {
				int oldImg = lifetime_img;
				int oldLevel = await level;
				playerMetabolics = decode(event.data, type:Metabolics);
				if (!load.isCompleted) {
					load.complete();
				}
				int newImg = lifetime_img;
				int newLvl;
				if (newImg > oldImg) {
					newLvl = await level;
					if (oldLevel > newLvl - 2 && newLvl > oldLevel && webSocketMessages > 0) {
						levelUp.open();
					}
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
		socket.onError.listen((ErrorEvent e) {
			logmessage('[Metabolics] Error ${e.error}');
		});
	}

	update() => view.meters.updateAll();

	void collectQuoin(Map map) {
		Element element = querySelector('#${map['id']}');
		quoins[map['id']].checking = false;

		if (map['success'] == 'false') return;

		int amt = map['amt'];
		if (querySelector("#buff-quoin") != null) {
			amt *= 2;
			// TODO: implement server-side so that this amount actually gets awarded
		}
		String quoinType = map['quoinType'];

		if (quoinType == "energy" && playerMetabolics.energy + amt > playerMetabolics.max_energy) {
			amt = playerMetabolics.max_energy - playerMetabolics.energy;
		}

		if (quoinType == "mood" && playerMetabolics.mood + amt > playerMetabolics.max_mood) {
			amt = playerMetabolics.max_mood - playerMetabolics.mood;
		}
		quoins[map['id']].collected = true;

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

	int get maxEnergy => playerMetabolics.max_energy;

	int get mood => playerMetabolics.mood;

	int get maxMood => playerMetabolics.max_mood;

	int get img => playerMetabolics.img;

	int get lifetime_img => playerMetabolics.lifetime_img;

	String get currentStreet => playerMetabolics.current_street;

	num get currentStreetX => playerMetabolics.current_street_x;

	num get currentStreetY => playerMetabolics.current_street_y;

	List<String> get location_history => JSON.decode(playerMetabolics.location_history);

	Future<int> get level async {
		String lvlStr = await HttpRequest.getString("http://${Configs.utilServerAddress}/getLevel?img=${img.toString()}");
		return int.parse(lvlStr);
	}

	Future<int> get img_req_for_curr_lvl async {
		String imgStr = await HttpRequest.getString("http://${Configs.utilServerAddress}/getImgForLevel?level=${(await level).toString()}");
		return int.parse(imgStr);
	}

	Future<int> get img_req_for_next_lvl async {
		String imgStr = await HttpRequest.getString("http://${Configs.utilServerAddress}/getImgForLevel?level=${((await level) + 1).toString()}");
		return int.parse(imgStr);
	}
}