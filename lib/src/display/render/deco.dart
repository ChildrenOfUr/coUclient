part of couclient;

class Deco implements Comparable
{
	ImageElement _image;
	int _zIndex, _x, _y, _w, _h;

	Deco(Map deco, int x, int y)
	{
		_w = deco['w'];
  		_h = deco['h'];
  		_zIndex = deco['z'];
  		_x = x;
  		_y = y;

  		// only draw if the image is loaded.
  		if (ASSET[deco['filename']] != null)
  		{
			ImageElement d = ASSET[deco['filename']].get();

			d.style.position = 'absolute';
			d.style.left = x.toString() + 'px';
			d.style.top = y.toString() + 'px';
			d.style.width = _w.toString() + 'px';
			d.style.height = _h.toString() + 'px';
			d.style.zIndex = _zIndex.toString();

			String transform = "";
			if(deco['r'] != null)
			{
				transform += "rotate3d(0,0,1,"+deco['r'].toString()+"deg)";
				d.style.transformOrigin = "50% bottom 0";
			}
			if(deco['h_flip'] != null && deco['h_flip'] == true)
				transform += " scale3d(-1,1,1)";
			d.style.transform = transform;
			_image = d.clone(false);
		}
	}

	ImageElement get image => _image;

	int get zIndex => _zIndex;
	int get x => _x;
	int get y => _y;
	int get w => _w;
	int get h => _h;

	int compareTo(Deco other) => zIndex.compareTo(other.zIndex);
}