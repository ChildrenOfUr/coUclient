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

	Map <int, int> imgLevels = {
		1: 100,
		2: 125,
		3: 156,
		4: 195,
		5: 244,
		6: 305,
		7: 381,
		8: 476,
		9: 595,
		10: 744,
		11: 930,
		12: 1163,
		13: 1454,
		14: 1818,
		15: 2273,
		16: 2841,
		17: 3551,
		18: 4439,
		19: 5549,
		20: 6936,
		21: 8670,
		22: 10838,
		23: 13548,
		24: 16935,
		25: 21169,
		26: 26461,
		27: 33076,
		28: 41345,
		29: 51681,
		30: 64601,
		31: 80751,
		32: 100939,
		33: 126174,
		34: 157718,
		35: 197148,
		36: 246435,
		37: 308044,
		38: 385055,
		39: 481319,
		40: 601649,
		41: 752061,
		42: 940076,
		43: 1175095,
		44: 1468869,
		45: 1836086,
		46: 2295108,
		47: 2868885,
		48: 3586106,
		49: 4482633,
		50: 5603291,
		51: 7004114,
		52: 8755143,
		53: 10943929,
		54: 13679911,
		55: 17099889,
		56: 21374861,
		57: 26718576,
		58: 33398220,
		59: 41747775,
		60: 52184719
	};

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
			if (map['collectQuoin'] != null) {
				collectQuoin(map);
			} else {
				playerMetabolics = decode(event.data, type:Metabolics);
				transmit('metabolicsUpdated', playerMetabolics);
			}
			update();
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

		// TODO: enable this when the server supports it
//    if (quoinType == "mystery") {
//      switch (new Random().nextInt(5)) {
//        case 0:
//          quoinType = "currant";
//          break;
//        case 1:
//          quoinType = "mood";
//          break;
//        case 2:
//          quoinType = "energy";
//          break;
//        case 3:
//          quoinType = "img";
//          break;
//        case 4:
//          quoinType = "favor";
//          break;
//        case 5:
//          quoinType = "time";
//          break;
//      }
//    }

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
				quoinText.text = "No time like the present";
				// TODO : update this later
				break;
			case "mystery":
				quoinText.text = "+" + amt.toString() + " brownie points";
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