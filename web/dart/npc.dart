part of coUclient;

class NPC
{
	int speed;
	CanvasElement canvas;
	bool ready = false, facingRight = true, glow = false, firstRender = true;
	double posX = 0.0, posY = 0.0;
	Animation animation;
	
	NPC(Map map,{this.speed : 75})
	{
		List<int> frameList = [];
		for(int i=0; i<map['numFrames']; i++)
			frameList.add(i);
		
		animation = new Animation(map['url'],"npc",map['numRows'],map['numColumns'],frameList);
		animation.load().then((_)
		{
			canvas = new CanvasElement();
        	canvas.id = map["id"];
        	canvas.attributes['actions'] = JSON.encode(map['actions']);
        	canvas.attributes['type'] = map['type'];
        	canvas.classes.add("npc");
        	canvas.width = map["width"];
        	canvas.height = map["height"];
        	canvas.style.position = "absolute";
        	canvas.attributes['translatex'] = posX.toString();
            canvas.attributes['translatey'] = posY.toString();
        	posX = map['x'].toDouble();
    		posY = (currentStreet.bounds.height - 170).toDouble();
        	querySelector("#PlayerHolder").append(canvas);
        	ready = true;
		});
	}
	
	update(double dt)
	{
		if(!ready)
			return;
		
		animation.updateSourceRect(dt);
		if(animation.spritesheet.src.contains("walk"))
		{
			if(facingRight)
				posX += speed*dt;
			else
				posX -= speed*dt;
							
			if(posX < 0)
				posX = 0.0;
			if(posX > currentStreet.bounds.width-canvas.width)
				posX = (currentStreet.bounds.width-canvas.width).toDouble();
			
			if(facingRight)
				canvas.style.transform = "translateX(${posX}px) translateY(${posY}px) translateZ(0) scale(1,1)";
			else
				canvas.style.transform = "translateX(${posX}px) translateY(${posY}px) translateZ(0) scale(-1,1)";
		
			canvas.attributes['translatex'] = posX.toString();
			canvas.attributes['translatey'] = posY.toString();
		}
	}
	
	render()
	{
		if(ready && animation.dirty)
		{
			if(!firstRender)
			{
				//if the entity is not visible, don't render it
				Rectangle npcRect = new Rectangle(posX,posY,canvas.width,canvas.height);
				if(!intersect(camera.visibleRect,npcRect))
					return;
			}
			
			firstRender = false;
			
			//fastest way to clear a canvas (without using a solid color)
			//source: http://jsperf.com/ctx-clearrect-vs-canvas-width-canvas-width/6
			canvas.context2D.clearRect(0, 0, animation.width, animation.height);
			
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
    		Rectangle destRect = new Rectangle(0,0,animation.width,animation.height);
    		canvas.context2D.drawImageToRect(animation.spritesheet, destRect, sourceRect: animation.sourceRect);
    		animation.dirty = false;
		}
	}
}