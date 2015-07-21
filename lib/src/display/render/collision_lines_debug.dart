part of couclient;

CanvasRenderingContext2D lineCanvasContext;
MutableRectangle previousPlayerRect;

void showLineCanvas() {
	hideLineCanvas();

	CanvasElement lineCanvas = new CanvasElement()
		..classes.add("streetcanvas")
		..style.position = "absolute"
		..style.width = currentStreet.bounds.width.toString() + "px"
		..style.height = currentStreet.bounds.height.toString() + "px"
		..width = currentStreet.bounds.width
		..height = currentStreet.bounds.height
		..attributes["ground_y"] = currentStreet.groundY.toString()
		..id = "lineCanvas";
	view.layers.append(lineCanvas);

	camera.dirty = true; //force a recalculation of any offset

	repaint(lineCanvas);
}

void hideLineCanvas() {
	CanvasElement lineCanvas = querySelector("#lineCanvas");
	if (lineCanvas != null)
		lineCanvas.remove();
}

void repaint(CanvasElement lineCanvas, [Platform temporary]) {
	lineCanvasContext = lineCanvas.context2D;
	lineCanvasContext.clearRect(0, 0, lineCanvas.width, lineCanvas.height);
	lineCanvasContext.lineWidth = 3;
	lineCanvasContext.strokeStyle = "#ffff00";
	lineCanvasContext.beginPath();
	for (Platform platform in currentStreet.platforms) {
		lineCanvasContext.moveTo(platform.start.x, platform.start.y - 1.5);
		lineCanvasContext.lineTo(platform.end.x, platform.end.y - 1.5);
	}
	lineCanvasContext.stroke();
	lineCanvasContext.beginPath();
	lineCanvasContext.strokeStyle = "#ff0000";
	for (Platform platform in currentStreet.platforms) {
		lineCanvasContext.moveTo(platform.start.x, platform.start.y + 1.5);
		lineCanvasContext.lineTo(platform.end.x, platform.end.y + 1.5);
	}
	lineCanvasContext.stroke();
	lineCanvasContext.beginPath();
	lineCanvasContext.strokeStyle = "#000000";
	for (Platform platform in currentStreet.platforms) {
		lineCanvasContext.moveTo(platform.end.x, platform.end.y + 5);
		lineCanvasContext.lineTo(platform.end.x, platform.end.y - 5);
	}
	lineCanvasContext.stroke();
	lineCanvasContext.beginPath();
	lineCanvasContext.strokeStyle = "#0000ff";
	for (Ladder ladder in currentStreet.ladders) {
		lineCanvasContext.rect(ladder.bounds.left, ladder.bounds.top,
		                       ladder.bounds.width, ladder.bounds.height);
	}
	lineCanvasContext.stroke();
	lineCanvasContext.beginPath();
	lineCanvasContext.strokeStyle = "#00ff00";
	lineCanvasContext.fillStyle = "#00ff00";
	for (Wall wall in currentStreet.walls) {
		lineCanvasContext.rect(wall.bounds.left, wall.bounds.top,
		                       wall.bounds.width, wall.bounds.height);
	}
	lineCanvasContext.stroke();
}

showPlayerRect() {
	if (lineCanvasContext == null || CurrentPlayer == null || currentStreet == null) {
		return;
	}
	if (previousPlayerRect != null) {
		lineCanvasContext.clearRect(previousPlayerRect.left, previousPlayerRect.top,
		                            previousPlayerRect.width, previousPlayerRect.height);
	}
	Rectangle playerRect;
	if(CurrentPlayer.facingRight) {
		playerRect = new Rectangle(CurrentPlayer.posX + CurrentPlayer.width / 2,
		                           CurrentPlayer.posY + currentStreet.groundY + 15,
		                           CurrentPlayer.width / 2, CurrentPlayer.height - 35);
	} else {
		playerRect = new Rectangle(CurrentPlayer.posX,
		                           CurrentPlayer.posY + currentStreet.groundY + 15,
		                           CurrentPlayer.width / 2, CurrentPlayer.height - 35);
	}

	lineCanvasContext.beginPath();
	lineCanvasContext.strokeStyle = "#ffffff";
	lineCanvasContext.rect(playerRect.left, playerRect.top, playerRect.width, playerRect.height);
	lineCanvasContext.stroke();

	if (previousPlayerRect == null) {
		previousPlayerRect = new MutableRectangle(playerRect.left, playerRect.top,
		                                          playerRect.width, playerRect.height);
	} else {
		previousPlayerRect.left = playerRect.left;
		previousPlayerRect.top = playerRect.top;
		previousPlayerRect.width = playerRect.width;
		previousPlayerRect.height = playerRect.height;
	}
}