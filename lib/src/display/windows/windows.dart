part of couclient;

class WindowManager {
	// Declaring all the possible popup windows
	AchievementsWindow achievements;
	AddFriendWindow addFriendWindow;
	AvatarWindow avatarWindow;
	BugWindow bugs;
	CalendarWindow calendarWindow;
	ChangeUsernameWindow changeUsernameWindow;
	EmoticonPicker emoticonPicker;
	InventorySearchWindow inventorySearchWindow;
	MotdWindow motdWindow;
	QuestLogWindow questLog;
	QuestMakerWindow questMaker;
	RockWindow rockWindow;
	SettingsWindow settings;
	VendorWindow vendor;
	WeatherWindow weather;

	WindowManager() {
		new Service('gameLoaded', (_) {
			//needs to have game.username defined first
			questMaker = new QuestMakerWindow();
		});

		// Defining all the possible popup windows
		achievements = new AchievementsWindow();
		addFriendWindow = new AddFriendWindow();
		avatarWindow = new AvatarWindow();
		bugs = new BugWindow();
		calendarWindow = new CalendarWindow();
		changeUsernameWindow = new ChangeUsernameWindow();
		emoticonPicker = new EmoticonPicker();
		inventorySearchWindow = new InventorySearchWindow();
		mapWindow = new MapWindow();
		motdWindow = new MotdWindow();
		questLog = new QuestLogWindow();
		rockWindow = new RockWindow();
		settings = new SettingsWindow();
		weather = new WeatherWindow();
		vendor = new VendorWindow();
	}

	static int get randomId => random.nextInt(9999999);
}

class AuctionWindow extends Modal {
	String id = 'auctionWindow';

	AuctionWindow() {
		prepare();
	}
}

Map<String, Modal> modals = {};

/// A Dart interface to an html Modal
abstract class Modal extends InformationDisplay {
	String id;
	StreamSubscription escListener;

	open({bool ignoreKeys: false}) {
		if(displayElement == null) {
			return;
		}

		inputManager.ignoreKeys = ignoreKeys;
		displayElement.hidden = false;
		elementOpen = true;
		this.focus();
	}

	close() {
		if(displayElement == null) {
			return;
		}

		inputManager.ignoreKeys = false;
		_destroyEscListener();
		displayElement.hidden = true;
		elementOpen = false;

		//see if there's another window that we want to focus
		for (Element modal in querySelectorAll('.window')) {
			if (!modal.hidden) {
				modals[modal.id]?.focus();
			}
		}
	}

	focus() {
		for (Element others in querySelectorAll('.window')) {
			others.style.zIndex = '2';
		}
		this.displayElement.style.zIndex = '3';
		displayElement.focus();
	}

	_createEscListener() {
		if (escListener != null) {
			return;
		}

		escListener = document.onKeyUp.listen((KeyboardEvent e) {
			//27 == esc key
			if (e.keyCode == 27) {
				close();
			}
		});
	}

	_destroyEscListener() {
		if (escListener != null) {
			escListener.cancel();
			escListener = null;
		}
	}

	prepare() {
		// GET 'window' ////////////////////////////////////
		displayElement = querySelector('#$id');

		// CLOSE BUTTON ////////////////////////////////////
		if (displayElement.querySelector('.fa-times.close') != null) {
			displayElement
				.querySelector('.fa-times.close')
				.onClick
				.listen((_) => this.close());
		}

		//catch right-clicks on a window and do nothing with them except
		//stop them from propagating to the document body
		displayElement.onContextMenu.listen((MouseEvent e) {
			e.stopPropagation();
			e.preventDefault();
		});

		// PREVENT PLAYER MOVEMENT WHILE WINDOW IS FOCUSED /
		displayElement
			.querySelectorAll('input, textarea, div[contenteditable="true"]')
			.onFocus
			.listen((_) {
			inputManager.ignoreKeys = true;
			inputManager.ignoreChatFocus = true;
		});
		displayElement
			.querySelectorAll('input, textarea, div[contenteditable="true"]')
			.onBlur
			.listen((_) {
			inputManager.ignoreKeys = false;
			inputManager.ignoreChatFocus = false;
		});

		//make div focusable. see: http://stackoverflow.com/questions/11280379/is-it-possible-to-write-onfocus-lostfocus-handler-for-a-div-using-js-or-jquery
		displayElement.tabIndex = -1;

		displayElement.onFocus.listen((_) => _createEscListener());
		displayElement.onBlur.listen((_) => _destroyEscListener());

		// TABS ////////////////////////////////////////////
		displayElement
			.querySelectorAll('.tab')
			.onClick
			.listen((MouseEvent m) {
			Element tab = m.target as Element;
			openTab(tab.text);
			// show intended tab
			tab.classes.add('active');
		});

		// DRAGGING ////////////////////////////////////////
		// init vars
		Element header = displayElement.querySelector('header');
		if (header != null) {
			bool dragging = false;
			num leftDiff, topDiff;

			// mouse down listeners
			displayElement.onMouseDown.listen((_) => this.focus());
			header.onMouseDown.listen((MouseEvent e) {
				dragging = true;
				Rectangle bounding = displayElement.getBoundingClientRect();
				leftDiff = e.page.x - bounding.left;
				topDiff = e.page.y - bounding.top;
			});

			// mouse is moving
			document.onMouseMove.listen((MouseEvent m) {
				if (dragging == true) {
					num left = m.page.x - leftDiff;
					num top = m.page.y - topDiff;
					displayElement.style
						..top = '${top}px'
						..left = '${left}px'
						..transform = 'initial';
				}
			});

			// mouseUp listener
			document.onMouseUp.listen((_) => dragging = false);

			modals[id] = this;
		}
	}

	openTab(String tabID) {
		Element tabView = displayElement.querySelector('article #${tabID.toLowerCase()}');
		// hide all tabs
		for (Element t in displayElement.querySelectorAll('article .tab-content'))
			t.hidden = true;
		for (Element t in displayElement.querySelectorAll('article .tab'))
			t.classes.remove('active');
		tabView.hidden = false;
	}
}
