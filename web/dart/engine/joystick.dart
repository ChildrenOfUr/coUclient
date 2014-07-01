part of coUclient;

class Joystick
{
	Element joystick, knob;
	int _neutralX, _neutralY, _initialTouchX, _initialTouchY, deadzoneInPixels;
	double deadzoneInPercent;
	bool UP = false, DOWN = false, LEFT = false, RIGHT = false;
	StreamController _moveController = new StreamController.broadcast();
	StreamController _releaseController = new StreamController.broadcast();
	
	/**
	 * deadzoneInPixels should be a number >= 0 that represents the number of pixels away
	 * from the center of the joystick element that the knob must be dragged in order to 
	 * trigger an UP/DOWN/LEFT/RIGHT action
	 * 
	 * deadzoneInPercent should be a number between 0.0 and 1.0 representing the percentage
	 * of the width of the joystick element that should be considered the deadzone
	 **/
	Joystick(this.joystick, this.knob, {this.deadzoneInPixels : 0, this.deadzoneInPercent : 0.0})
	{	
		if(deadzoneInPercent != 0)
		{
			deadzoneInPixels = (joystick.clientWidth * deadzoneInPercent).toInt();
			print("deadzone: ${deadzoneInPixels}px");
		}
		
		knob.onTouchStart.listen((TouchEvent event)
		{
			event.preventDefault();
			_neutralX = knob.offsetLeft;
			_neutralY = knob.offsetTop;
			_initialTouchX = event.changedTouches.first.client.x;
			_initialTouchY = event.changedTouches.first.client.y;
			_moveController.add(new JoystickEvent());
		});
		knob.onTouchMove.listen((TouchEvent event)
		{
			event.preventDefault(); //prevent page from scrolling/zooming
			int x = _neutralX + (event.changedTouches.first.client.x - _initialTouchX);
			int y = _neutralY + (event.changedTouches.first.client.y - _initialTouchY);
			
			//keep within containing joystick circle
			int radius = joystick.clientWidth~/2;
			if(!inCircle(_neutralX,_neutralY,radius,x,y)) //stick to side of circle
			{
				double slope = (y-_neutralY)/(x-_neutralX);
				double angle = atan(slope);
				if((x-_neutralX) < 0) //if left side of circle
					angle += PI;
				int yOnCircle = _neutralY+(sin(angle)*radius).floor();
				int xOnCircle = _neutralX+(cos(angle)*radius).floor();
				
				x = xOnCircle;
				y = yOnCircle;
			}
						
			if(x < _neutralX-deadzoneInPixels) LEFT = true;
			else LEFT = false;
			if(x > _neutralX+deadzoneInPixels) RIGHT = true;
			else RIGHT = false;
			if(y > _neutralY+deadzoneInPixels) DOWN = true;
			else DOWN = false;
			if(y < _neutralY-deadzoneInPixels) UP = true;
			else UP = false;

			knob.style.left = x.toString()+"px";
			knob.style.top = y.toString()+"px";
			
			_moveController.add(new JoystickEvent());
		});
		knob.onTouchEnd.listen((TouchEvent event)
		{
			event.preventDefault();
			knob.attributes.remove('style'); //in case the user rotates the screen
			UP = false; DOWN = false; LEFT = false; RIGHT = false; //reset
			
			_releaseController.add(new JoystickEvent());
		});
	}
	
	Stream get onMove => _moveController.stream;
	Stream get onRelease => _releaseController.stream;
	
	bool inCircle(int center_x, int center_y, int radius, int x, int y)
	{
		int square_dist = pow((center_x - x),2) + pow((center_y - y),2);
		return square_dist <= pow(radius,2);
	}
}

class JoystickEvent{}