part of couclient;

class ActionBubble {
	int duration;

	SpanElement outline = new SpanElement();
	SpanElement fill = new SpanElement();

	ActionBubble(List action, this.duration) {
		// Position the action bubble
		num posX = CurrentPlayer.posX;
		num posY = CurrentPlayer.posY;
		int width = CurrentPlayer.width;
		int height = CurrentPlayer.height;

		String text = (action[0] as String).split('|')[1];
		if (text.contains("Focus ")) {
			text = "Focus";
		}

		int x = posX.toInt() - width ~/ 2;
		int y = posY.toInt() - 60;

		outline
			..text = text
			..className = "border" + " " + (action[0] as String).split("|")[1].toLowerCase().replaceAll(' ', '_')
			..style.top = '$y' 'px'
			..style.left = '$x' 'px'
			..style.zIndex = '99';
		fill
			..text = text
			..className = "fill" + " " + (action[0] as String).split("|")[1].toLowerCase().replaceAll(' ', '_')
			..style.transition = "width ${duration / 1000}s linear"
			..style.top = '$y' 'px'
			..style.left = '$x' 'px'
			..style.zIndex = '99';

		view.playerHolder
			..append(outline)
			..append(fill);

		//start the "fill animation"
		fill.style.width = outline.clientWidth.toString() + "px";
	}

	Future get wait {
		Completer completer = new Completer();
		StreamSubscription escListener;
		Timer miningTimer = new Timer(new Duration(milliseconds:duration + 300), () {
			outline.remove();
			fill.remove();
			escListener.cancel();
			completer.complete();
		});

		escListener = document.onKeyUp.listen((KeyboardEvent k) {
			if(k.keyCode == 27) {
				outline.remove();
				fill.remove();
				escListener.cancel();
				miningTimer.cancel();
				completer.complete();
			}
		});
		return completer.future;
	}
}