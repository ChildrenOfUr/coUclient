part of couclient;

class Door extends Entity {
	ImageElement spritesheet;
	Rectangle sourceRect;
	bool ready = false, firstRender = true;

	Door(Map map) {
		canvas = new CanvasElement();
		canvas.id = map["id"];
		id = map['id'];
		String url = map['url'];
		num x = map['x'], y = map['y'];

		spritesheet = new ImageElement(src:url);
		spritesheet.onLoad.listen((_) {
			width = spritesheet.width ~/ map['numColumns'];
			height = spritesheet.height ~/ map['numRows'];
			x = num.parse(map['x'].toString());
			y = num.parse(map['y'].toString()) - height;
			left = x;
			top = y;

			canvas.attributes['actions'] = JSON.encode(map['actions']);
			canvas.attributes['type'] = map['type'];
			canvas.classes.add("door");
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
			view.playerHolder.append(canvas);
			sourceRect = new Rectangle(0,0,width,height);
			ready = true;
		});
	}

	@override
	void render() {
		if(ready && dirty) {
			if(!firstRender) {
				if(!intersect(camera.visibleRect, entityRect))
					return;
			}

			firstRender = false;

			//fastest way to clear a canvas (without using a solid color)
			//source: http://jsperf.com/ctx-clearrect-vs-canvas-width-canvas-width/6
			canvas.context2D.clearRect(0, 0, width, height);

			if(glow) {
				//canvas.context2D.shadowColor = "rgba(0, 0, 255, 0.2)";
				canvas.context2D.shadowBlur = 20;
				canvas.context2D.shadowColor = 'cyan';
				canvas.context2D.shadowOffsetX = 0;
				canvas.context2D.shadowOffsetY = 1;
			}
			else {
				canvas.context2D.shadowColor = "0";
				canvas.context2D.shadowBlur = 0;
				canvas.context2D.shadowOffsetX = 0;
				canvas.context2D.shadowOffsetY = 0;
			}

			canvas.context2D.drawImageToRect(spritesheet, destRect, sourceRect: sourceRect);
			dirty = false;
		}
	}
}