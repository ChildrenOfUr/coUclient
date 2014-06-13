part of coUclient;

class Quoins 
{
	final int _value;
	final String _name;
	const Quoins._internal(this._value,this._name);
	toString() => 'Quoin.$_name';
	
	static const IMG = const Quoins._internal(0,"img");
	static const MOOD = const Quoins._internal(1,"mood");
	static const ENERGY = const Quoins._internal(2,"energy");
	static const CURRANT = const Quoins._internal(3,"currant");
	static const MYSTERY = const Quoins._internal(4,"mystery");
	static const FAVOR = const Quoins._internal(5,"favor");
	static const TIME = const Quoins._internal(6,"time");
	static const QUARAZY = const Quoins._internal(7,"quarazy");
}

class Quoin
{
	Animation animation;
	bool ready = false;
	CanvasElement canvas;
	
	Quoin(Map map)
	{
		String typeString = map['type'];
		String id = map["id"];
		Quoins type;
		if(typeString == "img")
			type = Quoins.IMG;
		else if(typeString == "mood")
			type = Quoins.MOOD;
		else if(typeString == "energy")
			type = Quoins.ENERGY;
		else if(typeString == "currant")
			type = Quoins.CURRANT;
		
		List<int> frameList = [];
		for(int i=0; i<24; i++)
			frameList.add(type._value*24+i);
		
		animation = new Animation(map['url'],type._name,8,24,frameList,fps:22)
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
		if(ready && animation.dirty)
		{
			canvas.width = canvas.width;
    		Rectangle destRect = new Rectangle(0,0,animation.width,animation.height);
    		canvas.context2D.drawImageToRect(animation.spritesheet, destRect, sourceRect: animation.sourceRect);
    		animation.dirty = false;
		}
	}
}