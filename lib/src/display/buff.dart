part of couclient;

class Buff {
	/// Buffs panel
	static final Element _buffContainer = querySelector("#buffHolder");

	/// List of running buffs
	static Map<String, Buff> _running = new Map();

	/// Whether the player has the specified buff
	static bool isRunning(String id) {
		return _running.containsKey(id);
	}

	/// Download existing buffs from server
	static void loadExisting() {
		HttpRequest.getString(
			"http://${Configs.utilServerAddress}/buffs/get/${game.email}"
		).then((String json) {
			print(json);
			JSON.decode(json).forEach((Map buff) => new Buff.fromMap(buff));
		});
	}

	/// Un-display a buff
	static bool removeBuff(String buffId) {
		if (!isRunning(buffId)) {
			return false;
		} else {
			_running[buffId].remove();
			return true;
		}
	}

	/// Display a buff
	Buff(this.id, this.name, this.description, this.length, this.remaining) {
		_running.addAll({id: this});
		_display();
		_animate();
	}

	/// Parse an encoded buff (and display it)
	Buff.fromMap(Map<String, dynamic> map) {
		new Buff(
			map["id"],
			map["name"],
			map["description"],
			new Duration(seconds: map["length"]),
			new Duration(seconds: map["player_remaining"])
		);
	}

	/// Whether it has already been removed
	bool exists = true;

	/// Add to panel
	void _display() {
		ImageElement icon = new ImageElement()
			..classes.add("buffIcon")
			..src = "files/system/buffs/$id.png";

		SpanElement title = new SpanElement()
			..classes.add("title")
			..text = name;

		SpanElement desc = new SpanElement()
			..classes.add("desc")
			..text = description;

		DivElement progress = new DivElement()
			..classes.add("buff-progress")
			..style.width = "calc(100% - 6px)"
			..id = "buff-" + id + "-progress";

		buffElement = new DivElement()
			..classes.add("toast")
			..classes.add("buff")
			..id = "buff-" + id
			..style.opacity = "0.5"
			..append(progress)
			..append(icon)
			..append(title)
			..append(desc);

		// Display in game
		_buffContainer.append(buffElement);

		// Animate closing
		new Timer(new Duration(milliseconds: length.inMilliseconds - 500), () {
			if (exists) {
				_elementHide();
				exists = false;
			}
		});
		new Timer(new Duration(milliseconds: length.inMilliseconds), () {
			if (exists) {
				_elementRemove();
				exists = false;
			}
		});
	}

	String _elementHide() => buffElement.style.opacity = "0";
	void _elementRemove() => buffElement.remove();

	/// Start the decreasing progress bar
	void _animate() {
		Stopwatch stopwatch = new Stopwatch()
			..start();
		timer = new Timer.periodic(new Duration(seconds: 1), (_) {
			int elapsed = stopwatch.elapsed.inSeconds;
			if (elapsed < length.inSeconds) {
				num width = 100 - ((100 / length.inSeconds) * elapsed);
				buffElement.querySelector(".buff-progress")
					.style.width = "calc($width% - 6px)";
			} else {
				stopwatch.stop();
				remove();
			}
		});
	}

	/// Remove from panel and memory
	void remove() {
		_elementHide();
		_elementRemove();
		timer.cancel();
		_running.remove(id);
	}

	String id, name, description;
	Duration length, remaining;
	Element buffElement;
	Timer timer;
}
