part of couclient;

/**
 *
 * This class will be responsible for querying the database and writing back to it
 * with the details of the player (currants, mood, etc.)
 *
**/

MetabolicsService metabolics = new MetabolicsService();

class Metabolics
{
	@Field()
	int id;

	@Field()
	int mood = 50;

	@Field()
	int max_mood = 100;

	@Field()
	int energy = 50;

	@Field()
	int max_energy = 100;

	@Field()
	int currants = 0;

	@Field()
	int img = 0;

	@Field()
	int lifetime_img = 0;

	@Field()
	String current_street = 'LA58KK7B9O522PC';

	@Field()
	num current_street_x = 1.0;

	@Field()
	num current_street_y = 0.0;

	@Field()
	int user_id = -1;
}

class MetabolicsService
{
	Metabolics metabolics;
	DateTime lastUpdate, nextUpdate;
	String url = 'ws://$websocketServerAddress/metabolics';

	void init(Metabolics m)
	{
		metabolics = m;
		view.meters.updateAll();

		setupWebsocket();
	}

	setupWebsocket()
	{
		//establish a websocket connection to listen for metabolics objects coming in
		WebSocket socket = new WebSocket(url);
		socket.onOpen.listen((_) => socket.send(JSON.encode({'username':game.username})));
		socket.onMessage.listen((MessageEvent event)
		{
			Map map = JSON.decode(event.data);
			if(map['collectQuoin'] != null)
				collectQuoin(map);
			else
				metabolics = decode(JSON.decode(event.data),Metabolics);
			update();
		});
		socket.onClose.listen((CloseEvent e)
		{
			//print('socket closed: ${e.reason}');
            //wait 5 seconds and try to reconnect
            new Timer(new Duration(seconds: 5), () => setupWebsocket());
		});
	}

	update() => view.meters.updateAll();

	void collectQuoin(Map map)
	{
		Element element = querySelector('#${map['id']}');
		element.attributes['checking'] = 'false';

		if(map['success'] == 'false')
			return;

		int amt = map['amt'];
		String quoinType = map['quoinType'];

		element.attributes['collected'] = "true";

		Element quoinText = querySelector("#qq"+element.id+" .quoinString");

		switch (quoinType)
		{
			case "currant" :
				if (amt == 1)
					quoinText.text = "+" + amt.toString() + " currant";
				else
					quoinText.text = "+" + amt.toString() + " currants";
				break;

			case "mood" :
				quoinText.text = "+" + amt.toString() + " mood";
				break;

			case "energy" :
				quoinText.text = "+" + amt.toString() + " energy";
				break;

			case "quarazy" :
			case "img" :
				quoinText.text = "+" + amt.toString() + " iMG";
				break;

			case "favor" :
				// TODO : add code for favor
				break;

			case "time" :
				// TODO : what DOES time do?
				break;
		}
	}

	int getCurrants() => metabolics.currants;

	int getEnergy() => metabolics.energy;

	int getMaxEnergy() => metabolics.max_energy;

	int getMood() => metabolics.mood;

	int getMaxMood() => metabolics.max_mood;

	int getImg() => metabolics.img;

	String getCurrentStreet() => metabolics.current_street;

	num getCurrentStreetX() => metabolics.current_street_x;

	num getCurrentStreetY() => metabolics.current_street_y;
}
