part of couclient;

class ActionBubble {
	static bool occuring = false;
	int duration;

	SpanElement outline = new SpanElement();
	SpanElement fill = new SpanElement();

	SkillIndicator assocSkillIndicator;

	factory ActionBubble(String actionName, int duration, [String assocSkill]) {
		return new ActionBubble._(actionName, duration, assocSkill);
	}

	factory ActionBubble.withAction(Action action) {
		return new ActionBubble._(action.actionName, action.timeRequired, action.associatedSkill);
	}

	ActionBubble._(String actionName, this.duration, [String assocSkill]) {
		// Only the first word, ignore anything after the first space
		String text = actionName.split(' ')[0].toLowerCase();
		String cssName = actionName.toLowerCase().replaceAll(' ', '_');

		outline
			..text = text
			..className = 'border $cssName'
			..style.zIndex = '99';
		fill
			..text = text
			..className = 'fill $cssName'
			..style.transition = 'width ${duration / 1000}s linear'
			..style.zIndex = '99'
			..style.whiteSpace = 'nowrap';

		CurrentPlayer.superParentElement
			..append(outline)
			..append(fill);

		// Position the action bubble
		Rectangle outlineRect = outline.client;
		int outlineWidth = outlineRect.width;
		int outlineHeight = outlineRect.height;
		//print('width: $outlineWidth');
		num playerX = num.parse(CurrentPlayer.playerParentElement.attributes['translatex']);
		num playerY = num.parse(CurrentPlayer.playerParentElement.attributes['translatey']);
		int x = playerX~/1 -outlineWidth~/2 + CurrentPlayer.width ~/ 2;
		int y = playerY~/1 -outlineHeight - 25;

		fill
			..style.top = '${y}px'
			..style.left = '${x}px';
		outline
			..style.top = '${y}px'
			..style.left = '${x}px';

		//start the "fill animation"
		fill.style.width = '${outlineWidth}px';

		if (assocSkill != null) {
			assocSkillIndicator = new SkillIndicator(assocSkill);
		}

		occuring = true;
		new Timer(new Duration(milliseconds:duration), () => occuring = false);
	}

	Future<bool> get wait {
		Completer<bool> completer = new Completer<bool>();
		StreamSubscription escListener;
		Timer miningTimer = new Timer(new Duration(milliseconds:duration + 300), () {
			outline.remove();
			fill.remove();
			escListener.cancel();
			completer.complete(true);
			assocSkillIndicator?.close();
			occuring = false;
		});

		escListener = document.onKeyUp.listen((KeyboardEvent k) {
			if (k.keyCode == 27) {
				outline.remove();
				fill.remove();
				escListener.cancel();
				miningTimer.cancel();
				completer.complete(false);
				assocSkillIndicator?.close();
				occuring = false;
			}
		});
		return completer.future;
	}
}
