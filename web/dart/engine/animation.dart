part of coUclient;

class Animation
{
	String url, animationName, animationStyleString;
	Duration loopDelay;
	List<int> frameList;
	int width, height, numRows, numColumns, fps;
	int frameNum = 0;
	ImageElement spritesheet;
	double timeInMillis = 0.0, delayConsumed = 0.0;
	Rectangle sourceRect;
	bool dirty = true, delayInitially = false;
	
	Animation(this.url,this.animationName,this.numRows,this.numColumns,this.frameList,{this.fps : 30, this.loopDelay : null, this.delayInitially : false});
	
	Future<Animation> load()
	{
		if(loopDelay == null)
			loopDelay = new Duration(milliseconds:0);
		
		if(!delayInitially)
			delayConsumed = loopDelay.inMilliseconds.toDouble();
		
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
	
	reset()
	{
		timeInMillis = 0.0;
		frameNum = 0;
		delayConsumed = 0.0;
		dirty = true; //will cause the first frame to be shown right away even if there is a delay of the rest of the animation (should be a good thing)
	}
	
	updateSourceRect(double dt, {bool holdAtLastFrame: false})
	{
		timeInMillis += dt;
		delayConsumed += dt*1000;
		
		if(timeInMillis > 1/fps && delayConsumed >= loopDelay.inMilliseconds)
		{
			//advance the frame cycling around if necessary
			if(frameNum >= frameList.length -1 && holdAtLastFrame)
				frameNum = frameList.length -1;
			else
			{
				frameNum = (frameNum + timeInMillis~/(1/fps)) % frameList.length;
                timeInMillis = 0.0;
                dirty = true;
                
                if(frameNum >= frameList.length -1)
                	delayConsumed = 0.0;
			}
		}
		
		int column = frameList[frameNum]%numColumns;
		int row = frameList[frameNum]~/numColumns;
		
		sourceRect = new Rectangle(column*width,row*height,width,height);
	}
}