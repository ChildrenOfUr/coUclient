part of couclient;

double timeLast = 0.0;
String lastXY = "";

// Our gameloop
update(double dt) {
	if (serverDown) {
		return;
	}

	CurrentPlayer.update(dt);

	otherPlayers.forEach((String username, Player otherPlayer) {
//		if (otherPlayer.currentAnimation != null) {
//			otherPlayer.currentAnimation.updateSourceRect(dt);
//		}

		double x = otherPlayer.left;
		double y = otherPlayer.top;
		String transform = "translateY(${y}px) translateX(${x}px) translateZ(0)";

		if (!otherPlayer.facingRight) {
			transform += ' scale3d(-1,1,1)';
			otherPlayer.playerParentElement.classes
				..add("facing-left")
				..remove("facing-right");
			otherPlayer.playerName.style.transform = 'translateY(calc(-100% - 34px)) scale3d(-1,1,1)';

			if (otherPlayer.chatBubble != null) {
				otherPlayer.chatBubble.textElement.style.transform = 'scale3d(-1,1,1)';
			}
		} else {
			transform += ' scale3d(1,1,1)';
			otherPlayer.playerParentElement.classes
				..add("facing-right")
				..remove("facing-left");
			otherPlayer.playerName.style.transform = 'translateY(calc(-100% - 34px)) scale3d(1,1,1)';

			if (otherPlayer.chatBubble != null) {
				otherPlayer.chatBubble.textElement.style.transform = 'scale3d(1,1,1)';
			}
		}

		otherPlayer.playerParentElement.style.transform = transform;
	});

	quoins.values.forEach((Quoin quoin) => quoin.update(dt));
	entities.values.forEach((Entity entity) => entity.update(dt));
	otherPlayers.values.forEach((Player player) => player.update(dt, true));

	//update the other clients with our position & street
	timeLast += dt;
	if (timeLast > .03 && playerSocket != null && playerSocket.readyState == WebSocket.OPEN) {
		String xy = CurrentPlayer.left.toString() + "," + CurrentPlayer.top.toString();

		if (xy == lastXY && timeLast < 5) {
			// Don't send updates when the player doesn't move - except once every 5 seconds
			return;
		}

		lastXY = xy;
		sendPlayerInfo();
		timeLast = 0.0;
	}

	Wormhole.updateAll();
}
