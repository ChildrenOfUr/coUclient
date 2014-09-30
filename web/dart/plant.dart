part of coUclient;

class Plant extends Entity
{
	int state, width, height, numRows, numColumns;
	num x,y;
	bool ready = false, firstRender = true;
	ImageElement spritesheet;
	Rectangle sourceRect;
	String url;

	Plant(Map map)
	{
		canvas = new CanvasElement();
        canvas.id = map["id"];

		numRows = map['numRows'];
		numColumns = map['numColumns'];

		List<int> frameList = [];
		for(int i=0; i<map['numFrames']; i++)
			frameList.add(i);

		url = map['url'].replaceAll("\"","");
		HttpRequest.request('http://localhost:8181/getActualImageHeight?url=$url&numRows=$numRows&numColumns=$numColumns').then((HttpRequest request)
		{
			canvas.attributes['actualHeight'] = request.responseText;
		});
		spritesheet = new ImageElement(src:url);
		spritesheet.onLoad.listen((_)
		{
			width = spritesheet.width~/map['numColumns'];
			height = spritesheet.height~/map['numRows'];
			x = num.parse(map['x'].toString());
            y = currentStreet.bounds.height - num.parse(map['y'].toString()) - height;

        	canvas.attributes['actions'] = JSON.encode(map['actions']);
        	canvas.attributes['type'] = map['type'];
        	canvas.classes.add("plant");
        	canvas.classes.add('entity');
        	canvas.style.zIndex = (-1).toString(); //make sure plants are behind animals
        	canvas.width = width;
        	canvas.height = height;
        	canvas.style.position = "absolute";
        	canvas.style.transform = "translateX(${x}px) translateY(${y}px)";
        	canvas.attributes['translatex'] = x.toString();
        	canvas.attributes['translatey'] = y.toString();
        	canvas.attributes['width'] = width.toString();
        	canvas.attributes['height'] = height.toString();
    		state = map['state'];
        	playerHolder.append(canvas);
        	sourceRect = new Rectangle(0,0,width,height);
        	ready = true;
		});
	}

	updateState(int newState)
	{
		state = newState;
		dirty = true;
	}

	updateGlow(bool newGlow)
	{
		glow = newGlow;
		dirty = true;
	}

	update(double dt)
	{
		if(!ready)
			return;

		int column = state%numColumns;
        int row = state~/numColumns;

		sourceRect = new Rectangle(column*width,row*height,width,height);
	}

	render()
	{
		if(ready && dirty)
		{
			if(!firstRender)
			{
				num left = num.parse(canvas.attributes['translatex'].replaceAll("px", ""));
        		num top = num.parse(canvas.attributes['translatey'].replaceAll("px", ""));
        		Rectangle plantRect = new Rectangle(left,top,canvas.width,canvas.height);

        		if(!intersect(camera.visibleRect,plantRect))
        			return;
			}

			//fastest way to clear a canvas (without using a solid color)
			//source: http://jsperf.com/ctx-clearrect-vs-canvas-width-canvas-width/6
			canvas.context2D.clearRect(0, 0, width, height);

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

    		Rectangle destRect = new Rectangle(0,0,width,height);
    		canvas.context2D.drawImageToRect(spritesheet, destRect, sourceRect: sourceRect);

    		dirty = false;
    		firstRender = false;
		}
	}
}