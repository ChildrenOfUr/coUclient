part of couclient;

class NPC extends Entity implements xl.Animatable {
	String type;
	num speed = 0,
		ySpeed = 0;
	bool ready = false,
		loading = false,
		facingRight = true,
		firstRender = true;
	xl.FlipBook animation;
//	Animation animation;
	ChatBubble chatBubble = null;

	bool isHiddenSpritesheet(String url) =>
		url == 'data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7';

	NPC(Map map) {
		if (map.containsKey('actions')) {
			actions = decode(JSON.encode(map['actions']), type: const TypeHelper<List<Action>>().type);
		}

		canvas = new CanvasElement();
		speed = map['speed'];
		ySpeed = map['ySpeed'] ?? 0;
		type = map['type'];

//		List<int> frameList = [];
//		for (int i = 0; i < map['numFrames']; i++) {
//			frameList.add(i);
//		}

		id = map['id'];

		try {
			resourceManager.addBitmapData(map['url'], map['url']);
		} catch (e) {
			//it probably already contains it from another npc
			//which is fine, but it sure is noisy about it
		}
		resourceManager.load().then((_) {
			xl.BitmapData spritesheet = resourceManager.getBitmapData(map['url']);
			num w = spritesheet.width/map['numColumns'];
			num h = spritesheet.height/map['numRows'];
			animation = new xl.FlipBook(spritesheet.sliceIntoFrames(w, h, frameCount: map['numFrames']));
			animation.play();
			view.playerStage.juggler.add(animation);
			view.playerStage.addChild(animation);
			width = animation.width;
			height = animation.height;
			top = map['y'] - animation.height;
			left = map['x'];

			_positionNpc();

			view.playerStage.juggler.add(this);

			addingLocks[id] = false;
			ready = true;
		});
//		loadAnimation(map).then((_) {
//			if (!isHiddenSpritesheet(map['url'])) {
//				HttpRequest.request('http://${Configs.utilServerAddress}/getActualImageHeight?url=${map['url']}&numRows=${map['numRows']}&numColumns=${map['numColumns']}').then((HttpRequest request) {
//					canvas.attributes['actualHeight'] = request.responseText;
//				});
//			} else {
//				canvas.attributes['actualHeight'] = '1';
//			}

//			canvas.id = map["id"];
//			canvas.attributes['actions'] = JSON.encode(map['actions']);
//			canvas.attributes['type'] = map['type'];
//			canvas.classes.add("npc");
//			canvas.classes.add('entity');
//			canvas.width = map["width"];
//			canvas.height = map["height"];
//			canvas.style.position = "absolute";
//			canvas.attributes['translatex'] = left.toString();
//			canvas.attributes['translatey'] = top.toString();
//			canvas.attributes['width'] = canvas.width.toString();
//			canvas.attributes['height'] = canvas.height.toString();
//			view.playerHolder.append(canvas);
//			sortEntities();
//			ready = true;
//		});
	}

	Future loadAnimation(Map map) async {
//		if (loading || animation?.name == map['animation_name']) {
//			return;
//		}
//
//		ready = false;
//
//		if (!resourceManager.containsBitmapData(id+map['animation_name'])) {
//			loading = true;
//			resourceManager.addBitmapData(id+map['animation_name'], map['url']);
//			await resourceManager.load();
//			loading = false;
//		}
//
//		xl.BitmapData spritesheet = resourceManager.getBitmapData(id+map['animation_name']);
//		num width = spritesheet.width/map['numColumns'];
//		num height = spritesheet.height/map['numRows'];
//		if (animation != null) {
//			view.playerStage.juggler.remove(animation);
//		}
//		animation = new xl.FlipBook(spritesheet.sliceIntoFrames(width, height, frameCount: map['numFrames']));
//		view.playerStage.juggler.add(animation);
//		width = animation.width;
//		height = animation.height;
//
//		ready = true;
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

	Future updateAnimation(Map npcMap) async {
		//new animation
		if (ready && animation.name != npcMap["animation_name"]) {
			List<int> frameList = [];
			for (int i = 0; i < npcMap['numFrames']; i++) {
				frameList.add(i);
			}

			await loadAnimation(npcMap);
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
//		if (currentStreet == null || canvas == null) {
//			return;
//		}
//
//		super.update(dt);
//
//		_setTranslate();

//		if (intersect(camera.visibleRect, entityRect) && !isHiddenSpritesheet(animation.url)) {
//			animation.updateSourceRect(dt);
//		}
	}

	render() {
//		if (ready && (animation.dirty || dirty)) {
//			if (!firstRender) {
//				//if the entity is not visible, don't render it
//				if (!intersect(camera.visibleRect, entityRect)) {
//					return;
//				}
//			}
//
//			firstRender = false;
//
//			//fastest way to clear a canvas (without using a solid color)
//			//source: http://jsperf.com/ctx-clearrect-vs-canvas-width-canvas-width/6
//			canvas.context2D.clearRect(0, 0, animation.width, animation.height);
//
//			if (glow) {
//				//canvas.context2D.shadowColor = "rgba(0, 0, 255, 0.2)";
//				canvas.context2D.shadowBlur = 2;
//				canvas.context2D.shadowColor = 'cyan';
//				canvas.context2D.shadowOffsetX = 0;
//				canvas.context2D.shadowOffsetY = 1;
//			} else {
//				canvas.context2D.shadowColor = "0";
//				canvas.context2D.shadowBlur = 0;
//				canvas.context2D.shadowOffsetX = 0;
//				canvas.context2D.shadowOffsetY = 0;
//			}
//
//			canvas.context2D.drawImageToRect(animation.spritesheet, destRect,
//				                                 sourceRect: animation.sourceRect);
//			animation.dirty = false;
//			dirty = false;
//		}
	}

	_positionNpc() {
		animation.x = left - camera.getX();
		animation.y = top - camera.getY();
	}

	@override
	bool advanceTime(num time) {
		_positionNpc();

		if (!facingRight) {
			animation.scaleX = -1;
		} else {
			animation.scaleX = 1;
		}

		return true;
	}
}
