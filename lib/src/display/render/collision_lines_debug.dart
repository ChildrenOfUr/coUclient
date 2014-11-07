part of couclient;

void showLineCanvas()
{
	hideLineCanvas();

  	CanvasElement lineCanvas = new CanvasElement()
  		..classes.add("streetcanvas")
  		..style.position = "absolute"
  		..style.width = currentStreet.bounds.width.toString()+"px"
  		..style.height = currentStreet.bounds.height.toString()+"px"
  		..width = currentStreet.bounds.width
  		..height = currentStreet.bounds.height
  		..attributes["ground_y"] = currentStreet.streetData['dynamic']['ground_y'].toString()
  		..id = "lineCanvas";
  	view.layers.append(lineCanvas);

  	camera.dirty = true; //force a recalculation of any offset

  	repaint(lineCanvas);
}

void hideLineCanvas()
{
	CanvasElement lineCanvas = querySelector("#lineCanvas");
	if(lineCanvas != null)
		lineCanvas.remove();
}

void repaint(CanvasElement lineCanvas, [Platform temporary])
{
	CanvasRenderingContext2D context = lineCanvas.context2D;
  	context.clearRect(0, 0, lineCanvas.width, lineCanvas.height);
  	context.lineWidth = 3;
  	context.strokeStyle = "#ffff00";
  	context.beginPath();
  	for(Platform platform in currentStreet.platforms)
  	{
  		context.moveTo(platform.start.x, platform.start.y-1.5);
  		context.lineTo(platform.end.x, platform.end.y-1.5);
  	}
  	context.stroke();
  	context.beginPath();
  	context.strokeStyle = "#ff0000";
  	for(Platform platform in currentStreet.platforms)
  	{
  		context.moveTo(platform.start.x, platform.start.y+1.5);
  		context.lineTo(platform.end.x, platform.end.y+1.5);
  	}
  	context.stroke();
  	context.beginPath();
  	context.strokeStyle = "#000000";
  	for(Platform platform in currentStreet.platforms)
  	{
  		context.moveTo(platform.end.x, platform.end.y+5);
  		context.lineTo(platform.end.x, platform.end.y-5);
  	}
  	context.stroke();
  	context.beginPath();
  	context.strokeStyle = "#0000ff";
	for(Ladder ladder in currentStreet.ladders)
	{
		context.rect(ladder.bounds.left, ladder.bounds.top,
				ladder.bounds.width, ladder.bounds.height);
	}
	context.stroke();
	context.beginPath();
	context.strokeStyle = "#00ff00";
	context.fillStyle = "#00ff00";
	for(Wall wall in currentStreet.walls)
	{
		context.rect(wall.bounds.left, wall.bounds.top,
				wall.bounds.width, wall.bounds.height);
	}
	context.stroke();
}