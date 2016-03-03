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
	static final String DARK_CLASS = "darkui";

	static set darkMode(bool newMode) {
		if (newMode) {
			toDarkMode();
		} else {
			toLightMode();
		}
	}

	static bool get darkMode {
		return document.body.classes.contains(DARK_CLASS);
	}

	static set modeName(String newMode) {
		newMode = newMode.trim().toLowerCase();
		darkMode = (newMode == "dark");
	}

	static String get modeName {
		return (darkMode ? "dark" : "light");
	}

	static void toDarkMode() {
		document.body.classes.add(DARK_CLASS);
		querySelector("ur-meters").attributes[DARK_CLASS] = "true";
		querySelectorAll("ur-button").forEach((Element element) {
			element.attributes[DARK_CLASS] = "true";
		});
	}

	static void toLightMode() {
		document.body.classes.remove(DARK_CLASS);
		querySelector("ur-meters").attributes[DARK_CLASS] = "false";
		querySelectorAll("ur-button").forEach((Element element) {
			element.attributes[DARK_CLASS] = "false";
		});
	}
}