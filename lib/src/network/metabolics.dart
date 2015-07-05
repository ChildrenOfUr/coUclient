part of couclient;

/**
 *
 * This class will be responsible for querying the database and writing back to it
 * with the details of the player (currants, mood, etc.)
 *
 **/

MetabolicsService metabolics = new MetabolicsService();

class Metabolics {
	int id, mood = 50, max_mood = 100, energy = 50, max_energy = 100;
	int currants = 0, img = 0, lifetime_img = 0, user_id = -1;
	int AlphFavor = 0, CosmaFavor = 0, FriendlyFavor = 0, GrendalineFavor = 0;
	int HumbabaFavor = 0, LemFavor = 0, MabFavor = 0, PotFavor = 0, SprigganFavor = 0;
	int TiiFavor = 0, ZilleFavor = 0;
	num current_street_x = 1.0, current_street_y = 0.0;
	String current_street = 'LA58KK7B9O522PC';
}

class MetabolicsService {
	Metabolics playerMetabolics;
	DateTime lastUpdate, nextUpdate;
	String url = 'ws://${Configs.websocketServerAddress}/metabolics';

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
			if(map['collectQuoin'] != null) {
				collectQuoin(map);
			} else {
				playerMetabolics = decode(event.data, type:Metabolics);
				transmit('metabolicsUpdated',playerMetabolics);
			}
			update();
		});
		socket.onClose.listen((CloseEvent e) {
			log('Metabolics: Websocket closed: ${e.reason}');
			//wait 5 seconds and try to reconnect
			new Timer(new Duration(seconds: 5), () => setupWebsocket());
		});
		socket.onError.listen((ErrorEvent e) {
			log('Metabolics: error ${e.error}');
		});
	}

	update() => view.meters.updateAll();

	void collectQuoin(Map map) {
		Element element = querySelector('#${map['id']}');
		quoins[map['id']].checking = false;

		if(map['success'] == 'false') return;

		int amt = map['amt'];
		if(querySelector("#buff-quoin") != null) {
			amt *= 2;
			// TODO: implement server-side so that this amount actually gets awarded
		}
		String quoinType = map['quoinType'];

		if(quoinType == "energy" && playerMetabolics.energy + amt > playerMetabolics.max_energy) {
			amt = playerMetabolics.max_energy - playerMetabolics.energy;
		}

		if(quoinType == "mood" && playerMetabolics.mood + amt > playerMetabolics.max_mood) {
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

		switch(quoinType) {
			case "currant":
				if(amt == 1) quoinText.text = "+" + amt.toString() + " currant";
				else quoinText.text = "+" + amt.toString() + " currants";
				break;

			case "mood":
				if(amt == 0) {
					quoinText.text = "Full mood!";
					toast("You collected a mood quoin, but you already had full mood.");
				} else {
					quoinText.text = "+" + amt.toString() + " mood";
				}
				break;

			case "energy":
				if(amt == 0) {
					quoinText.text = "Full energy!";
					toast("You collected an energy quoin, but your energy tank was already full.");
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

	String get currentStreet => playerMetabolics.current_street;

	num get currentStreetX => playerMetabolics.current_street_x;

	num get currentStreetY => playerMetabolics.current_street_y;
}
