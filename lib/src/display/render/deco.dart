part of couclient;

class Deco
{
	Deco(Map deco, int x, int y, DivElement attachToCanvas)
	{
		int w = deco['w'];
  		int h = deco['h'];
  		int z = deco['z'];
    
  		// only draw if the image is loaded.
  		if (ASSET[deco['filename']] != null)
  		{
    		ImageElement d = ASSET[deco['filename']].get();
    
    		d.style.position = 'absolute';
		    d.style.left = x.toString() + 'px';
		    d.style.top = y.toString() + 'px';
		    d.style.width = w.toString() + 'px';
		    d.style.height = h.toString() + 'px';
		    d.style.zIndex = z.toString();
    
		    String transform = "";
		    if(deco['r'] != null)
		    {
		      transform += "rotate("+deco['r'].toString()+"deg)";
		      d.style.transformOrigin = "50% bottom 0";
		    }
		    if(deco['h_flip'] != null && deco['h_flip'] == true)
		                  transform += " scale(-1,1)";
		    d.style.transform = transform;
		    attachToCanvas.append(d.clone(false));
		}
	}
}