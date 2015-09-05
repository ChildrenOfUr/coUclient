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

	Map <int, int> imgLevels = {
		1: 100,
		2: 137,
		3: 188,
		4: 258,
		5: 353,
		6: 484,
		7: 663,
		8: 908,
		9: 1244,
		10: 1704,
		11: 2334,
		12: 3198,
		13: 4381,
		14: 6002,
		15: 8223,
		16: 11266,
		17: 15434,
		18: 21145,
		19: 28969,
		20: 39688,
		21: 54373,
		22: 74491,
		23: 102053,
		24: 139813,
		25: 191544,
		26: 262415,
		27: 359509,
		28: 492527,
		29: 674762,
		30: 924424,
		31: 1266461,
		32: 1735052,
		33: 2377021,
		34: 3256519,
		35: 4461431,
		36: 6112160,
		37: 8373659,
		38: 11471913,
		39: 15716521,
		40: 21531634,
		41: 29498339,
		42: 40412724,
		43: 55365432,
		44: 75850642,
		45: 103915380,
		46: 142364071,
		47: 195038777,
		48: 267203124,
		49: 366068280,
		50: 501513544,
		51: 687073555,
		52: 941290770,
		53: 1289568355,
		54: 1766708646,
		55: 2420390845,
		56: 3315935458,
		57: 4542831577,
		58: 6223679260,
		59: 8526440586,
		60: 11681223603
	};

	Map<int, int> scaleLevels([num sf = 1.37]) {
		Map<int, num> scale = {
			1: 0
		};
		int base = 100;
		for (int i = 1; i <= 60; i++) {
			scale.addAll(({i: base}));
			base = (base * sf).round();
		}
		return scale;
	}

	void init(Metabolics m) {
		playerMetabolics = m;
		view.meters.updateAll();

		setupWebsocket();
	}

	setupWebsocket() {
		//establish a websocket connection to listen for metabolics objects coming in
		WebSocket socket = new WebSocket(url);
		socket.onOpen.listen((_) => socket.send(JSON.encode({'username': game.username})));
		socket.onMessage.listen((MessageEvent event) {
			Map map = JSON.decode(event.data);
			if (map['collectQuoin'] != null && map['collectQuoin'] == "true") {
				collectQuoin(map);
			} else {
				int oldLevel = level;
				playerMetabolics = decode(event.data, type:Metabolics);
				if (!load.isCompleted) {
					load.complete();
				}
				if (oldLevel > level - 2 && level > oldLevel && webSocketMessages > 0) {
					levelUp.open();
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

	int get level {
		int lvl = 0;
		for (int levelNum in imgLevels.keys) {
			if (imgLevels[levelNum] > lifetime_img) {
				lvl = levelNum - 1;
				break;
			}
		}
		return lvl;
	}

	int get img_req_for_curr_lvl {
		return imgLevels[level];
	}

	int get img_req_for_next_lvl {
		return imgLevels[level + 1];
	}
}