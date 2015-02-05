part of couclient;

class Platform implements Comparable
{
  Point start, end;
  String id;
  bool itemPerm, pcPerm;
  Platform(Map platformLine, Map layer, int groundY, [this.itemPerm = false, this.pcPerm = false])
  {
	  id = platformLine['id'];
    (platformLine['endpoints'] as List).forEach((Map endpoint)
    {
      if(endpoint["name"] == "start")
      {
        start = new Point(endpoint["x"],endpoint["y"]+groundY);
        if(layer['name'] == 'middleground')
          start = new Point(endpoint["x"]+layer['w']~/2,endpoint["y"]+layer['h']+groundY);
      }
      if(endpoint["name"] == "end")
      {
        end = new Point(endpoint["x"],endpoint["y"]+groundY);
        if(layer['name'] == 'middleground')
          end = new Point(endpoint["x"]+layer['w']~/2,endpoint["y"]+layer['h']+groundY);
      }
    });
  }

  String toString()
  {
    return "(${start.x},${start.y})->(${end.x},${end.y})";
  }

  int compareTo(Platform other)
  {
    return other.start.y - start.y;
  }
}