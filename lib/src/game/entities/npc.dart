part of couclient;

class NPC extends GlowingEntity {
	String type;
	int speed = 0;
	bool ready = false, facingRight = true;
	StreamController _animationLoaded = new StreamController.broadcast();
	String animationUrl, animationName;
	xl.FlipBook displayObject;

	Stream get onAnimationLoaded => _animationLoaded.stream;

	factory NPC(Map map) {
		if (map['type'].contains('Street Spirit')) {
			return new StreetSpirit(map);
		}
		return new NPC._NPC(map);
	}

	NPC._NPC(Map map) {
		speed = map['speed'];
		type = map['type'];
		width = map['width'];
		height = map['height'];
		id = map['id'];

		canvas = new CanvasElement();
		canvas.id = id;
		canvas.attributes['actions'] = JSON.encode(map['actions']);
		canvas.attributes['type'] = map['type'];
		canvas.classes.add("npc");
		canvas.classes.add('entity');
		canvas.style.position = "absolute";
		canvas.style.visibility = "hidden";
		view.playerHolder.append(canvas);

		loadAnimation(map).then((_) {
			width = displayObject.width;
			height = displayObject.height;
			left = map['x'];
			top = currentStreet.bounds.height - map['y'] - height;
			displayObject.x = left;
			displayObject.y = top;
			currentStreet.interactionLayer.addChild(displayObject);
			currentStreet.interactionLayer.addEntity(this);
			ready = true;
			_animationLoaded.add(true);
		});
	}

	Future loadAnimation(Map animationMap) async {
		if(type == 'Batterfly') print(animationName);
		animationUrl = animationMap['url'];
		animationName = animationMap['animation_name'];
		int numRows = animationMap['numRows'];
		int numColumns = animationMap['numColumns'];
		int numFrames = animationMap['numFrames'];
		bool loops = animationMap['loops'];
		ready = false;

		if (!entityResourceManger.containsBitmapData(animationUrl)) {
			entityResourceManger.addBitmapData(animationUrl, animationUrl, loadOptions);
			await entityResourceManger.load();
		}

		//remove the old one
		if (displayObject != null) {
			currentStreet.stage.juggler.remove(displayObject);
			displayObject.removeFromParent();
		}

		//make and add the new one
		xl.BitmapData data = entityResourceManger.getBitmapData(animationUrl);
		SpriteSheet spritesheet = new SpriteSheet(data, data.width ~/ numColumns, data.height ~/ numRows, frameCount:numFrames);
		displayObject = new xl.FlipBook(spritesheet.frames, 30, loops)
			..pivotX = this.width / 2
			..addTo(currentStreet.interactionLayer)
			..play();

		currentStreet.stage.juggler.add(displayObject);
		ready = true;
	}

	@override
	bool advanceTime(num time) {
		RegExp movementWords = new RegExp(r'(walk|fly|move)');
		if (animationName.contains(movementWords)) {
			if (facingRight) {
				left += speed * time;
			} else {
				left -= speed * time;
			}

			if (left < 0) {
				left = 0.0;
			}
			if (left > currentStreet.bounds.width - canvas.width) {
				left = (currentStreet.bounds.width - canvas.width).toDouble();
			}
		}

		if (facingRight) {
			displayObject.scaleX = 1;
		} else {
			displayObject.scaleX = -1;
		}

		super.advanceTime(time);
	}

	@override
	render() {
	}
}
