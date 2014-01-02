part of coUclient;

UserInterface ui = new UserInterface();
Chat chat = new Chat();

class UserInterface 
{
	//NumberFormat for having commas in the currants and iMG displays
	NumberFormat commaFormatter = new NumberFormat("#,###");
	
	// Name Meter Variables
	DivElement nameMeter = querySelector('#PlayerName');
	
	// Currant Meter Variables
	SpanElement currantMeter = querySelector('#CurrCurrants');
	
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
		
		//Set up the Currant Display
		setCurrants('0');
		
		// This should actually pull from an online source..
		setEnergy('100');
		setMaxEnergy('100');
		setMood('100');
		setMaxMood('100');
		
		chat.init();
	}
	
	_setEnergy(int newValue)
	{
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
		currantMeter.text = commaFormatter.format(newValue);
	}
	
	_setImg(int newValue)
	{
		imgMeter.text = commaFormatter.format(newValue);
	}
	
	_setName(String newValue)
	{
		if (newValue.length >= 17)
	    	newValue = newValue.substring(0, 15) + '...';
	  	nameMeter.text = newValue;
	}
	
	_setSong(String artist, String song)
	{
		titleMeter.text = song;
		artistMeter.text = artist;    
	} 
	
	_setMute(String isMuted)
	{
		Element audioGlyph = querySelector('#AudioGlyph');
		if(isMuted != null && isMuted == '1') //set to muted
		{
			(querySelector('#VolumeSlider') as InputElement).disabled = true;
			audioGlyph.innerHtml = '<img src="./assets/system/mute.png" class="centered-icon glyph">'; //hack to have mute icon be centered
			setVolume('0');
			localStorage['isMuted'] = '1';
		}
		else //set to unmuted
		{
			(querySelector('#VolumeSlider') as InputElement).disabled = false;
			audioGlyph.innerHtml = '<i id="VolumeGlyph" class="icon-volume-up glyph icon-large"></i>';
			setVolume(localStorage['prevVolume']);
			localStorage['isMuted'] = '0';
		}
	}
}

resize()
{
	Element gameScreen = querySelector('#GameScreen');
	//Element gameStage = querySelector('#GameStage');
	
	//width and height calculations done here are now done in CSS
	gameScreenWidth = gameScreen.clientWidth;
	gameScreenHeight = gameScreen.clientHeight;
	
	//approx 1308px wide is the minimum width for the window to show everything well
	//according to Paul, we should be able to see at least a few lines of chat in each box - this means
	//minimum height is about 325px
	if(window.innerWidth < 1308 || window.innerHeight < 325)
		querySelector('#SizeWarning').hidden = false;
	else
		querySelector('#SizeWarning').hidden = true;
}
	
// Manages the elements that display the date and time.
refreshClock()
{
	List data = getDate();
	querySelector('#CurrDay').innerHtml = data[3].toString();
	querySelector('#CurrTime').innerHtml = data[4].toString();
	querySelector('#CurrDate').innerHtml = data[2].toString() + ' of ' + data[1].toString();
}