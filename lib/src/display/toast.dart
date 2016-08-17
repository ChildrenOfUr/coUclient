part of couclient;

enum NotifyRule {
	YES, // Send notification
	NO, // Do not send notification
	UNFOCUSED // Send only if the window is not focused
}

class Toast {
	/// In-game toasts panel
	static final Element _toastContainer = querySelector('#toastHolder');

	/// Icon URL for system notifications
	static const notifIconUrl = 'http://childrenofur.com/assets/icon_72.png';

	/// Predefined click functions (pass as onClick)
	static final Map<String, Function> _clickActions = {
		'imgmenu': ({MouseEvent event, String argument}) => imgMenu.open(),
		'iteminfo': ({MouseEvent event, String argument}) => new ItemWindow(argument),
		'addFriend': ({MouseEvent event, String argument}) => windowManager.addFriendWindow.openWith(argument)
	};

	String message;
	bool skipChat;
	NotifyRule notify;
	Function clickHandler;
	String clickArgument;
	Element toastElement;
	Element chatElement;

	@override
	String toString() => message;

	/**
	 * Creates and displays a Toast.
	 * [message]: What to say in the toast, chat message, and notification.
	 * [skipChat]: `true` to disable display in local chat, `false` (default) to act normally and display.
	 * [notify]: `YES` to send a browser notification, `NO` (default) to keep inside the client window, 'UNFOCUSED` to send only if the window is not focused
	 * [onClick]: A clickActions identifier ('name|optional_arg') or function, which will be passed the click MouseEvent.
	 */
	Toast(this.message, {this.skipChat, this.notify, dynamic onClick}) {
		if (skipChat == null) skipChat = false;
		if (notify == null) notify = NotifyRule.NO;

		// Display in toasts panel
		_sendToPanel();

		// Attach click listener in panel (if onClick is passed)
		_setupClickHandler(onClick);

		// Display in chat panel (or queue) if not disabled
		// Adds its own click listener based on that of the toast
		_sendToChat();

		// Display in system notification tray (if enabled)
		_sendNotification();
	}

	/// Handle click events on the toast in the panel
	void _setupClickHandler(dynamic onClick) {
		if (onClick != null) {
			if (onClick is Function) {
				clickHandler = onClick;
			} else if (onClick is String) {
				List<String> parts = onClick.split('|');
				clickHandler = _clickActions[parts.first];
				clickArgument = (parts.length > 1 ? parts.sublist(1).join('|') : '');
			} else {
				throw new ArgumentError(
					'onClick must be a string identifier or function, but it is of type ${onClick.runtimeType}'
				);
			}

			toastElement
				..style.cursor = 'pointer'
				..onClick.listen((MouseEvent event) => click(event));
		}
	}

	/// Display in toasts panel
	void _sendToPanel() {
		// Create node
		toastElement = new DivElement()
			..classes.add('toast')
			..style.opacity = '0.5'
			..text = message;

		// How long to display it (1s + 100ms per character, max 30s)
		int textTime = (1000 + (message.length * 100)).clamp(1000, 30000);

		// Animate closing it
		Duration timeOpacity = new Duration(milliseconds: textTime);
		Duration timeHide = new Duration(milliseconds: timeOpacity.inMilliseconds + 500);
		new Timer(timeOpacity, () => toastElement.style.opacity = '0');
		new Timer(timeHide, () => toastElement.remove());

		_toastContainer.append(toastElement);
	}

	/// Run click event
	void click(MouseEvent event) {
		try {
			clickHandler(event: event, argument: clickArgument);
		} catch(e) {
			logmessage('Could not trigger toast click event ${clickHandler}: $e');
		}
	}

	/// Display in chat, if not disabled
	void _sendToChat() {
		if (Chat.localChat != null && skipChat != null && !skipChat) {
			Chat.localChat.addAlert(this);
		} else if (!skipChat) {
			chatToastBuffer.add(this);
		}
	}

	/// Send system notification, if enabled
	void _sendNotification() {
		if (
			notify == NotifyRule.YES ||
			(notify == NotifyRule.UNFOCUSED && !inputManager.windowFocused)
		) {
			new Notification(
				'Game Alert',
				body: message,
				icon: notifIconUrl
			);
		}
	}
}