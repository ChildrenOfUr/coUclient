part of couclient;

//TODO: comment the begining of files with brief descriptions as to what they do.

bool showCollisionLines = false;
DateTime now, lastUpdate = new DateTime.now();

// Our renderloop
render() {
	if(serverDown) {
		return;
	}

	//Draw Street
	if(currentStreet is Street)
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

	//update minimap
	minimap.updateObjects();
	// update gps
	gpsIndicator.update();
}