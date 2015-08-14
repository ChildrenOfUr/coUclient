part of couclient;

class Plant extends GlowingEntity {
	int state = 0, numRows, numColumns, numFrames;
	num x, y;
	bool ready = false;

	Rectangle sourceRect;
	String url;
	SpriteSheet spritesheet;
	xl.Sprite displayObject;
	xl.Bitmap bitmap;

	Plant(Map map) {
		displayObject = new xl.Sprite();
		canvas = new CanvasElement();
		canvas.id = map["id"];
		id = map['id'];

		numRows = map['numRows'];
		numColumns = map['numColumns'];
		numFrames = map['numFrames'];

		url = map['url'].replaceAll("\"", "");
		if (!entityResourceManger.containsBitmapData(url)) {
			entityResourceManger.addBitmapData(url, url, loadOptions);
			entityResourceManger.load().then((_) {
				xl.BitmapData data = entityResourceManger.getBitmapData(url);
				spritesheet = new SpriteSheet(data, data.width ~/ numColumns, data.height ~/ numRows, frameCount:numFrames);
				bitmap = new xl.Bitmap();
				bitmap.bitmapData = spritesheet[state];
				width = bitmap.width;
				height = bitmap.height;
				displayObject.addChild(bitmap);
				x = map['x'];
				y = currentStreet.bounds.height - map['y'] - height;
				left = x;
				top = y;
				displayObject.x = x;
				displayObject.y = y;
				currentStreet.interactionLayer.addChild(displayObject);
				currentStreet.interactionLayer.addEntity(this);
				ready = true;
			});
		}

		canvas.attributes['actions'] = JSON.encode(map['actions']);
		canvas.attributes['type'] = map['type'];
		canvas.classes.add("plant");
		canvas.classes.add('entity');
		canvas.style.position = "absolute";
		canvas.style.visibility = "hidden";
		state = map['state'];
		view.playerHolder.append(canvas);
	}

	@override
	render(){}

	updateState(int newState) {
		state = newState;
		bitmap.bitmapData = spritesheet[state];
		dirty = true;
	}
}