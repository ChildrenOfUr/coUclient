part of coUclient;

class Joystick
{
	Element _joystick, _knob;
	int _neutralX, _neutralY, _initialTouchX, _initialTouchY;
	bool UP = false, DOWN = false, LEFT = false, RIGHT = false;
	StreamController _moveController = new StreamController.broadcast();
	StreamController _releaseController = new StreamController.broadcast();
	
	Joystick(this._joystick, this._knob)
	{
		_neutralX = _knob.offsetLeft;
		_neutralY = _knob.offsetTop;
		
		_knob.onTouchStart.listen((TouchEvent event)
		{
			_initialTouchX = event.touches.first.client.x;
			_initialTouchY = event.touches.first.client.y;
			_moveController.add(new JoystickEvent());
		});
		_knob.onTouchMove.listen((TouchEvent event)
		{
			event.preventDefault(); //prevent page from scrolling/zooming

			int x = _neutralX + (event.touches.first.client.x - _initialTouchX);
			int y = _neutralY + (event.touches.first.client.y - _initialTouchY);
			
			//keep within containing joystick circle
			int radius = _joystick.clientWidth~/2;
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
						
			if(x < _neutralX) LEFT = true;
			else LEFT = false;
			if(x > _neutralX) RIGHT = true;
			else RIGHT = false;
			if(y > _neutralY) DOWN = true;
			else DOWN = false;
			if(y < _neutralY) UP = true;
			else UP = false;

			_knob.style.left = x.toString()+"px";
			_knob.style.top = y.toString()+"px";
			
			_moveController.add(new JoystickEvent());
		});
		_knob.onTouchEnd.listen((TouchEvent event)
		{
			_knob.style.left = _neutralX.toString()+"px";
			_knob.style.top = _neutralY.toString()+"px";
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