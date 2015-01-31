part of couclient;

class Signpost extends Entity
{
	DivElement pole;
	List<Element> signs = [];
	bool interacting = false;

	Signpost(Map signpost, int x, int y)
	{
		int h = 200, w = 100;
		if(signpost['h'] != null)
			h = signpost['h'];
		if(signpost['w'] != null)
			w = signpost['w'];
		pole = new DivElement()
	        ..className = 'entity'
			..attributes['translateX'] = x.toString()
			..attributes['translateY'] = y.toString()
			..attributes['width'] = w.toString()
			..attributes['height'] = h.toString()
	        ..style.backgroundImage = "url('http://childrenofur.com/locodarto/scenery/sign_pole.png')"
	        ..style.backgroundRepeat = "no-repeat"
	        ..style.pointerEvents = "auto"
	        ..style.width = w.toString() + "px"
	        ..style.height = h.toString() + "px"
	        ..style.position = "absolute"
	        ..style.top = y.toString() + "px"
	        ..style.left = x.toString() + "px";

		String id = 'pole'+random.nextInt(50).toString();
		pole.id = id;
		entities[id] = this;

		int i=0;
		List signposts = signpost['connects'] as List;
		for(Map<String,String> exit in signposts)
  		{
    		if(exit['label'] == playerTeleFrom || playerTeleFrom == "console")
			{
  				CurrentPlayer.posX = x;
  				CurrentPlayer.posY = y;
			}

			String tsid = exit['tsid'].replaceFirst("L", "G");
			SpanElement span = new SpanElement()
  				..style.top = (i*25+10).toString() + "px"
  				..text = exit["label"]
  				..className = "ExitLabel"
				..attributes['url'] = 'http://RobertMcDermot.github.io/CAT422-glitch-location-viewer/locations/$tsid.callback.json'
				..attributes['tsid'] = tsid
				..attributes['from'] = currentStreet.label;

			pole.append(span);
			signs.add(span);

			if(i %2 != 0)
			{
  				span.style.right = '50%';
  				span.style.transform = "rotate(5deg)";
    		}
			else
			{
				span.style.left = '50%';
				span.style.transform = "rotate(-5deg)";
			}

    		i++;
  		}

		view.playerHolder.append(pole);
	}

	update(dt){}

	render()
	{
		if(dirty)
		{
			if(glow)
				pole.classes.add('hovered');
			else
			{
				pole.classes.remove('hovered');
				signs.forEach((Element sign) => sign.classes.remove('hovered'));
			}

			dirty = false;
		}
	}

	@override
	void interact(String id)
	{
		//if there's only one exit, go to that one immediately
		if(signs.length == 1)
		{
			signs[0].click();
			return;
		}

		if(!interacting)
		{
			//remove the glow around the pole and put one on the first sign
			pole.classes.remove('hovered');
			signs[0].classes.add('hovered');
		}

		interacting = true;
		bool letGo = false;

		//check for gamepad input
		Timer gamepadLoop = new Timer.periodic(new Duration(milliseconds:17), (Timer t)
		{
			//only select a new option once every 300ms
			bool selectAgain = inputManager.lastSelect.add(new Duration(milliseconds:300)).isBefore(new DateTime.now());
			if(inputManager.controlCounts['upKey']['keyBool'] == true && selectAgain)
				selectUp();
			if(inputManager.controlCounts['downKey']['keyBool'] == true && selectAgain)
				selectDown();
			if(inputManager.controlCounts['leftKey']['keyBool'] == true ||
				inputManager.controlCounts['rightKey']['keyBool'] == true ||
				inputManager.controlCounts['jumpKey']['keyBool'] == true)
			{
				inputManager.stopMenu(null);
				t.cancel();
				interacting = false;
			}
			if(inputManager.controlCounts['actionKey']['keyBool'] == true && letGo)
			{
				clickSelected();
				t.cancel();
				interacting = false;
			}
			if(inputManager.controlCounts['actionKey']['keyBool'] == false)
				letGo = true;
		});

		inputManager.menuKeyListener = document.onKeyDown.listen((KeyboardEvent k)
		{
			Map keys = inputManager.keys;
			bool ignoreKeys = inputManager.ignoreKeys;

			if((k.keyCode == keys["UpBindingPrimary"] || k.keyCode == keys["UpBindingAlt"]) && !ignoreKeys) //up arrow or w and not typing
				selectUp();
			if((k.keyCode == keys["DownBindingPrimary"] || k.keyCode == keys["DownBindingAlt"]) && !ignoreKeys) //down arrow or s and not typing
				selectDown();
			if((k.keyCode == keys["LeftBindingPrimary"] || k.keyCode == keys["LeftBindingAlt"]) && !ignoreKeys) //left arrow or a and not typing
				inputManager.stopMenu(null);
			if((k.keyCode == keys["RightBindingPrimary"] || k.keyCode == keys["RightBindingAlt"]) && !ignoreKeys) //right arrow or d and not typing
				inputManager.stopMenu(null);
			if((k.keyCode == keys["JumpBindingPrimary"] || k.keyCode == keys["JumpBindingAlt"]) && !ignoreKeys) //spacebar and not typing
				inputManager.stopMenu(null);
			if((k.keyCode == keys["ActionBindingPrimary"] || k.keyCode == keys["ActionBindingAlt"]) && !ignoreKeys) //spacebar and not typing
				clickSelected();
		});
		document.onClick.listen((_)
		{
			inputManager.stopMenu(null);
		});
	}

	void selectUp()
	{
		int removed = 0;
		for(int i=0; i<signs.length; i++)
		{
			if(signs[i].classes.remove('hovered'))
				removed = i;
		}
		if(removed == 0)
			signs[signs.length-1].classes.add('hovered');
		else
			signs[removed-1].classes.add('hovered');

		inputManager.lastSelect = new DateTime.now();
	}

	void selectDown()
	{
		int removed = signs.length-1;
		for(int i=0; i<signs.length; i++)
		{
			if(signs[i].classes.remove('hovered'))
				removed = i;
		}
		if(removed == signs.length-1)
			signs[0].classes.add('hovered');
		else
			signs[removed+1].classes.add('hovered');

		inputManager.lastSelect = new DateTime.now();
	}

	void clickSelected()
	{
		signs.forEach((Element sign)
		{
			if(sign.classes.contains('hovered'))
			{
				inputManager.stopMenu(null);
				sign.click();
			}
		});

		interacting = false;
	}
}