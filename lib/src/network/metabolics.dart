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

DateTime lastServerUpdate, nextServerUpdate;

class MetabolicsService
{
	Metabolics metabolics;

	void init(Metabolics m)
	{
		metabolics = m;
		view.meters.updateAll();
	}

	update()
	{
		view.meters.updateAll();

		//to prevent server overload, only update it once every 5 seconds at most
		if(lastServerUpdate == null || nextServerUpdate == null || nextServerUpdate.compareTo(new DateTime.now()) < 0)
		{
			//save metabolics back to server
			HttpRequest.request("http://server.childrenofur.com:8181/setMetabolics?username=${game.username}",
				method: "POST", requestHeaders: {"content-type": "application/json"},
				sendData: JSON.encode(encode(metabolics)));

			lastServerUpdate = new DateTime.now();
			nextServerUpdate = lastServerUpdate.add(new Duration(seconds:5));
		}
	}

	setEnergy(int newValue)
	{
		if (newValue <= 0)
			newValue = 0;
		if (newValue > metabolics.max_energy)
			newValue = metabolics.max_energy;

		metabolics.energy = newValue;
		update();
	}

	setMaxEnergy(int newValue)
	{
		if (newValue <= 0)
			newValue = 0;
		metabolics.max_energy = newValue;
		if (metabolics.energy > metabolics.max_energy)
			metabolics.energy = metabolics.max_energy;

		update();
	}

	setMood(int newValue)
	{
		if (newValue <= 0)
			newValue = 0;
		if (newValue > metabolics.max_mood)
			newValue = metabolics.max_mood;

		metabolics.mood = newValue;

		update();
	}

	setMaxMood(int newValue)
	{
		if (newValue <= 0)
			newValue = 0;
		metabolics.max_mood = newValue;
		if (metabolics.mood > metabolics.max_mood)
			metabolics.mood = metabolics.max_mood;

		update();
	}

	setCurrants(int newValue)
	{
		if (newValue <= 0)
			newValue = 0;
		metabolics.currants = newValue;

		update();
	}

	setImg(int newValue)
	{
		if (newValue <= 0)
			newValue = 0;
		metabolics.img = newValue;

		update();
	}

	setCurrentStreet(String newValue)
	{
		metabolics.current_street = newValue;
		update();
	}

	setCurrentStreetX(num newValue)
	{
		metabolics.current_street_x = newValue;
		update();
	}

	setCurrentStreetY(num newValue)
	{
		metabolics.current_street_y = newValue;
		update();
	}

	setCurrentStreetXY(num newX, num newY)
	{
		metabolics.current_street_x = newX;
		metabolics.current_street_y = newY;
        update();
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
