part of couclient;

class NPC extends Entity {
	String type;
	int speed = 0,
		ySpeed = 0;
	bool ready = false,
		facingRight = true,
		firstRender = true;
	Animation animation;
	ChatBubble chatBubble = null;
	StreamController _animationLoaded = new StreamController.broadcast();

	Stream get onAnimationLoaded => _animationLoaded.stream;

	NPC(Map map) {
		canvas = new CanvasElement();
		speed = map['speed'];
		ySpeed = map['ySpeed'] ?? 0;
		type = map['type'];

		List<int> frameList = [];
		for (int i = 0; i < map['numFrames']; i++) {
			frameList.add(i);
		}

		animation = new Animation(
			map['url'], "npc", map['numRows'], map['numColumns'], frameList,
			loopDelay: new Duration(milliseconds: map['loopDelay']),
			loops: map['loops']);
		animation.load().then((_) {
			HttpRequest.request('http://${Configs.utilServerAddress}/getActualImageHeight?url=${map['url']}&numRows=${map['numRows']}&numColumns=${map['numColumns']}').then((HttpRequest request) {
				canvas.attributes['actualHeight'] = request.responseText;
			});

			id = map['id'];

			try {
				top = map['y'] - animation.height;
				left = map['x'];
				width = map['width'];
				height = map['height'];
			} catch (e) {
				logmessage("Error animating NPC $id: $e");
				top = left = width = height = 0;
			}

			canvas.id = map["id"];
			canvas.attributes['actions'] = JSON.encode(map['actions']);
			canvas.attributes['type'] = map['type'];
			canvas.classes.add("npc");
			canvas.classes.add('entity');
			canvas.width = map["width"];
			canvas.height = map["height"];
			canvas.style.position = "absolute";
			canvas.attributes['translatex'] = left.toString();
			canvas.attributes['translatey'] = top.toString();
			canvas.attributes['width'] = canvas.width.toString();
			canvas.attributes['height'] = canvas.height.toString();
			view.playerHolder.append(canvas);
			ready = true;
			addingLocks[id] = false;
			_animationLoaded.add(true);
		});
	}

	void set x(num newX) {
		if (!ready || (left == newX && !firstRender)) {
			return;
		} else {
			left = newX;
		}
	}

	void set y(num newY) {
		if (!ready || (top == newY && !firstRender)) {
			return;
		} else if(ready) {
			top = newY - (animation.height ?? 0);
		}
	}

	_setTranslate() {
		canvas.attributes['translatex'] = left.toString();
		canvas.attributes['translatey'] = top.toString();
		if(facingRight) {
			canvas.style.transform = "translateX(${left}px) translateY(${top}px) scale3d(1,1,1)";
		} else {
			canvas.style.transform = "translateX(${left}px) translateY(${top}px) scale3d(-1,1,1)";
		}
	}

	update(double dt) {
		if (currentStreet == null || canvas == null) {
			return;
		}

		super.update(dt);

		_setTranslate();

		if (intersect(camera.visibleRect, entityRect)) {
			animation.updateSourceRect(dt);
		}
	}

	render() {
		if (ready && (animation.dirty || dirty)) {
			if (!firstRender) {
				//if the entity is not visible, don't render it
				if (!intersect(camera.visibleRect, entityRect)) {
					return;
				}
			}

			firstRender = false;

			//fastest way to clear a canvas (without using a solid color)
			//source: http://jsperf.com/ctx-clearrect-vs-canvas-width-canvas-width/6
			canvas.context2D.clearRect(0, 0, animation.width, animation.height);

			if (glow) {
				//canvas.context2D.shadowColor = "rgba(0, 0, 255, 0.2)";
				canvas.context2D.shadowBlur = 2;
				canvas.context2D.shadowColor = 'cyan';
				canvas.context2D.shadowOffsetX = 0;
				canvas.context2D.shadowOffsetY = 1;
			} else {
				canvas.context2D.shadowColor = "0";
				canvas.context2D.shadowBlur = 0;
				canvas.context2D.shadowOffsetX = 0;
				canvas.context2D.shadowOffsetY = 0;
			}

			canvas.context2D.drawImageToRect(animation.spritesheet, destRect,
				                                 sourceRect: animation.sourceRect);
			animation.dirty = false;
			dirty = false;
		}
	}
}
