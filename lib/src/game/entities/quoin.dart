part of couclient;

class Quoin extends Entity {
	Map <String, int> quoins = {"img":0, "mood":1, "energy":2, "currant":3, "mystery":4, "favor":5, "time":6, "quarazy":7};
	String typeString;
	bool ready = false, _collected = false, checking = false, hit = false;
//	DivElement circle, parent;
	Rectangle quoinRect;
	xl.FlipBook flipbook;
	xl.Sprite circle;

	void set collected(bool value) {
		_collected = value;
		if(value) {
			flipbook.removeFromParent();
			currentStreet.stage.juggler.remove(this);
			currentStreet.stage.juggler.remove(flipbook);
		} else {
			currentStreet.stage.juggler.add(flipbook);
			currentStreet.stage.juggler.add(this);
			currentStreet.interactionLayer.addEntity(this);
		}
	}

	bool get collected => _collected;

	Quoin(Map map) {
		canvas = new CanvasElement();
		canvas.id = map["id"];
		init(map);
	}

	init(Map map) async	{
		typeString = map['type'];

		// Disable mystery quoins
		if (typeString == "mystery") {
			return;
		}

		// Don't show Quarazy Quoins more than once for a street
		if (typeString == "quarazy") {
			if (!metabolics.load.isCompleted) {
				await metabolics.load.future;
			}
			if (metabolics.location_history.contains(currentStreet.tsid_g)) {
				return;
			}
		}

		id = map["id"];
		int quoinValue = quoins[typeString.toLowerCase()];

		String url = map['url'];

		if (!entityResourceManger.containsBitmapData(url)) {
			entityResourceManger.addBitmapData(url, url, loadOptions);
			await entityResourceManger.load();
			xl.BitmapData data = entityResourceManger.getBitmapData(url);
			SpriteSheet spritesheet = new SpriteSheet(data, data.width ~/ 24, data.height ~/ 8);
			List<xl.BitmapData> frames = [];
			for(int i=0; i<24; i++) {
				frames.add(spritesheet[quoinValue*24+i]);
			}
			flipbook = new xl.FlipBook(frames,22)
				..addTo(currentStreet.interactionLayer)
				..play();

			currentStreet.stage.juggler.add(flipbook);
			currentStreet.interactionLayer.addEntity(this);

			width = flipbook.width;
			height = flipbook.height;
			left = map['x'];
			top = currentStreet.bounds.height - map['y'] - height;
			quoinRect = new Rectangle(left, top, width, height);

			flipbook.x = left - camera.x;
			flipbook.y = top - camera.y;

			ready = true;
		}

		canvas.attributes['actions'] = JSON.encode(map['actions']);
		canvas.attributes['type'] = map['type'];
		canvas.attributes['collected'] = "false";
		canvas.classes.add("plant");
		canvas.classes.add('entity');
		canvas.style.position = "absolute";
		canvas.style.visibility = "hidden";
		view.playerHolder.append(canvas);

//		animation = new Animation(map['url'], typeString.toLowerCase(), 8, 24, frameList, fps:22);
//		await animation.load();
//
//		canvas = new CanvasElement();
//		canvas.width = animation.width;
//		canvas.height = animation.height;
//		canvas.id = id;
//		canvas.className = map['type'] + " quoin";
//		canvas.style.position = "absolute";
//		canvas.style.left = map['x'].toString() + "px";
//		canvas.style.bottom = map['y'].toString() + "px";
//		canvas.style.transform = "translateZ(0)";
//		canvas.attributes['collected'] = "false";
//
//		left = map['x'];
//		top = currentStreet.bounds.height - map['y'] - canvas.height;
//
//		circle = new DivElement()
//			..id = "q" + id
//			..className = "circle"
//			..style.position = "absolute"
//			..style.left = map["x"].toString() + "px"
//			..style.bottom = map["y"].toString() + "px";
//		parent = new DivElement()
//			..id = "qq" + id
//			..className = "parent"
//			..style.position = "absolute"
//			..style.left = map["x"].toString() + "px"
//			..style.bottom = map["y"].toString() + "px";
//		DivElement inner = new DivElement();
//		inner.className = "inner";
//		DivElement content = new DivElement();
//		content.className = "quoinString";
//		parent.append(inner);
//		inner.append(content);
//
//		view.playerHolder
//			..append(canvas)
//			..append(circle)
//			..append(parent);
//
//		ready = true;
	}

	@override
	update(double dt) {
		if(!ready) {
			return;
		}

		//if a player collides with us, tell the server
		if(!hit) {
			if(_checkPlayerCollision()) {

				new Timer(new Duration(seconds: 10), () => hit = false);

				if(typeString == 'mood' &&
				   metabolics.playerMetabolics.mood == metabolics.playerMetabolics.max_mood) {
					toast("You tried to collect a mood quoin, but your mood was already full.");
				} else if(typeString == 'energy' &&
				          metabolics.playerMetabolics.energy == metabolics.playerMetabolics.max_energy) {
					toast("You tried to collect an energy quoin, but your energy tank was already full.");
				} else if (metabolics.playerMetabolics.quoins_collected >= 100) {
					toast("You've reached your daily limit of 100 quoins");
				} else {
					_sendToServer();
				}

				hit = true;
			}
		}
	}

	@override
	bool get intersectingPlayer {
		return intersect(CurrentPlayer.avatarRect, quoinRect);
	}

	bool _checkPlayerCollision() {
		if(collected || checking) {
			return false;
		}

		return intersectingPlayer;
	}

	void _sendToServer() {
		//don't try to collect the same quoin again before we get a response
		checking = true;

		audio.playSound('quoinSound');

//		circle.classes.add("circleExpand");
//		parent.classes.add("circleExpand");
//		new Timer(new Duration(seconds:2), () => _removeCircleExpand(parent));
//		new Timer(new Duration(milliseconds:800), () => _removeCircleExpand(circle));
//		canvas.style.display = "none"; //.remove() is very slow

		if(streetSocket != null && streetSocket.readyState == WebSocket.OPEN) {
			Map map = new Map();
			map["remove"] = id;
			map["type"] = "quoin";
			map['username'] = game.username;
			map["streetName"] = currentStreet.label;
			streetSocket.send(JSON.encode(map));
		}
	}

	void _removeCircleExpand(Element element) {
		if(element != null)
			element.classes.remove("circleExpand");
	}

	@override
	bool advanceTime(num time) {
		flipbook.x = left - camera.x;
		flipbook.y = top - camera.y;
	}

	@override
	render() {}
}