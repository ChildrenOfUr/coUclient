part of couclient;

UserInterface ui = new UserInterface();

class UserInterface extends Pump {

//NumberFormat for having commas in the currants and iMG displays
	NumberFormat commaFormatter = new NumberFormat("#,###");
	
  // If you need to change an element somewhere else, put the declaration in this class.
  // You can then access it with 'ui.yourElement'. This way we keep everything in one spot
  /////////////////////ELEMENTS//////////////////////////////////////////////
  // you won! element
  Element youWon = querySelector('#youWon');

  // Initial play button
  Element playButton = querySelector('#playButton');

  // Initial loading screen elements
  Element loadStatus = querySelector("#loading #loadstatus");
  Element loadStatus2 = querySelector("#loading #loadstatus2");
  Element loadingScreen = querySelector('#loading');
  Element loadingSpinner = querySelector('#loading .fa-spin');
  Element streetLoading = querySelector("#streetLoading");
  
  // Name Meter Variables
  Element nameElement = querySelector('#playerName');

  // Time Meter Variables
  Element currDay = querySelector('#currDay');
  Element currTime = querySelector('#currTime');
  Element currDate = querySelector('#currDate');

  // Location and Map elements
  Element currLocation = querySelector('#currLocation');
  Element mapButton = querySelector('#mapButton');

  // Settings Glyph
  Element settingsButton = querySelector('#settingsGlyph');

  // Currant Meter Variables
  Element currantElement = querySelector('#currCurrants');

  // Img Meter Variables
  Element imgElement = querySelector('#currImagination');

  // Inventory Management
  Element inventorySearch = querySelector('#inventorySearch');
  Element inventory = querySelector("#inventory");

  // Pause button
  Element pauseButton = querySelector('#thinkButton');
  Element pauseMenu = querySelector('#pauseMenu');

  // settings window elements
  ElementList settingsTabs = querySelectorAll('#settingsWindow article .tab');
  
  
  // bugreport button
  Element bugButton = querySelector('#bugGlyph');
  Element consoleText = new DivElement();//querySelector('.dialog.console');

  // main Element
  Element mainElement = querySelector('main');
  
  // world Element
  Element worldElement = querySelector('#world');
  Element playerHolder = querySelector("#playerHolder");
  Element layers = querySelector("#layers");
  int worldWidth, worldHeight;


  // Music Meter Variables
  Element titleElement = querySelector('#trackTitle');
  Element artistElement = querySelector('#trackArtist');
  AnchorElement SClinkElement = querySelector('#SCLink');
  Element volumeGlyph = querySelector('#volumeGlyph');
  InputElement volumeSlider = querySelector('#volumeSlider *');


  // Energy Meter Variables
  Element energymeterImage = querySelector('#energyDisks .green');
  Element energymeterImageLow = querySelector('#energyDisks .red');
  Element currEnergyText = querySelector('#currEnergy');
  Element maxEnergyText = querySelector('#maxEnergy');

  // Mood Meter Variables
  Element moodmeterImageLow = querySelector('#leftDisk .hurt');
  Element moodmeterImageEmpty = querySelector('#leftDisk .dead');
  Element currMoodText = querySelector('#moodMeter .fraction .curr');
  Element maxMoodText = querySelector('#moodMeter .fraction .max');
  Element moodPercent = querySelector('#moodMeter .percent .number');

  // Chat panel
  Element panel = querySelector('#panel');
  Element chatTemplate = querySelector('#conversationTemplate');
  
  //fps meter
  Element fpsDisplay = querySelector('#fps');
  
  /////////////////////ELEMENTS//////////////////////////////////////////////


  // Declare/Set initial variables here
  /////////////////////VARS//////////////////////////////////////////////////
  String username = 'null';

  String location = 'null';

  bool muted = false;
  int volume = 0;
  String SCsong = '-';
  String SCartist = '-';
  String SClink = '';

  /////////////////////VARS//////////////////////////////////////////////////


  // start listening for events
  UserInterface() {
    
    //load emoticons
    new Asset("packages/couclient/emoticons/emoticons.json").load().then((Asset asset) => EMOTICONS = asset.get()["names"]);

    // Set initial Time
    currDay.text = clock.dayofweek;
    currTime.text = clock.time;
    currDate.text = clock.day + ' of ' + clock.month;

    // Load saved volume level
    if (local['volume'] != null) {
      volume = int.parse(local['volume']);
    } else volume = 10;

    // The 'you won' splash
    window.onBeforeUnload.listen((_) {
      youWon.hidden = false;
    });
    
	//Start listening for page resizes.
	_resize();
	window.onResize.listen((_) => _resize());

    // Starts the game
    playButton.onClick.listen((_) {
      loadingScreen.style.opacity = '0';
      new Moment('PlaySound', 'game_loaded');
      new Timer(new Duration(seconds: 1), () {
        loadingScreen.remove();
      });
    });


    // Listens for the pause button
    pauseButton.onClick.listen((_) {
      pauseMenu.hidden = false;
    });


    // Controls the volume slider and glyph
    volumeGlyph.onClick.listen((_) {
      if (session['volume'] == null) session['volume'] = '5';
      if (muted == true) {
        volume = int.parse(session['volume']);
        muted = false;
        volumeSlider.value = volume.toString();
      } else if (muted == false) {
        session['volume'] = volume.toString();
        muted = true;
        volumeSlider.value = '0';
      }
    });



    this & EVENT_BUS;
  }
  
	void _resize()
	{
	  	worldWidth = worldElement.clientWidth;
	  	worldHeight = worldElement.clientHeight;
	}

  process(var event) {

    // CHAT EVENT HANDLERS //
    // ChatEvents are drawn to their Conversation.
    if (event.isType('ChatEvent')) {
      for (Chat convo in openConversations) {
        if (convo.title == event.content['channel']) convo.addMessage(event.content['username'], event.content['message']);
      }
    }
    // List online players
    if (event.isType('ChatListEvent')) {
      for (Chat convo in openConversations) {
        if (convo.title == event.content['channel']) convo.addAlert("Players in this Channel:  ${event.content['users']}".replaceAll('[', '').replaceAll(']', ''));
      }
    }
    // StartChat events start a Conversation
    if (event.isType('StartChat')) {
      Chat chat = new Chat(event.content as String);
      openConversations.add(chat);
	  //handle chat input getting focused/unfocused so that the character doesn't move while typing
	  ElementList chatInputs = querySelectorAll('.Typing');
	  chatInputs.onFocus.listen((_) {
	    inputManager.ignoreKeys = true;
	  });
	  chatInputs.onBlur.listen((_) {
	    inputManager.ignoreKeys = false;
	  });
    }
    // MISC EVENT HANDLERS //
    if (event.isType('TimeUpdate')) {
      currDay.text = clock.dayofweek;
      currTime.text = clock.time;
      currDate.text = clock.day + ' of ' + clock.month;
    }
    if (event.isType('DoneLoading')) {
      // display 'Play' buttons
      for (Element button in loadingScreen.querySelectorAll('.button')) button.hidden = false;
      loadingScreen.querySelector('.fa').hidden = true;
    }
  }

  // update the userinterface
  update() {

    // Update name display
    if (username.length >= 17) username = username.substring(0, 15) + '...';
    if (username != nameElement.text) nameElement.text = username;


    // Update the location text
    if (location.length >= 20) location = location.substring(0, 17) + '...';
    if (location != currLocation.text) currLocation.text = location;


    // Update the audio icon
    if (muted == true && volumeGlyph.classes.contains('fa-volume-up')) {
      volumeGlyph.classes
          ..remove('fa-volume-up')
          ..add('fa-volume-off');
    }
    if (muted == false && volumeGlyph.classes.contains('fa-volume-off')) {
      volumeGlyph.classes
          ..remove('fa-volume-off')
          ..add('fa-volume-up');
    }

    // Update the volume slider
    if (int.parse(volumeSlider.value) == 0) muted = true; else muted = false;
    if (volume != int.parse(volumeSlider.value)) {
      volume = int.parse(volumeSlider.value);
    }

    // Updates the stored volume level
    if (volume.toString() != local['volume'] && muted == false) local['volume'] = volume.toString();

    // Update all audioElements to the correct volume
    for (AudioElement audio in querySelectorAll('audio')) {
      if (audio.volume != ui.volume / 100) audio.volume = ui.volume / 100;


      // Update the soundcloud widget
      if (SCsong != titleElement.text) titleElement.text = SCsong;
      if (SCartist != artistElement.text) artistElement.text = SCartist;
      if (SClink != SClinkElement.href) SClinkElement.href = SClink;

    }
    window.requestAnimationFrame((_) => this.update());
  }
}



// This is Robert's touchscroller class for handling
// touchscreen scroll compatability.
/////////////////////TOUCHSCROLLER///////////////////////////////////////
class TouchScroller {
  static int HORIZONTAL = 0,
      VERTICAL = 1,
      BOTH = 2;
  DivElement _scrollDiv;
  int _startX, _startY, _lastX, _lastY, _direction;

  TouchScroller(this._scrollDiv, this._direction) {
    _scrollDiv.onTouchStart.listen((TouchEvent event) {
      event.stopPropagation();
      _startX = event.changedTouches.first.client.x;
      _startY = event.changedTouches.first.client.y;
      _lastX = _startX;
      _lastY = _startY;
    });
    _scrollDiv.onTouchMove.listen((TouchEvent event) {
      event.preventDefault();
      int diffX = _lastX - event.changedTouches.single.client.x;
      int diffY = _lastY - event.changedTouches.single.client.y;
      _lastX = event.changedTouches.single.client.x;
      _lastY = event.changedTouches.single.client.y;
      if (_direction == HORIZONTAL || _direction == BOTH) _scrollDiv.scrollLeft = _scrollDiv.scrollLeft + diffX;
      if (_direction == VERTICAL || _direction == BOTH) _scrollDiv.scrollTop = _scrollDiv.scrollTop + diffY;
    });
  }
}


