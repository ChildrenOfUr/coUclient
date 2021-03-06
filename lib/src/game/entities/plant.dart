part of couclient;

class Plant extends Entity {
	int state, numRows, numColumns;
	num x, y;
	bool ready = false, firstRender = true;
	ImageElement spritesheet;
	Rectangle sourceRect;
	String url;

	Plant(Map map) {
		if (map.containsKey('actions')) {
			actions = decodeJsonArray(map['actions'], (json) => Action.fromJson(json));
		}

		canvas = new CanvasElement();
		canvas.id = map["id"];
		id = map['id'];

		numRows = map['numRows'];
		numColumns = map['numColumns'];

		List<int> frameList = [];
		for(int i = 0; i < map['numFrames']; i++) {
			frameList.add(i);
		}

		url = map['url'].replaceAll("\"", "");
		HttpRequest.request('${Configs.http}//${Configs.utilServerAddress}/getActualImageHeight?url=$url&numRows=$numRows&numColumns=$numColumns').then((HttpRequest request) {
			canvas.attributes['actualHeight'] = request.responseText;
		});
		spritesheet = new ImageElement(src:url);
		spritesheet.onLoad.listen((_) {
			width = spritesheet.width ~/ map['numColumns'];
			height = spritesheet.height ~/ map['numRows'];
			x = num.parse(map['x'].toString());
			y = num.parse(map['y'].toString()) - height;
			z = num.parse(map['z'].toString());
			rotation = num.parse((map['rotation'] ?? 0).toString());
			h_flip = map['h_flip'].toString() == 'true';
			left = x;
			top = y;

			canvas.attributes['actions'] = jsonEncode(map['actions']);
			canvas.attributes['type'] = map['type'];
			canvas.classes.add("plant");
			canvas.classes.add('entity');
			canvas.style.zIndex = z.toString();
			canvas.width = width;
			canvas.height = height;
			canvas.style.position = "absolute";
			canvas.style.transform = "rotate(${rotation}deg) translateX(${x}px) translateY(${y}px)" + (h_flip ? 'scale3d(-1,1,1)' : 'scale3d(1,1,1)');
			canvas.attributes['translatex'] = x.toString();
			canvas.attributes['translatey'] = y.toString();
			canvas.attributes['width'] = width.toString();
			canvas.attributes['height'] = height.toString();
			state = map['state'];
			view.playerHolder.append(canvas);
			sourceRect = new Rectangle(0, 0, width, height);
			ready = true;
			addingLocks[id] = false;
		});
	}

	updateState(int newState) {
		state = newState;
		dirty = true;
	}

	@override
	update(double dt) {
		if(!ready)
			return;

		super.update(dt);

		int column = state % numColumns;
		int row = state ~/ numColumns;

		sourceRect = new Rectangle(column * width, row * height, width, height);
	}

	@override
	render() {
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