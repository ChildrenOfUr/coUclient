part of couclient;

//TODO: comment the begining of files with brief descriptions as to what they do.

NumberFormat twoDigit = new NumberFormat("#0");
bool showCollisionLines = false;

DateTime now, lastUpdate = new DateTime.now();

// The higher this value, the less the FPS will be affected by quick changes
// Setting this to 1 will show you the FPS of the last sampled frame only
num fpsFilter = 50;

// Our renderloop
render()
{
	//Draw Street
	if (currentStreet is Street)
		currentStreet.render();
	//Draw Player
	if(CurrentPlayer is Player)
		CurrentPlayer.render();

	//draw quoins
	quoins.forEach((String id, Quoin quoin) => quoin.render());

	//draw entites
	entities.forEach((String id, Entity entity) => entity.render());

	//draw other players
	otherPlayers.forEach((String name, Player player) => player.render());
}