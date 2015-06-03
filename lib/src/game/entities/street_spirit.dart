part of couclient;

class StreetSpirit extends NPC {
	bool bobbingUp = true;
	num bobUpper, bobLower;

	StreetSpirit(Map map) : super._NPC(map) {
		onAnimationLoaded.first.then((_) {
			bobUpper = top + 15;
			bobLower = top - 15;
		});
	}

	@override
	update(double dt) {
		if(!ready) {
			return;
		}
		//make street spirits bob up and down
		if(bobbingUp) {
			top -= sin(top/bobUpper)*speed/3*dt;
		}
		if(!bobbingUp) {
			top += sin(top/bobLower)*speed/3*dt;
		}

		if(top < bobLower) {
			top = bobLower;
			bobbingUp = false;
		}
		if(top > bobUpper) {
			top = bobUpper;
			bobbingUp = true;
		}

		canvas.attributes['translatex'] = left.toString();
		canvas.attributes['translatey'] = top.toString();

		if(facingRight)
			canvas.style.transform = "translateX(${left}px) translateY(${top}px) scale3d(1,1,1)";
		else
			canvas.style.transform = "translateX(${left}px) translateY(${top}px) scale3d(-1,1,1)";

		super.update(dt);
	}
}