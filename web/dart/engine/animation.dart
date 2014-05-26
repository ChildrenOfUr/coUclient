part of coUclient;

class Animation
{
	String url, animationName, animationStyleString;
	int width, height, numRows, numColumns, numFrames, columnOffset = 0, rowOffset = 0, fps;
	ImageElement spritesheet;
	double timeInMillis = 0.0;
	Rectangle sourceRect;
	bool dirty = false;
	
	Animation(this.url,this.animationName,this.numRows,this.numColumns,{this.numFrames : -1,this.fps : 30})
	{
		if(numFrames == -1)
        	numFrames = numRows * numColumns;
	}
	
	Future<Animation> load()
	{
		Completer c = new Completer();
		
		//need to get the avatar background image size dynamically
		//because we cannot guarentee that every glitchen has the same dimensions
		//additionally each animation sprite has different dimensions even for the same glitchen
		spritesheet = new ImageElement(src: url);
		spritesheet.onLoad.listen((_)
		{
			width = spritesheet.width~/numColumns;
			height = spritesheet.height~/numRows;
			
			c.complete(this);
		});
		
		return c.future;
	}
	
	updateSourceRect(double dt)
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
			
			timeInMillis = 0.0;
			dirty = true;
		}
		
		sourceRect = new Rectangle(columnOffset*width,rowOffset*height,width,height);
	}
}