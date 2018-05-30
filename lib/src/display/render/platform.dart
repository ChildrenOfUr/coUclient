part of couclient;

class Platform implements Comparable {
	Point start, end;
	String id;
	bool itemPerm = true, ceiling = false;
	Rectangle bounds;

	Platform(Map platformLine, Map layer, int groundY) {
		id = platformLine['id'];
		ceiling = platformLine['platform_pc_perm'] == 1;

		(platformLine['endpoints'] as List).forEach((dynamic endpoint) {
			assert(endpoint is Map);

			if(endpoint["name"] == "start") {
				start = new Point(endpoint["x"], endpoint["y"] + groundY);
				if(layer['name'] == 'middleground')
					start = new Point(endpoint["x"] + layer['w'] ~/ 2, endpoint["y"] + layer['h'] + groundY);
			}
			if(endpoint["name"] == "end") {
				end = new Point(endpoint["x"], endpoint["y"] + groundY);
				if(layer['name'] == 'middleground')
					end = new Point(endpoint["x"] + layer['w'] ~/ 2, endpoint["y"] + layer['h'] + groundY);
			}
		});

		int width = end.x - start.x;
		int height = end.y - start.y;
		bounds = new Rectangle(start.x,start.y,width,height);
	}

	@override
	String toString() {
		return "(${start.x},${start.y})->(${end.x},${end.y}) ceiling=$ceiling";
	}

	@override
	int compareTo(dynamic other) {
		assert(other is Platform);
		return other.start.y - start.y;
	}
}