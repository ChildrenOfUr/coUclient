part of coUclient;

Street currentStreet;

Camera camera = new Camera(0,400);
class Camera
{
	num x,y;
	num zoom = 0; // for future eyeballery
	Camera(this.x,this.y)
	{
    	COMMANDS.add(['camera','sets the cameras position "camera x,y"',this.setCamera]);
	}
	
  	// we're using css transitions for smooth scrolling.
	setCamera(String xy) //  format 'x,y'
	{
		try
		{
			this.x = int.parse(xy.split(',')[0]); 
			this.y = int.parse(xy.split(',')[1]);
		}
		catch (exception, stacktrace)
		{
			printConsole("error: format must be camera [num],[num]");
		}
	}
}

DivElement gameScreen = querySelector('#GameScreen');

class Street 
{    
	String label;
	Map _data;
	CanvasElement belowPlayer = new CanvasElement();
	CanvasElement abovePlayer = new CanvasElement();
	
	Rectangle bounds;
  
	Street(String streetName)
	{
		_data = ASSET[streetName].get();
     
		// sets the label for the street
		label = _data['label'];
          
		bounds = new Rectangle(_data['dynamic']['l'],
								_data['dynamic']['t'],
								_data['dynamic']['l'].abs() + _data['dynamic']['r'].abs(),
								_data['dynamic']['t'].abs());
	}
  
	Future <List> load()
	{
		Completer c = new Completer();
		// clean up old street data
		currentStreet = null;
   
		// set the song loading if necessary
		if (_data['music'] != null)
			setSong(_data['music']);
   
		// Collect the url's of each deco to load.
		List decosToLoad = [];
		for (Map layer in _data['dynamic']['layers'].values)
		{
			for (Map deco in layer['decos'])
			{
				if (!decosToLoad.contains('http://revdancatt.github.io/CAT422-glitch-location-viewer/img/scenery/' + deco['filename'] + '.png'))
        			decosToLoad.add('http://revdancatt.github.io/CAT422-glitch-location-viewer/img/scenery/' + deco['filename'] + '.png');
			}
		}
		var end = new DateTime.now();
    
		// turn them into assets
		List assetsToLoad = [];
		for (String deco in decosToLoad)
		{
			assetsToLoad.add(new Asset(deco));
		}
		
		// Load each of them, and then continue.
		Batch decos = new Batch(assetsToLoad);
		decos.load(setStreetLoadBar).then((_)
        {
			//Decos should all be loaded at this point//
			
			// set the street.
			currentStreet = this;
		      
			/* //// Gradient Canvas //// */
			DivElement gradientCanvas = new DivElement();
			gradientCanvas.classes.add('streetcanvas');
			gradientCanvas.id = 'gradient';
			gradientCanvas.style.zIndex = (-100).toString();
			gradientCanvas.style.width = bounds.width.toString() + "px";
			gradientCanvas.style.height = bounds.height.toString() + "px";
			gradientCanvas.style.position = 'absolute';
			
			// Color the gradientCanvas
			String top = _data['gradient']['top'];
			String bottom = _data['gradient']['bottom'];
			gradientCanvas.style.background = "-webkit-linear-gradient(top, #$top, #$bottom)";
			gradientCanvas.style.background = "-moz-linear-gradient(top, #$top, #$bottom)";
			gradientCanvas.style.background = "-ms-linear-gradient(#$top, #$bottom)";
			gradientCanvas.style.background = "-o-linear-gradient(#$top, #$bottom)";
			
			// Append it to the screen*/
			gameScreen.append(gradientCanvas);
		    
			/* //// Scenery Canvases //// */
			//For each layer on the street . . .
			for (Map layer in new Map.from(_data['dynamic']['layers']).values)
			{
				DivElement decoCanvas = new DivElement()
					..classes.add('streetcanvas');
				decoCanvas.id = layer['name'];
				
				decoCanvas.style.zIndex = layer['z'].toString();
				decoCanvas.style.width = layer['w'].toString() + 'px';
				decoCanvas.style.height = layer['h'].toString() + 'px';
				decoCanvas.style.position = 'absolute';
		      
				//For each decoration in the layer, give its attributes and draw
				
				//TODO: FIX THIS
				//Parallax and such is working, BUT
				//Not all images are drawing at the correct y values.
				//It seems this int.y makes foreground and background work, but not middleground???
				List<ImageElement> decos = new List<ImageElement>();
				for (Map deco in layer['decos'])
				{
					int x = deco['x'] - deco['w']~/2;
					int y = deco['y'] - deco['h'] + _data['dynamic']['ground_y'];
					if(layer['name'] == 'middleground')
					{
						y += layer['h'];
						x += layer['w']~/2;
					}
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
						if(deco['h_flip'] != null && deco['h_flip'] == true)
							transform += "scale(-1,1)";
						if(deco['r'] != null)
							transform += " rotate("+(PI/180*deco['r']).toString()+"deg)";
						d.style.transform = transform;
						decoCanvas.append(d.clone(false));
					}
				}
				
				// Append the canvas to the screen
				gameScreen.append(decoCanvas);
			}
			
			c.complete(this);
		});
        // Done initializing street.
		return c.future;
	}
 
	//Parallaxing: Adjust the position of each canvas in #GameScreen
	//based on the camera position and relative size of canvas to Street
	render()
	{
		num currentPercentX = camera.x / (bounds.width - gameScreen.clientWidth);
		num currentPercentY = camera.y / (bounds.height - gameScreen.clientHeight);
		
		//modify left and top for parallaxing
		for (DivElement canvas in gameScreen.querySelectorAll('.streetcanvas'))
		{
			double offsetX = (canvas.clientWidth - gameScreen.clientWidth) * currentPercentX;
			double offsetY = (canvas.clientHeight - gameScreen.clientHeight) * currentPercentY;

			canvas.style.transform = "translateZ(0) translateX("+(-offsetX).toString()+"px) translateY("+(-offsetY).toString()+"px)";
		}
	}
}

// Initialization, loads all the streets in our master file into memory.
Future load_streets()
{
	querySelector("#LoadStatus").text = "Loading Streets";
	// allows us to load street files as though they are json files.
	jsonExtensions.add('street');
	
	Completer c = new Completer();

	// loads the master street json.
	new Asset('./assets/streets.json').load().then((Asset streetList) 
	{
		// Load each street file into memory. If this gets too expensive we'll move this elsewhere.
		List toLoad = [];
		for (String url in streetList.get().values)
			toLoad.add(new Asset(url).load(querySelector("#LoadStatus2")));
		
		c.complete(Future.wait(toLoad));
	});
	
	return c.future;
}

// the callback function for our deco loading 'Batch'
setStreetLoadBar(int percent)
{
	querySelector('#StreetLoadingStatus').text = 'loading decos...';
	querySelector('#MapLoadingBar').style.width = (percent + 1).toString() + '%';
	if (percent >= 99)
	{
		querySelector('#StreetLoadingStatus').text = '...done';
		querySelector('#MapLoadingScreen').style.opacity = '0.0';
	}
}