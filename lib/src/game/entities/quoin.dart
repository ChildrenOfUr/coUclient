part of couclient;

class Quoin {
	Map <String, int> quoins = {"img":0, "mood":1, "energy":2, "currant":3, "mystery":4, "favor":5, "time":6, "quarazy":7};
	String typeString;
	Animation animation;
	bool ready = false, firstRender = true, collected = false, checking = false, hit = false;
	CanvasElement canvas;
	DivElement circle, parent;
	Rectangle quoinRect;
	num left, top;
	String id;

	Quoin(Map map) {
		init(map);
	}

	init(Map map) async
	{
		typeString = map['type'];
		id = map["id"];
		int quoinValue = quoins[typeString.toLowerCase()];

		List<int> frameList = [];
		for(int i = 0; i < 24; i++)
			frameList.add(quoinValue * 24 + i);

		animation = new Animation(map['url'], typeString.toLowerCase(), 8, 24, frameList, fps:22);
		await animation.load();

		canvas = new CanvasElement();
		canvas.width = animation.width;
		canvas.height = animation.height;
		canvas.id = id;
		canvas.className = map['type'] + " quoin";
		canvas.style.position = "absolute";
		canvas.style.left = map['x'].toString() + "px";
		canvas.style.bottom = map['y'].toString() + "px";
		canvas.style.transform = "translateZ(0)";
		canvas.attributes['collected'] = "false";

		left = map['x'];
		top = currentStreet.bounds.height - map['y'] - canvas.height;

		circle = new DivElement()
			..id = "q" + id
			..className = "circle"
			..style.position = "absolute"
			..style.left = map["x"].toString() + "px"
			..style.bottom = map["y"].toString() + "px";
		parent = new DivElement()
			..id = "qq" + id
			..className = "parent"
			..style.position = "absolute"
			..style.left = map["x"].toString() + "px"
			..style.bottom = map["y"].toString() + "px";
		DivElement inner = new DivElement();
		inner.className = "inner";
		DivElement content = new DivElement();
		content.className = "quoinString";
		parent.append(inner);
		inner.append(content);

		view.playerHolder
			..append(canvas)
			..append(circle)
			..append(parent);

		ready = true;
	}

	update(double dt) {
		if(!ready) {
			return;
		}

		quoinRect = new Rectangle(left, top, canvas.width, canvas.height);

		//if a player collides with us, tell the server
		if(!hit) {
			if(_checkPlayerCollision()) {

				new Timer(new Duration(seconds: 1), () => hit = false);

				if(typeString == 'mood' && metabolics.playerMetabolics.mood == metabolics.playerMetabolics.max_mood) {
					toast("You tried to collect a mood quoin, but your mood was already full.");
				} else if(typeString == 'energy' && metabolics.playerMetabolics.energy == metabolics.playerMetabolics.max_energy) {
					toast("You tried to collect an energy quoin, but your energy tank was already full.");
				} else {
					_sendToServer();
				}

				hit = true;
			}
		}

		if(intersect(camera.visibleRect, quoinRect)) {
			animation.updateSourceRect(dt);
		}
	}

	bool _checkPlayerCollision() {
		if(collected || checking) {
			return false;
		}

		return intersect(CurrentPlayer.avatarRect, quoinRect);
	}

	void _sendToServer() {
		//don't try to collect the same quoin again before we get a response
		checking = true;

		audio.playSound('quoinSound');

		circle.classes.add("circleExpand");
		parent.classes.add("circleExpand");
		new Timer(new Duration(seconds:2), () => _removeCircleExpand(parent));
		new Timer(new Duration(milliseconds:800), () => _removeCircleExpand(circle));
		canvas.style.display = "none"; //.remove() is very slow

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

	render() {
		if(ready && animation.dirty && canvas.attributes['collected'] == "false") {
			if(!firstRender) {
				//if the entity is not visible, don't render it
				if(!intersect(camera.visibleRect, quoinRect))
					return;
			}

			firstRender = false;

			//fastest way to clear a canvas (without using a solid color)
			//source: http://jsperf.com/ctx-clearrect-vs-canvas-width-canvas-width/6
			canvas.context2D.clearRect(0, 0, animation.width, animation.height);

			Rectangle destRect = new Rectangle(0, 0, animation.width, animation.height);
			canvas.context2D.drawImageToRect(animation.spritesheet, destRect, sourceRect: animation.sourceRect);
			animation.dirty = false;
		}
	}
}