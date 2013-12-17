part of coUclient;

/*
 * SpriteCache decoCache = new SpriteCache();
	List<Future> futures = new List<Future>();
	
	for(Map deco in _data['dynamic']['layers']['middleground']['decos'])
	{
		decoCache.add(deco['filename']);
		futures.add(decoCache.recent.onLoad.first);
	}
	
	Future.wait(futures).then((_) //load all elements of the street before drawing to canvas
	{
	});
 */
class SpriteCache
{
	CanvasElement spriteSheet;
	Map<String,Sprite> cachedSprites;
	ImageElement recent;
	
	SpriteCache()
	{
		spriteSheet = new CanvasElement();
		cachedSprites = new Map<String,Sprite>();
	}
	
	bool _contains(String filename)
	{
		return cachedSprites.containsKey(filename);
	}
	
	void add(String filename)
	{
		if(_contains(filename))
		  return;
	  
		// for now we'll piggyback off of revdancatt's work. :P
		ImageElement source = new ImageElement()
			..src = 'http://revdancatt.github.io/CAT422-glitch-location-viewer/img/scenery/' + filename + '.png';
		
		source.onLoad.listen((Event e)
		{
			Rectangle bestFit = _getBestFitRect(source);
			Sprite sprite = new Sprite(bestFit.left,bestFit.top,source.width,source.height);
			spriteSheet.context2D.drawImageToRect(source, bestFit);
			cachedSprites[filename] = sprite;
		});
		
		recent = source;
	}
	
	Rectangle _getBestFitRect(ImageElement source)
	{
		//TODO: This is a naieve algorithm that simply stacks each sprite underneath the previous in a long column
		//This will leave wasted space if the sprites are not of similar width and therefore waste memory with a larger canvas than needed
		//Reimplementing this using a variation of the packing problem will save memory
	
		if(spriteSheet.width < source.width)
			spriteSheet.width = source.width;
		
		int nextY = spriteSheet.height + 1;
		spriteSheet.height += source.height;
				
		CanvasRenderingContext2D ctx = spriteSheet.context2D;
		return new Rectangle(0,nextY,source.width,source.height);
	}
	
	/**
	 * Returns a [Rectangle] objecct representing the sprite's bounds within this cache's [CanvasElement]
	 * 
	 * Returns null if the sprite referenced by the filename has not already been added or is no longer present
	 */
	Rectangle getSpriteBounds(String filename)
	{
		if(cachedSprites[filename] == null)
			return null;
		
		num x = cachedSprites[filename].x, y = cachedSprites[filename].y;
		num width = cachedSprites[filename].width, height = cachedSprites[filename].height;
		return new Rectangle(x,y,width,height);
	}
}

class Sprite
{
	num x,y,width,height;
	
	Sprite(this.x,this.y,this.width,this.height);
}