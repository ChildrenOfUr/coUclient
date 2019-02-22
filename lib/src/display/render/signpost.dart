part of couclient;

class Signpost extends Entity {
	DivElement pole;
	List<Element> signs = [];
	bool interacting = false, letGo = false;
	StreamSubscription clickListener;

	Signpost(Map<String, dynamic> signpost, int x, int y) {
		int h = 200, w = 100;
		if(signpost['h'] != null) {
			h = signpost['h'];
		}
		if(signpost['w'] != null) {
			w = signpost['w'];
		}

		left = x;
		top = y;
		width = w;
		height = h;

		pole = new DivElement()
			..className = 'entity';

		pole.attributes
			..['translateX'] = x.toString()
			..['translateY'] = y.toString()
			..['width'] = w.toString()
			..['height'] = h.toString();

		pole.style
			..backgroundImage = "url('https://childrenofur.com/locodarto/scenery/sign_pole.png')"
			..backgroundRepeat = "no-repeat"
			..backgroundPosition = "center bottom"
			..pointerEvents = "auto"
			..width = w.toString() + "px"
			..height = h.toString() + "px"
			..position = "absolute"
			..top = y.toString() + "px"
			..left = x.toString() + "px";

		id = 'pole' + random.nextInt(50).toString();
		pole.id = id;
		entities[id] = this;

		int i = 0;
		List<Map<String, dynamic>> signposts = (signpost['connects'] as List).cast<Map<String, dynamic>>();
		for(Map<String, dynamic> exit in signposts) {
			if(exit['label'] as String == playerTeleFrom || playerTeleFrom == "console") {
				CurrentPlayer.left = x;
				CurrentPlayer.top = y;
			}

			String tsid = tsidG(exit['tsid'] as String);
			SpanElement span = new SpanElement()
				..style.top = (i * 25 + 10).toString() + "px"
				..text = exit["label"] as String
				..className = "ExitLabel"
				..attributes['url'] = 'https://RobertMcDermot.github.io/CAT422-glitch-location-viewer/locations/$tsid.callback.json'
				..attributes['tsid'] = tsid
				..attributes['from'] = currentStreet.label;

			pole.append(span);
			signs.add(span);

			if(i % 2 != 0) {
				span.style.right = '50%';
				span.style.transform = "rotate(5deg)";
			}
			else {
				span.style.left = '50%';
				span.style.transform = "rotate(-5deg)";
			}

			i++;
		}

		view.playerHolder.append(pole);
	}

	@override
	update(dt) {
		super.update(dt);
	}

	@override
	render() {
		if(dirty) {
			if(glow)
				pole.classes.add('hovered');
			else {
				pole.classes.remove('hovered');
				signs.forEach((Element sign) => sign.classes.remove('hovered'));
			}

			dirty = false;
		}
	}

	@override
	void interact(String id) {
		if (signs.length == 1) {
			// Only one exit -> Go to that one immediately
			signs.single.click();
			return;
		} else if (GPS.active) {
			// Multiple exits -> Go to the one matching the next street along the GPS path
			signs.singleWhere((Element sign) => sign.text == GPS.nextStreetName).click();
		}

		if(!interacting) {
			//remove the glow around the pole and put one on the first sign
			pole.classes.remove('hovered');
			signs.forEach((Element sign) => sign.classes.remove('hovered'));
			signs[0].classes.add('hovered');

			interacting = true;
			letGo = false;
		}

		//check for gamepad input
		gamepadLoop(num);

		inputManager.menuKeyListener = document.onKeyDown.listen((KeyboardEvent k) {
			Map keys = inputManager.keys;
			bool ignoreKeys = inputManager.ignoreKeys;

			//up arrow or w and not typing
			if((k.keyCode == keys["UpBindingPrimary"] || k.keyCode == keys["UpBindingAlt"]) && !ignoreKeys) {
				selectUp();
			}
			//down arrow or s and not typing
			if((k.keyCode == keys["DownBindingPrimary"] || k.keyCode == keys["DownBindingAlt"]) && !ignoreKeys) {
				selectDown();
			}
			//left arrow or a and not typing
			if((k.keyCode == keys["LeftBindingPrimary"] || k.keyCode == keys["LeftBindingAlt"]) && !ignoreKeys) {
				stop();
			}
			//right arrow or d and not typing
			if((k.keyCode == keys["RightBindingPrimary"] || k.keyCode == keys["RightBindingAlt"]) && !ignoreKeys) {
				stop();
			}
			//spacebar and not typing
			if((k.keyCode == keys["JumpBindingPrimary"] || k.keyCode == keys["JumpBindingAlt"]) && !ignoreKeys) {
				stop();
			}
			//enter and not typing
			if((k.keyCode == keys["ActionBindingPrimary"] || k.keyCode == keys["ActionBindingAlt"]) && !ignoreKeys) {
				clickSelected();
				stop();
			}
			if(k.keyCode == 27) {
				stop();
			}
		});
		clickListener = document.onClick.listen((_) => stop());
	}

	void gamepadLoop(num) {
		//only select a new option once every 300ms
		bool selectAgain = inputManager.lastSelect.add(new Duration(milliseconds:300)).isBefore(new DateTime.now());
		if (inputManager.upKey.active && selectAgain) {
			selectUp();
		}

		if (inputManager.downKey.active && selectAgain) {
			selectDown();
		}

		if (inputManager.leftKey.active || inputManager.rightKey.active || inputManager.jumpKey.active) {
			stop();
		}

		if (inputManager.actionKey.active && letGo) {
			clickSelected();
			stop();
		}

		if (!letGo && !inputManager.actionKey.active) {
			letGo = true;
		}

		if(interacting)
			window.animationFrame.then(gamepadLoop);
	}

	void stop() {
		inputManager.stopMenu(null);
		clickListener.cancel();
		interacting = false;
		letGo = false;
		signs.forEach((Element sign) => sign.classes.remove('hovered'));
	}

	void selectUp() {
		int removed = 0;
		for(int i = 0; i < signs.length; i++) {
			if(signs[i].classes.remove('hovered'))
				removed = i;
		}
		if(removed == 0)
			signs[signs.length - 1].classes.add('hovered');
		else
			signs[removed - 1].classes.add('hovered');

		inputManager.lastSelect = new DateTime.now();
	}

	void selectDown() {
		int removed = signs.length - 1;
		for(int i = 0; i < signs.length; i++) {
			if(signs[i].classes.remove('hovered'))
				removed = i;
		}
		if(removed == signs.length - 1)
			signs[0].classes.add('hovered');
		else
			signs[removed + 1].classes.add('hovered');

		inputManager.lastSelect = new DateTime.now();
	}

	void clickSelected() {
		signs.forEach((Element sign) {
			if(sign.classes.contains('hovered')) {
				inputManager.stopMenu(null);
				sign.click();
			}
		});

		interacting = false;
	}
}
