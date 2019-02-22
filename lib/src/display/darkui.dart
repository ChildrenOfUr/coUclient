part of couclient;

/*
	| Color        | Light   | Dark    |
	|--------------|---------|---------|
	| Background   | #eeeeee | #282828 |
	| Main Text    | #000000 | #ffffff |
	| Special Text | #4b2e4c | #eeeeee |
	| Alternate    | #444444 | #181818 |
*/

abstract class DarkUI {
	/// The class name to apply or attribute to set when in dark mode
	static final String DARK_CLASS = "darkui";

	/// Returns all of the elements that should be styled
	static List<Element> get appliedElements {
		return new List()
			..add(document.body)
			..add(querySelector("#meters #topLeftMask"))
			..add(querySelector("#meters #playerName"))
			..add(querySelector("#meters #imaginationText"))
//			..add(querySelector("ur-mailbox /deep/ core-pages")) // TODO
			..addAll(querySelectorAll(".panel"))
			..addAll(querySelectorAll("button"));
	}

	/// Whether to toggle automatically with day cycles
	static bool autoMode = false;

	/// Toggle if in auto mode
	static void update() {
		if (autoMode) {
			darkMode = clock.isNight;
		}
	}

	/// Returns true if in dark mode, false if not
	static bool get darkMode {
		return document.body.classes.contains(DARK_CLASS);
	}

	/// Sets mode based on true (dark) or false (light)
	static set darkMode(bool newMode) {
		if (newMode) {
			_toDarkMode();
		} else {
			_toLightMode();
		}

		transmit(DARK_CLASS, newMode);
	}

	/// Switches to dark mode
	static void _toDarkMode() {
		appliedElements.forEach((Element element) {
			element
				..classes.add(DARK_CLASS)
				..attributes[DARK_CLASS] = "true";
		});
	}

	/// Switches to light mode
	static void _toLightMode() {
		appliedElements.forEach((Element element) {
			element
				..classes.remove(DARK_CLASS)
				..attributes[DARK_CLASS] = "false";
		});
	}
}
