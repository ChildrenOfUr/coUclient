part of coUclient;

class NPC
{
	static Random rand = new Random();
	int numRows, numColumns, numFrames, columnOffset = 0, rowOffset = 0, fps, speed;
	ImageElement img;
	CanvasElement canvas;
	Rectangle destRect, sourceRect;
	bool dirty = true, facingRight = true, glow = false;
	double timeInMillis = 0.0;
	
	NPC(this.canvas,this.img,this.numRows,this.numColumns,{this.numFrames : -1,this.fps : 30,this.speed : 150})
	{
		if(numFrames == -1)
			numFrames = numRows * numColumns;
		
		destRect = new Rectangle(0,0,canvas.width,canvas.height);
		sourceRect = new Rectangle(columnOffset,rowOffset,canvas.width,canvas.height);
	}
	
	resetImage(ImageElement i, Map map)
	{
		img = i;
		numRows = map["numRows"];
		numColumns = map["numColumns"];
		numFrames = map["numFrames"];
		rowOffset = 0;
		columnOffset = 0;
		facingRight = map["facingRight"];
	}
	
	update(double dt)
	{
		timeInMillis += dt;
		if(timeInMillis > 1/fps)
		{
			if(numFrames < numColumns*numRows && rowOffset == numRows-1)
			{
				int deficit = numColumns*numRows - numFrames;
				if(columnOffset == numColumns-deficit-1)
				{
					columnOffset = 0;
					rowOffset = 0;
				}
				else
					columnOffset++;
			}
			else if(columnOffset == numColumns-1 && rowOffset == numRows-1)
			{
				columnOffset = 0;
				rowOffset = 0;
			}
			else if(columnOffset == numColumns-1)
			{
				columnOffset = 0;
				rowOffset++;
			}
			else if(columnOffset < numColumns-1)
				columnOffset++;
			
			if(img.src.contains("walk"))
			{
				double posX = double.parse(canvas.style.left.replaceAll("px", ""));
				if(facingRight)
					posX += speed*dt;
				else
					posX -= speed*dt;
				
				if(posX < 0)
					posX = 0.0;
				if(posX > currentStreet.bounds.width-canvas.width)
					posX = (currentStreet.bounds.width-canvas.width).toDouble();
				
				canvas.style.left = posX.toString()+"px";
				
				if(facingRight)
    				canvas.style.transform = "scale(1,1) translateZ(0)";
    			else
    				canvas.style.transform = "scale(-1,1) translateZ(0)";
			}
			sourceRect = new Rectangle(columnOffset*canvas.width,rowOffset*canvas.height,canvas.width,canvas.height);
			dirty = true;
			timeInMillis = 0.0;
		}
	}
	
	render()
	{
		if(dirty)
		{
			canvas.context2D.clearRect(0, 0, canvas.width, canvas.height);
			if(glow)
			{
				canvas.context2D.shadowColor = "rgba(0, 0, 255, 0.2)";
				canvas.context2D.shadowBlur = 20;
				canvas.context2D.shadowOffsetX = 0;
				canvas.context2D.shadowOffsetY = -5;
			}
			else
			{
				canvas.context2D.shadowColor = "0";
				canvas.context2D.shadowBlur = 0;
				canvas.context2D.shadowOffsetX = 0;
				canvas.context2D.shadowOffsetY = 0;
			}
			canvas.context2D.drawImageToRect(img, destRect, sourceRect: sourceRect);
            dirty = false;
		}
	}
}