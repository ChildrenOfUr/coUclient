part of couclient;

class NPC
{
	int speed;
	CanvasElement canvas;
	bool ready = false, facingRight = true, glow = false;
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
        	canvas.classes.add("npc");
        	canvas.width = map["width"];
        	canvas.height = map["height"];
        	canvas.style.position = "absolute";
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
		}
	}
	
	render()
	{
		if(ready && animation.dirty)
		{
			canvas.width = canvas.width;
    		Rectangle destRect = new Rectangle(0,0,animation.width,animation.height);
    		canvas.context2D.drawImageToRect(animation.spritesheet, destRect, sourceRect: animation.sourceRect);
    		animation.dirty = false;
		}
	}
}