part of couclient;

class Quoin
{
	Map <String,int> quoins = {"img":0,"mood":1,"energy":2,"currant":3,"mystery":4,"favor":5,"time":6,"quarazy":7};
	Animation animation;
	bool ready = false, firstRender = true;
	CanvasElement canvas;
	
	Quoin(Map map)
	{
		String typeString = map['type'];
		String id = map["id"];
		int quoinValue = quoins[typeString.toLowerCase()];
		
		List<int> frameList = [];
		for(int i=0; i<24; i++)
			frameList.add(quoinValue*24+i);
		
		animation = new Animation(map['url'],typeString.toLowerCase(),8,24,frameList,fps:22)
			..load().then((_)
			{
				canvas = new CanvasElement();
				canvas.width = animation.width;
				canvas.height = animation.height;
                canvas.id = id;
                canvas.className = map['type'] + " quoin";
                canvas.style.position = "absolute";
                canvas.style.left = map['x'].toString()+"px";
                canvas.style.bottom = map['y'].toString()+"px";
                canvas.style.transform = "translateZ(0)";
                canvas.attributes['collected'] = "false";
                
            	DivElement element = new DivElement();
            	DivElement circle = new DivElement()
            		..id = "q"+id
            		..className = "circle"
            		..style.position = "absolute"
            		..style.left = map["x"].toString()+"px"
            		..style.bottom = map["y"].toString()+"px";
            	DivElement parent = new DivElement()
            		..id = "qq"+id
            		..className = "parent"
            		..style.position = "absolute"
            		..style.left = map["x"].toString()+"px"
            		..style.bottom = map["y"].toString()+"px";
            	DivElement inner = new DivElement();
            	inner.className = "inner";
            	DivElement content = new DivElement();
            	content.className = "quoinString";
            	parent.append(inner);
            	inner.append(content);
            	
            	querySelector("#PlayerHolder")
            		..append(canvas)
            		..append(circle)
            		..append(parent);
            	
            	ready = true;
			});
	}
	
	update(double dt)
	{
		if(!ready)
			return;
		
		animation.updateSourceRect(dt);
	}
	
	render()
	{
		if(ready && animation.dirty && canvas.attributes['collected'] == "false")
		{
			if(!firstRender)
			{
				//if the entity is not visible, don't render it
				num left = num.parse(canvas.style.left.replaceAll("px", ""));
	  			num top = currentStreet.bounds.height - num.parse(canvas.style.bottom.replaceAll("px", "")) - canvas.height;
	  			Rectangle quoinRect = new Rectangle(left,top,canvas.width,canvas.height);
				if(!intersect(camera.visibleRect,quoinRect))
					return;
			}
			
			firstRender = false;
			
			//fastest way to clear a canvas (without using a solid color)
			//source: http://jsperf.com/ctx-clearrect-vs-canvas-width-canvas-width/6
			canvas.context2D.clearRect(0, 0, animation.width, animation.height);
			
    		Rectangle destRect = new Rectangle(0,0,animation.width,animation.height);
    		canvas.context2D.drawImageToRect(animation.spritesheet, destRect, sourceRect: animation.sourceRect);
    		animation.dirty = false;
		}
	}
}