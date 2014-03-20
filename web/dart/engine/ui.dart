part of coUclient;

UserInterface ui = new UserInterface();
Chat chat = new Chat();

class UserInterface 
{
	//NumberFormat for having commas in the currants and iMG displays
	NumberFormat commaFormatter = new NumberFormat("#,###");
	
	//store the gameScreen.clientWidth and height so that we don't have to query it at render time
	//causing the DOM to be reflowed
	num gameScreenWidth, gameScreenHeight;
	
	// Name Meter Variables
	DivElement nameMeter = querySelector('#PlayerName');
	
	// Currant Meter Variables
	SpanElement currantMeter = querySelector('#CurrCurrants');
	int _currants = 0;
	
	// Img Meter Variables
	SpanElement imgMeter = querySelector('#CurrImagination');
	
	// Music Meter Variables
	SpanElement titleMeter = querySelector('#TrackTitle');
	SpanElement artistMeter = querySelector('#TrackArtist');
	SC sc = new SC('7d2a07867f8a3d47d4f059b600b250b1');
	Map jukebox = new Map();
	Scound currentSong;
	
	// Energy Meter Variables
	Element _energymeterImage = querySelector('#EnergyIndicator');
	Element _energymeterImageLow = querySelector('#EnergyIndicatorRed');
	Element _currEnergyText = querySelector('#CurrEnergy');
	Element _maxEnergyText = querySelector('#MaxEnergy');
	int _energy = 100;
	int _maxenergy = 100;
	int _emptyAngle = 10;
	int _angleRange = 120;// Do not change!
	
	// Mood Meter Variables
	Element _moodmeterImageLow =  querySelector('#MoodCircleRed');
	Element _moodmeterImageEmpty = querySelector('#MoodCircleEmpty');
	int _mood = 100;
	int _maxmood = 100;
	Element _currMoodText = querySelector('#CurrMood');
	Element _maxMoodText = querySelector('#MaxMood');
	Element _moodPercent = querySelector('#MoodPercent');
	
	int _img = 0;
		
	//Location/Map Variables
	DivElement currLocation =  querySelector('#Location');
	ImageElement map =  querySelector('#MapGlyph');
	
	UserInterface()
	{
		_maxEnergyText.innerHtml = _maxenergy.toString();
	}
	
	init()
	{
		//Start listening for the game's exit and display "You Won!"
		window.onBeforeUnload.listen((_)
		{
			querySelector('#YouWon').hidden = false;    
		});
		
		//Start listening for page resizes.
		resize();
		window.onResize.listen((_) => resize());
		
		//TODO: This should actually pull from an online source..
		setEnergy('100');
		setMaxEnergy('100');
		setMood('100');
		setMaxMood('100');
		if(localStorage["currants"] != null)
        	_currants = int.parse(localStorage["currants"]);
		if(localStorage["img"] != null)
			_img = int.parse(localStorage["img"]);
		
		//Set up the Currant Display
		setCurrants(_currants.toString());
		setImg(_img.toString());
		
		currLocation.text = currentStreet.label;
	}
	
	_setEnergy(int newValue)
	{
		if(newValue > _maxenergy)
			return;
		
		_energy = newValue;
		_currEnergyText.parent.parent.classes.toggle('changed',true);
		Timer t = new Timer(new Duration(seconds:1),() => _currEnergyText.parent.parent.classes.toggle('changed'));
		_currEnergyText.text=_energy.toString();
		String angle = ((_angleRange - (_energy/_maxenergy)*_angleRange).toInt()).toString();
		_energymeterImage.style.transform = 'rotate(' +angle+ 'deg)';
		_energymeterImageLow.style.transform = 'rotate(' +angle+ 'deg)';
		_energymeterImageLow.style.opacity = ((1-(_energy/_maxenergy))).toString();    
	}
	 
	_setMood(int newValue)
	{
		if(newValue > _maxmood)
			return;
		
		_mood = newValue;
		_currMoodText.parent.classes.toggle('changed', true);
		Timer t = new Timer(new Duration(seconds:1),() => _currMoodText.parent.classes.toggle('changed'));
		_currMoodText.text=_mood.toString();
		_moodPercent.text=((100*((_mood/_maxmood))).toInt()).toString();
		_moodmeterImageLow.style.opacity = ((0.7-(_mood/_maxmood))).toString();
		
		if (_mood <= 0)
			_moodmeterImageEmpty.style.opacity = 1.toString();
		else
			_moodmeterImageEmpty.style.opacity = 0.toString();
	}
	
	_setCurrants(int newValue)
	{
		_currants = newValue;
		currantMeter.text = commaFormatter.format(newValue);
	}	
	
	_setImg(int newValue)
	{
		_img = newValue;
		imgMeter.text = commaFormatter.format(newValue);
	}
	
	int _getCurrants()
	{
		return _currants;
	}
	
	int _getEnergy()
	{
		return _energy;
	}
	
	int _getMood()
	{
		return _mood;
	}
	
	int _getImg()
	{
		return _img;
	}
	
	_setName(String newValue)
	{
		if (newValue.length >= 17)
	    	newValue = newValue.substring(0, 15) + '...';
	  	nameMeter.text = newValue;
	}
	
	_setLocation(String label)
	{
		currLocation.text = label;
	}
	
	_setSong(String artist, String song)
	{
		titleMeter.text = song;
		artistMeter.text = artist;    
	} 
	
	_setMute(String isMuted)
	{
		Element audioGlyph = querySelector('#AudioGlyph');
		Element mobileAudioGlyph = querySelector('#MobileAudioGlyph');
		if(isMuted != null && isMuted == '1') //set to muted
		{
			(querySelector('#VolumeSlider') as InputElement).disabled = true;
			audioGlyph.innerHtml = '<img src="./assets/system/mute.png" class="centered-icon glyph">'; //hack to have mute icon be centered
			mobileAudioGlyph.innerHtml = '<img src="./assets/system/mute.png" class="centered-icon glyph">';
			setVolume('0',true);
			localStorage['isMuted'] = '1';
		}
		else //set to unmuted
		{
			(querySelector('#VolumeSlider') as InputElement).disabled = false;
			audioGlyph.innerHtml = '<i id="VolumeGlyph" class="fa fa-volume-up glyph fa-lg"></i>';
			mobileAudioGlyph.innerHtml = '<i id="VolumeGlyph" class="fa fa-lg fa-volume-up"></i>';
			setVolume(localStorage['prevVolume'],false);
			localStorage['isMuted'] = '0';
		}
	}
}

resize()
{
	Element gameScreen = querySelector('#GameScreen');
	
	//width and height calculations done here are now done in CSS
	ui.gameScreenWidth = gameScreen.clientWidth;
	ui.gameScreenHeight = gameScreen.clientHeight;
	
	//approx 1308px wide is the minimum width for the window to show everything well
	//according to Paul, we should be able to see at least a few lines of chat in each box - this means
	//minimum height is about 325px
	Element warningMessage = querySelector('#SizeWarning');
	if(window.innerWidth < 1308 || window.innerHeight < 325)
		warningMessage.hidden = false;
	else
		warningMessage.hidden = true;
	
	if(window.innerWidth < 1308)
		warningMessage.text = "Warning, the window should be at least 1308px wide to display the game well.";
	if(window.innerHeight < 325)
		warningMessage.text = "Warning, the window should be at least 325px high to display the game well.";
	if(window.innerWidth < 1308 && window.innerHeight < 325)
		warningMessage.text = "Warning, the window should be at least 1308px wide and 325px high to display the game well.";
}
	
// Manages the elements that display the date and time.
refreshClock()
{
	List data = getDate();
	querySelector('#CurrDay').innerHtml = data[3].toString();
	querySelector('#CurrTime').innerHtml = data[4].toString();
	querySelector('#CurrDate').innerHtml = data[2].toString() + ' of ' + data[1].toString();
}