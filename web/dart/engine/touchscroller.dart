part of couclient;

class TouchScroller
{
	static int HORIZONTAL = 0, VERTICAL = 1, BOTH = 2;
	DivElement _scrollDiv;
	int _startX, _startY, _lastX, _lastY, _direction;
	
	TouchScroller(this._scrollDiv, this._direction)
	{
		_scrollDiv.onTouchStart.listen((TouchEvent event)
		{
			event.stopPropagation();
			_startX = event.changedTouches.first.client.x;
			_startY = event.changedTouches.first.client.y;
			_lastX = _startX;
			_lastY = _startY;
		});
		_scrollDiv.onTouchMove.listen((TouchEvent event)
		{
			event.preventDefault();
			int diffX = _lastX - event.changedTouches.single.client.x;
			int diffY = _lastY - event.changedTouches.single.client.y;
			_lastX = event.changedTouches.single.client.x;
			_lastY = event.changedTouches.single.client.y;
			if(_direction == HORIZONTAL || _direction == BOTH)
				_scrollDiv.scrollLeft = _scrollDiv.scrollLeft + diffX;
			if(_direction == VERTICAL || _direction == BOTH)
				_scrollDiv.scrollTop = _scrollDiv.scrollTop + diffY;
		});
	}
}