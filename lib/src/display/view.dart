part of couclient;

UserInterface view;

class UserInterface {
	/////////////////////ELEMENTS//////////////////////////////////////////////
	// you won! element
	Element youWon = querySelector('#youWon');

	// Initial loading screen elements
	Element loadStatus = querySelector("#loading #loadstatus");
	Element loadStatus2 = querySelector("#loading #loadstatus2");
	Element loadingScreen = querySelector('#loading');
	Element loadingSpinner = querySelector('#loading .fa-spin');

	// Time Meter Variables
	Element currDay = querySelector('#currDay');
	Element currTime = querySelector('#currTime');
	Element currDate = querySelector('#currDate');

	// Location and Map elements
	Element currLocation = querySelector('#currLocation');
	Element mapButton = querySelector('#mapButton');

	// Settings Glyph
	Element settingsButton = querySelector('#settingsGlyph');

	// Inventory Management
	Element inventorySearch = querySelector('#inventorySearch');
	Element inventory = querySelector("#inventory");

	// Pause button
	Element pauseButton = querySelector('#thinkButton');

	// settings window elements
	ElementList tabs = querySelectorAll('article .tab');

	// teleport window
	Element tpButton = querySelector("#tpGlyph");

	// bugreport button
	Element bugButton = querySelector('#bugGlyph');
	Element bugReportMeta = querySelector('#bugWindow #reportMeta');
	InputElement bugReportTitle = querySelector('#bugWindow #reportTitle');
	SelectElement bugReportType = querySelector('#bugWindow #reportCategory');
	CheckboxInputElement bugScreenshot = querySelector('#bugWindow #reportScreenshot');

	// main Element
	Element mainElement = querySelector('main');

	// world Element
	Element worldElement = querySelector('#world');
	int worldElementWidth, worldElementHeight;
	Element playerHolder = querySelector("#playerHolder");
	Element layers = querySelector("#layers");

	//Location/Map Variables
	Element mapWindow = querySelector('#mapWindow');
	Element mapImg = querySelector('#mapImage');
	Element mapTitle = querySelector('#mapTitle');
	CanvasElement mapCanvas = querySelector('#MapCanvas');

	// Chat panel
	Element panel = querySelector('#panel');
	Element chatTemplate = querySelector('#conversationTemplate');

	Element conversationArchive = querySelector("#conversationArchive");

	// bugreport button
	Element logoutButton = querySelector('#signoutGlyph');


	/////////////////////ELEMENTS//////////////////////////////////////////////


	// Declare/Set initial variables here
	/////////////////////VARS//////////////////////////////////////////////////

	String location = 'null';

	/////////////////////VARS//////////////////////////////////////////////////

	// Object for manipulating meters.
	Meters meters = new Meters();

	VolumeSliderWidget slider = new VolumeSliderWidget();
	SoundCloudWidget soundcloud = new SoundCloudWidget();

	loggedIn() {
		loadStatus2.text = "Preparing world...";
		new Service(['streetLoaded'], (_) {
			loadingScreen.style.opacity = '0';
			new Timer(new Duration(seconds: 1), () {
				loadingScreen.hidden = true;
			});
		});
	}

	loggedOut() {
		loadStatus2.text = "Chatting with server...";
		loadingScreen.hidden = false;
		new Timer(new Duration(seconds: 1), () {
			loadingScreen.style.opacity = '1';
		});
	}

	// start listening for events
	UserInterface() {

		// Set initial Time
		currDay.text = clock.dayofweek;
		currTime.text = clock.time;
		currDate.text = clock.day + ' of ' + clock.month;

		// Listens for the logout button
		logoutButton.onClick.listen((_) {
			auth.logout();
		});

		// The 'you won' splash
		window.onBeforeUnload.listen((_) {
			youWon.hidden = false;
			transmit("gameUnloading");
		});

		// Listens for the pause button
		Element pauseMenu = querySelector("#pauseMenu");
		pauseButton.onClick.listen((_) {
			if (pauseMenu.hidden) {
				imgMenu.open();
			} else {
				imgMenu.close();
			}
		});

		new Service(['timeUpdate'], (event) {
			currDay.text = clock.dayofweek;
			currTime.text = clock.time;
			currDate.text = clock.day + ' of ' + clock.month;
		});

		new Service(['doneLoading'], (event) {
			// display 'Play' buttons
			for(Element button in loadingScreen.querySelectorAll('.button'))
				button.hidden = false;
		});

		//listen for resizing of the window so we can keep track of how large the
		//world element is so that we don't remeasure it often
		resize();
		window.onResize.listen((_) => resize());

		setUpOverlays();

		new Service(["streetLoaded"], (_) {
			// Update the max size of the game when a new street is loaded
			if (mapData.boundsExpansionDisabled()) {
				mainElement.style
				..maxHeight = null
				..maxWidth = null;
			} else {
				mainElement.style
				// Add 140px vertical space for UI
					..maxHeight = (currentStreet.bounds.height + 140).toString() + "px"
				// Add 280px horizontal space for UI
					..maxWidth = (currentStreet.bounds.width + 280).toString() + "px";
			}
			resize();
		});

		// Track game focus
		worldElement
			..onFocus.listen((_) => transmit("worldFocus", true))
			..onBlur.listen((_) => transmit("worldFocus", false));

		new Service(["gameLoaded"], (_) {
			// Shift + click inventory items -> chat link
			inventory.querySelectorAll(".box").onClick.listen((MouseEvent e) {
				Element target = e.target;

				if (!e.shiftKey || !target.classes.contains("inventoryItem") || Chat.lastFocusedInput == null) {
					return;
				}

				String itemType = jsonDecode(target.attributes["itemmap"])["itemType"];

				if (Chat.lastFocusedInput.value == "" || Chat.lastFocusedInput.value.endsWith(" ")) {
					Chat.lastFocusedInput.value += "#$itemType#";
				} else {
					Chat.lastFocusedInput.value += " #$itemType#";
				}

				Chat.lastFocusedInput.focus();
			});

			// Inventory number keys
			MenuKeys.invSlotsListener();
		});
	}

	resize() {
		worldElementWidth = worldElement.clientWidth;
		worldElementHeight = worldElement.clientHeight;
		transmit('windowResized',null);
	}
}


// This is Robert's touchscroller class for handling
// touchscreen scroll compatability.
/////////////////////TOUCHSCROLLER///////////////////////////////////////
class TouchScroller {
	static int HORIZONTAL = 0,
	VERTICAL = 1,
	BOTH = 2;
	Element _scrollDiv;
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
			if(_direction == HORIZONTAL || _direction == BOTH) _scrollDiv.scrollLeft = _scrollDiv.scrollLeft + diffX;
			if(_direction == VERTICAL || _direction == BOTH) _scrollDiv.scrollTop = _scrollDiv.scrollTop + diffY;
		});
	}
}
