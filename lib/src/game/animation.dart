part of couclient;

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
	bool dirty = true, delayInitially = false, paused = false, loaded = false, loops;

	Animation(this.url,this.animationName,this.numRows,this.numColumns,this.frameList,{this.fps : 30, this.loopDelay : null, this.delayInitially : false, this.loops : true});

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
		spritesheet = new ImageElement(src: url.replaceAll("\"", ""));
		spritesheet.onLoad.listen((_)
		{
			width = spritesheet.width~/numColumns;
			height = spritesheet.height~/numRows;

			sourceRect = new Rectangle(0,0,width,height);

			loaded = true;
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
		paused = false;
	}

	updateSourceRect(double dt, {bool holdAtLastFrame: false})
	{
		if(paused || !loaded)
			return;

		timeInMillis += dt;
		delayConsumed += dt*1000;

		if(timeInMillis > 1/fps && delayConsumed >= loopDelay.inMilliseconds)
		{
			//advance the frame cycling around if necessary
			if(frameNum >= frameList.length -1 && (holdAtLastFrame || !loops))
				frameNum = frameList.length -1;
			else
			{
				int oldFrame = frameNum;
				frameNum = (frameNum + timeInMillis~/(1/fps)) % frameList.length;
                timeInMillis = 0.0;

                if(oldFrame != frameNum)
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