part of couclient;

class WindowManager {
	WindowManager() {
		// Declaring all the possible popup windows
		SettingsWindow settings = new SettingsWindow();
		mapWindow = new MapWindow();
		BugWindow bugs = new BugWindow();
		BagWindow bag = new BagWindow();
		VendorWindow vendor = new VendorWindow();
		MotdWindow motdWindow = new MotdWindow();
		//GoWindow goWindow = new GoWindow();
		CalendarWindow calendarWindow = new CalendarWindow();
		RockWindow rockWindow = new RockWindow();
//		ItemWindow itemWindow = new ItemWindow();
	}
}

class AuctionWindow extends Modal {
	String id = 'auctionWindow';

	AuctionWindow() {
		prepare();
	}
}

class MailboxWindow extends Modal {
	String id = 'mailboxWindow';

	MailboxWindow() {
		prepare();
	}

	open() {
		(querySelector("ur-mailbox") as Mailbox).refresh();
		inputManager.ignoreKeys = true;
		super.open();
	}

	close() {
		inputManager.ignoreKeys = false;
		super.close();
	}
}

Map<String,Modal> modals = {};

/// A Dart interface to an html Modal
abstract class Modal {
	Element modalWindow;
	String id;
	StreamSubscription escListener;

	open() {
		modalWindow.hidden = false;
		this.focus();
	}

	close() {
		_destroyEscListener();
		modalWindow.hidden = true;

		//see if there's another window that we want to focus
		for(Element modal in querySelectorAll('.window')) {
			if(!modal.hidden) {
				modals[modal.id].focus();
			}
		}
	}

	focus() {
		for(Element others in querySelectorAll('.window')) {
			others.style.zIndex = '2';
		}
		this.modalWindow.style.zIndex = '3';
		modalWindow.focus();
	}

	_createEscListener() {
		if(escListener != null) {
			return;
		}

		escListener = document.onKeyUp.listen((KeyboardEvent e) {
			//27 == esc key
			if(e.keyCode == 27) {
				close();
			}
		});
	}

	_destroyEscListener() {
		if(escListener != null) {
			escListener.cancel();
			escListener = null;
		}
	}

	prepare() {
		// GET 'window' ////////////////////////////////////
		modalWindow = querySelector('#$id');

		// CLOSE BUTTON ////////////////////////////////////
		modalWindow.querySelector('.fa-times.close').onClick.listen((_) => this.close());

		// PREVENT PLAYER MOVEMENT WHILE WINDOW IS FOCUSED /
		modalWindow.querySelectorAll('input, textarea').onFocus.listen((_) {
			inputManager.ignoreKeys = true;
			inputManager.ignoreChatFocus = true;
		});
		modalWindow.querySelectorAll('input, textarea').onBlur.listen((_) {
			inputManager.ignoreKeys = false;
			inputManager.ignoreChatFocus = false;
		});

		//make div focusable. see: http://stackoverflow.com/questions/11280379/is-it-possible-to-write-onfocus-lostfocus-handler-for-a-div-using-js-or-jquery
		modalWindow.tabIndex = -1;

		modalWindow.onFocus.listen((_) => _createEscListener());
		modalWindow.onBlur.listen((_) => _destroyEscListener());

		// TABS ////////////////////////////////////////////
		modalWindow.querySelectorAll('.tab').onClick.listen((MouseEvent m) {
			Element tab = m.target as Element;
			openTab(tab.text);
			// show intended tab
			tab.classes.add('active');
		});

		// DRAGGING ////////////////////////////////////////
		// init vars
		if(modalWindow.querySelector('header') != null) {
			int new_x = 0, new_y = 0;
			bool dragging = false;

			// mouse down listeners
			modalWindow.onMouseDown.listen((_) => this.focus());
			modalWindow.querySelector('header').onMouseDown.listen((_) => dragging = true);

			// mouse is moving
			document.onMouseMove.listen((MouseEvent m) {
				if(dragging == true) {
					new_x += m.movement.x;
					new_y += m.movement.y;
					modalWindow.style
						..top = 'calc(50% + ${new_y}px)'
						..left = 'calc(50% + ${new_x}px)';
				}
			});

			// mouseUp listener
			document.onMouseUp.listen((_) => dragging = false);

			modals[id] = this;
		}
	}

	openTab(String tabID) {
		Element tabView = modalWindow.querySelector('article #${tabID.toLowerCase()}');
		// hide all tabs
		for(Element t in modalWindow.querySelectorAll('article .tab-content'))
			t.hidden = true;
		for(Element t in modalWindow.querySelectorAll('article .tab'))
			t.classes.remove('active');
		tabView.hidden = false;
	}
}
