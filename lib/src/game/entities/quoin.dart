part of couclient;

class Quoin {
	static Map<String, bool> notified = new Map();

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

		// Don't show Quarazy Quoins more than once for a street
		if (typeString == "quarazy") {
			if (!metabolics.load.isCompleted) {
				await metabolics.load.future;
			}

			if (
				metabolics.location_history.contains(currentStreet.tsid_g)
				|| metabolics.location_history.contains(currentStreet.tsid)
			) {
				return;
			}
		}

		id = map["id"];
		int quoinValue = quoins[typeString.toLowerCase()];

		List<int> frameList = [];
		for(int i = 0; i < 24; i++) {
			frameList.add(quoinValue * 24 + i);
		}

		animation = new Animation(map['url'], typeString.toLowerCase(), 8, 24, frameList, fps:22);
		await animation.load();

		canvas = new CanvasElement();
		canvas.width = animation.width;
		canvas.height = animation.height;
		canvas.id = id;
		canvas.className = map['type'] + " quoin";
		canvas.style.position = "absolute";
		canvas.style.left = map['x'].toString() + "px";
		canvas.style.top = map['y'].toString() + "px";
		canvas.style.transform = "translateZ(0)";
		canvas.attributes['collected'] = "false";

		left = map['x'];
		top = map['y'] - canvas.height;

		circle = new DivElement()
			..id = "q" + id
			..className = "circle"
			..style.position = "absolute"
			..style.left = map["x"].toString() + "px"
			..style.top = map["y"].toString() + "px";
		parent = new DivElement()
			..id = "qq" + id
			..className = "parent"
			..style.position = "absolute"
			..style.left = map["x"].toString() + "px"
			..style.top = map["y"].toString() + "px";
		DivElement inner = new DivElement();
		inner.className = "inner";
		DivElement content = new DivElement();
		content.className = "quoinString";
		parent.append(inner);
		inner.append(content);

		// Grey out quoins if their stats are maxed out
		if (statIsMaxed) {
			greyedOut = true;
		}

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
				if (_canCollect()) {
					_sendToServer();
				}

				hit = true;
			}
		}

		if(intersect(camera.visibleRect, quoinRect)) {
			animation.updateSourceRect(dt);
			greyedOut = statIsMaxed;
		}
	}

	/// Returns true if the quoin can be collected, false (and possibly toasts) if not
	bool _canCollect() {
		/// Notifies of the quoin message only one time per session
		bool _toastIfNotNotified(String message, [String key]) {
			/// Checks and updates notification history for this session
			bool _checkNotified(String key) {
				if (notified[key] != null && notified[key] == true) {
					// Already notified

					// Do not send it
					return true;
				} else {
					// First notification

					// Update status
					notified[key] = true;

					// Send it this time
					return false;
				}
			}

			// Not notified yet?
			if (!_checkNotified(key ?? typeString)) {
				// Send message
				new Toast(message);
			}

			// Allow single lines in the if bodies below
			return false;
		}

		if (metabolics.playerMetabolics.quoins_collected >= constants["quoinLimit"]) {
			return _toastIfNotNotified("You've reached your daily limit of ${constants["quoinLimit"].toString()} quoins");
		} else if (typeString == 'mood' && metabolics.playerMetabolics.mood >= metabolics.playerMetabolics.max_mood) {
			return _toastIfNotNotified("You tried to collect a mood quoin, but your mood was already full.");
		} else if (typeString == 'energy' && metabolics.playerMetabolics.energy >= metabolics.playerMetabolics.max_energy) {
			return _toastIfNotNotified("You tried to collect an energy quoin, but your energy tank was already full.");
		}  else {
			return true;
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

	bool get statIsMaxed {
		if (metabolics.playerMetabolics.quoins_collected >= constants["quoinLimit"]) {
			return true;
		}

		switch (typeString) {
			case "mood":
				return metabolics.playerMetabolics.mood >= metabolics.playerMetabolics.max_mood;
			case "energy":
				return metabolics.playerMetabolics.energy >= metabolics.playerMetabolics.max_energy;
			default:
				return false;
		}
	}

	set greyedOut(bool newValue) {
		final String GREY_CLASS = "quoin-disabled";

		if (newValue) {
			canvas.classes.add(GREY_CLASS);
		} else {
			canvas.classes.remove(GREY_CLASS);
		}
	}
}
