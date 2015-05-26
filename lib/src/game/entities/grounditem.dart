part of couclient;

class GroundItem extends Entity
{
	GroundItem(Map map)
	{
		ImageElement item = new ImageElement(src:map['iconUrl']);
    	item.onLoad.first.then((_)
    	{
		    left = map['x'];
		    top = map['y'];
		    width = item.width;
		    height = item.height;
		    id = map['id'];

    		item.style.transform = "translateX(${map['x']}px) translateY(${map['y']}px)";
    		item.style.position = "absolute";
        	item.attributes['translatex'] = map['x'].toString();
        	item.attributes['translatey'] = map['y'].toString();
        	item.attributes['width'] = item.width.toString();
            item.attributes['height'] = item.height.toString();
        	item.attributes['type'] = map['name'];
        	item.attributes['actions'] = JSON.encode(map['actions']);
        	item.classes.add('groundItem');
        	item.classes.add('entity');
        	item.id = map['id'];
        	view.playerHolder.append(item);
    	});
	}

	render(){}
}