part of coUclient;

class Wall
{
	String id;
    int x,y,width,height;
    Rectangle bounds;

	Wall(Map wall, Map layer, int groundY)
	{
		width = wall['w'];
		height = wall['h'];
		x = wall['x'] + layer['w'] ~/ 2 - width ~/ 2;
		y = wall['y'] + layer['h'] - height + groundY;
		id = wall['id'];

		bounds = new Rectangle(x, y, width, height);
	}

	@override
	toString() => "wall $id: " + bounds.toString();
}