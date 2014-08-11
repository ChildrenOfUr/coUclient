part of couclient;

class Signpost
{
	DivElement pole;
	
	Signpost(Map signpost, int x, int y, DivElement interactionsCanvas, DivElement gradientCanvas)
	{		
		pole = new DivElement()
	        ..style.backgroundImage = "url('http://childrenofur.com/locodarto/scenery/sign_pole.png')"
	        ..style.backgroundRepeat = "no-repeat"
	        ..style.width = signpost['w'].toString() + "px"
	        ..style.height = signpost['h'].toString() + "px"
	        ..style.position = "absolute"
	        ..style.top = y.toString() + "px"
	        ..style.left = (x-48).toString() + "px";
		interactionsCanvas.append(pole);
                  
		int i=0;
		List signposts = signpost['connects'] as List;
		for(Map<String,String> exit in signposts)
  		{
    		if(exit['label'] == playerTeleFrom || playerTeleFrom == "console")
			{
    			//TODO: after player is re-implemented
  				//CurrentPlayer.posX = x;
  				//CurrentPlayer.posY = y;
			}

			String tsid = exit['tsid'].replaceFirst("L", "G");
			SpanElement span = new SpanElement()
        		..style.position = "absolute"
  				..style.top = (y+i*25+10).toString() + "px"
  				..style.left = x.toString() + "px"
  				..text = exit["label"]
  				..className = "ExitLabel"
				..attributes['url'] = 'http://RobertMcDermot.github.io/CAT422-glitch-location-viewer/locations/$tsid.callback.json'
				..attributes['tsid'] = tsid
				..attributes['from'] = currentStreet.label
				..style.transform = "rotate(-5deg)";

			if(i %2 != 0)
			{
				//this is a temporary append so that we can figure out its width
  				gradientCanvas.append(span);
  				span.style.left = (x-span.clientWidth).toString() + "px";
  				span.style.transform = "rotate(5deg)";
    		}

    		interactionsCanvas.append(span);
    		i++;
  		}
	}
}