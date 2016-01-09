part of couclient;

toast(String message, {bool skipChat: false}) {
	Element toastContainer = querySelector('#toastHolder');

	DivElement toast = new DivElement()
		..classes.add('toast')
		..style.opacity = '0.5'
		..text = message;

	int textTime = 1000 + (toast.text.length * 100);
	if (textTime > 30000) {
		textTime = 30000;
	}

	Duration timeOpacity = new Duration(milliseconds: textTime);
	Duration timeHide = new Duration(milliseconds: timeOpacity.inMilliseconds + 500);

	new Timer(timeOpacity, () {
		toast.style.opacity = '0';
	});
	new Timer(timeHide, toast.remove);

	toastContainer.append(toast);

	if (Chat.localChat != null && !skipChat) {
		Chat.localChat.addAlert(message, toast: true);
	} else if (!skipChat) {
		chatToastBuffer.add(message);
	}
}

buff(String type) {
	Element buffContainer = querySelector('#buffHolder');
	String message, messageInfo;
	int length; // in seconds

	switch (type) {
		case 'pie':
			message = "Full of Pie";
			messageInfo = "Jump height decreased";
			length = 120;
			// 2 minutes
			break;
		case 'quoin':
			message = "Double Quoins";
			messageInfo = "Quoin values doubled";
			length = 600;
			// 10 minutes
			break;
		case 'spinach':
			message = "Spinach";
			messageInfo = "Jump height increased";
			length = 30;
			// 30 seconds
			break;
		default:
			return;
	}

	DivElement buff = new DivElement()
		..classes.add('toast')
		..classes.add('buff')
		..id = "buff-" + type
		..style.opacity = '0.5';
	ImageElement icon = new ImageElement()
		..classes.add('buffIcon')
		..src = 'files/system/buffs/buff_' + type + '.png';
	SpanElement title = new SpanElement()
		..classes.add('title')
		..text = message;
	SpanElement desc = new SpanElement()
		..classes.add('desc')
		..text = messageInfo;
	DivElement progress = new DivElement()
		..classes.add('buff-progress')
		..style.width = "100%"
		..id = "buff-" + type + "-progress";
	buff.append(progress);
	buff.append(icon);
	buff.append(title);
	buff.append(desc);

	Duration timeOpacity = new Duration(seconds: length);
	Duration timeHide = new Duration(milliseconds: timeOpacity.inMilliseconds + 500);
	new Timer(timeOpacity, () {
		buff.style.opacity = '0';
	});
	new Timer(timeHide, buff.remove);
	Stopwatch uStopwatch = new Stopwatch();
	Timer uTimer;
	uTimer = new Timer.periodic(new Duration(seconds: 1), (Timer t) {
		int seconds = uStopwatch.elapsed.inSeconds;
		if (seconds < length) {
			num width = 100 - ((100 / length) * seconds).round();
			progress.style.width = width.toString() + "%";
		} else {
			uStopwatch.stop();
			uTimer.cancel();
		}
	});

	buffContainer.append(buff);
	uStopwatch.start();

	// TODO: store buffs to server
	// TODO: get buffs from server and skip to remaining time
}