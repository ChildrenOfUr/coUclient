part of couclient;

class NPC extends Entity {
	String type;
	int speed = 0, ySpeed = 0;
	bool ready = false,
	facingRight = true,
	firstRender = true;
	Animation animation;
	ChatBubble chatBubble = null;
	StreamController _animationLoaded = new StreamController.broadcast();

	Stream get onAnimationLoaded => _animationLoaded.stream;

	factory NPC(Map map) {
		if (map['type'].contains('Street Spirit')) {
			return new StreetSpirit(map);
		}
		return new NPC._NPC(map);
	}

	NPC._NPC(Map map) {
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
			top = currentStreet.bounds.height -
			      num.parse(map['y'].toString()) -
			      animation.height;
			left = num.parse(map['x'].toString());
			width = map['width'];
			height = map['height'];
			id = map['id'];

			canvas = new CanvasElement();
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
			_animationLoaded.add(true);
		});
	}

	update(double dt) {
		if (!ready || currentStreet == null) {
			return;
		}

		super.update(dt);

		RegExp movementWords = new RegExp(r'(walk|fly|move|swim)');
		if (firstRender || animation.url.contains(movementWords)) {
			if(facingRight) {
				left += speed * dt;
			} else {
				left -= speed * dt;
			}
			top += ySpeed * dt;

			if (left < 0) {
				left = 0.0;
			}
			if (left > currentStreet.bounds.width - canvas.width) {
				left = (currentStreet.bounds.width - canvas.width).toDouble();
			}

			canvas.attributes['translatex'] = left.toString();
			canvas.attributes['translatey'] = top.toString();

			if (facingRight) {
				canvas.style.transform = "translateX(${left}px) translateY(${top}px) scale3d(1,1,1)";
			} else {
				canvas.style.transform = "translateX(${left}px) translateY(${top}px) scale3d(-1,1,1)";
			}
		}

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
