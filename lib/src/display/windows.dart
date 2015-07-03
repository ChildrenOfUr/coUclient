part of couclient;

class WindowManager {
	WindowManager() {
		// Declaring all the possible popup windows
		SettingsWindow settings = new SettingsWindow();
    mapWindow = new MapWindow();
		BugWindow bugs = new BugWindow();
		BagWindow bag = new BagWindow();
		//VendorWindow vendor = new VendorWindow();
		MotdWindow motdWindow = new MotdWindow();
		//GoWindow goWindow = new GoWindow();
		CalendarWindow calendarWindow = new CalendarWindow();
		RockWindow rockWindow = new RockWindow();
		ItemWindow itemWindow = new ItemWindow();

		new Service(['vendorWindow'], (event) {
			vendor(event.content);
		});
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

/// A Dart interface to an html Modal
abstract class Modal {
	Element window;
	String id;

	open() {
		window.hidden = false;
		this.focus();
	}

	close() {
		window.hidden = true;
	}

	focus() {
		for(Element others in querySelectorAll('.window')) {
			others.style.zIndex = '2';
		}
		this.window.style.zIndex = '3';
		window.focus();
	}

	prepare() {
		// GET 'window' ////////////////////////////////////
		window = querySelector('#$id');

		// CLOSE BUTTON ////////////////////////////////////
		window.querySelector('.fa-times.close').onClick.listen((_) => this.close());
		StreamSubscription escListener;
		escListener = document.onKeyUp.listen((KeyboardEvent e) {
			if(window.hidden == false && e.keyCode == 27) {
				//escape key
				this.close();
				// COMMENTED TO ALLOW PRESSING ESC TO CLOSE ANY WINDOW // escListener.cancel();
			}
		});

		// PREVENT PLAYER MOVEMENT WHILE WINDOW IS FOCUSED /
		window.querySelectorAll('input, textarea').onFocus.listen((_) {
			inputManager.ignoreKeys = true;
		});
		window.querySelectorAll('input, textarea').onBlur.listen((_) {
			inputManager.ignoreKeys = false;
		});

		// TABS ////////////////////////////////////////////
		window.querySelectorAll('.tab').onClick.listen((MouseEvent m) {
			Element tab = m.target as Element;
			openTab(tab.text);
			// show intended tab
			tab.classes.add('active');
		});

		// DRAGGING ////////////////////////////////////////
		// init vars
		if(window.querySelector('header') != null) {
			int new_x = 0, new_y = 0;
			bool dragging = false;

			// mouse down listeners
			window.onMouseDown.listen((_) => this.focus());
			window.querySelector('header').onMouseDown.listen((_) => dragging = true);

			// mouse is moving
			document.onMouseMove.listen((MouseEvent m) {
				if(dragging == true) {
					new_x += m.movement.x;
					new_y += m.movement.y;
					window.style
						..top = 'calc(50% + ${new_y}px)'
						..left = 'calc(50% + ${new_x}px)';
				}
			});

			// mouseUp listener
			document.onMouseUp.listen((_) => dragging = false);
		}
	}

	openTab(String tabID) {
		Element tabView = window.querySelector('article #${tabID.toLowerCase()}');
		// hide all tabs
		for(Element t in window.querySelectorAll('article .tab-content'))
			t.hidden = true;
		for(Element t in window.querySelectorAll('article .tab'))
			t.classes.remove('active');
		tabView.hidden = false;
	}
}
