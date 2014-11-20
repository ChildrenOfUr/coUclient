part of couclient;

class Ladder
{
	String id;
	int x,y,width,height;
	Rectangle bounds;

	Ladder(Map ladder, Map layer, int groundY)
	{
		width = ladder['w'];
		height = ladder['h'];
		x = ladder['x'] + layer['w'] ~/ 2 - width ~/ 2;
		y = ladder['y'] + layer['h'] - height + groundY;
		id = ladder['id'];

		bounds = new Rectangle(x, y, width, height);
	}
}