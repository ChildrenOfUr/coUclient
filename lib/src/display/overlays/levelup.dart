part of couclient;

class LevelUpOverlay extends Overlay {
	Element dropper;
	LevelUpOverlay(String id):super(id) {
		dropper = querySelector("#lu-dropper");
	}

	open([int newLevel]) {
		void display(int level) {
			dropper.text = level.toString();
			displayElement.hidden = false;
			audio.playSound('levelUp');
			inputManager.ignoreKeys = true;
			displayElement.querySelector("#lu-button").onClick.first.then((_) => close());
			transmit("worldFocus", false);
		}

		if (newLevel == null) {
			metabolics.level.then((int level) {
				display(level);
			});
		} else {
			display(newLevel);
		}
	}

	close() {
		metabolics.level.then((int lvl) {
			if (lvl % 10 == 0) {
				new Notification(
					"Level Up!", icon: Toast.notifIconUrl,
					body: "You've unlocked new username color options! Click here to visit your profile page, then log in to check them out."
				).onClick.listen((_) {
					window.open("http://childrenofur.com/profile?username=${game.username}", "_blank");
				});
			}
		});

		super.close();
	}
}

LevelUpOverlay levelUp;