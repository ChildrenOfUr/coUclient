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

	Map <int, int> imgLevels = {
		1: 0,
		2: 130,
		3: 169,
		4: 220,
		5: 286,
		6: 372,
		7: 484,
		8: 629,
		9: 818,
		10: 1063,
		11: 1382,
		12: 1797,
		13: 2336,
		14: 3037,
		15: 3948,
		16: 5132,
		17: 6672,
		18: 8674,
		19: 11276,
		20: 14659,
		21: 19057,
		22: 24774,
		23: 32206,
		24: 41868,
		25: 54428,
		26: 70756,
		27: 91983,
		28: 119578,
		29: 155451,
		30: 202086,
		31: 262712,
		32: 341526,
		33: 443984,
		34: 577179,
		35: 750333,
		36: 975433,
		37: 1268063,
		38: 1648482,
		39: 2143027,
		40: 2785935,
		41: 3621716,
		42: 4708231,
		43: 6120700,
		44: 7956910,
		45: 10343983,
		46: 13447178,
		47: 17481331,
		48: 22725730,
		49: 29543449,
		50: 38406484,
		51: 49928429,
		52: 64906958,
		53: 84379045,
		54: 109692759,
		55: 142600587,
		56: 185380763,
		57: 240994992,
		58: 313293490,
		59: 407281537,
		60: 529465998
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
				int oldLevel = level;
				playerMetabolics = decode(event.data, type:Metabolics);
				if (oldLevel < level && webSocketMessages > 0) {
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