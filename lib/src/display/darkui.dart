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

	/// Sets mode based on true (dark) or false (light)
	static set darkMode(bool newMode) {
		if (newMode) {
			toDarkMode();
		} else {
			toLightMode();
		}
	}

	/// Returns true if in dark mode, false if not
	static bool get darkMode {
		return document.body.classes.contains(DARK_CLASS);
	}

	/// Sets mode based on "light" or "dark" strings
	static set modeName(String newMode) {
		newMode = newMode.trim().toLowerCase();
		darkMode = (newMode == "dark");
	}

	/// Returns the current mode as "light" or "dark"
	static String get modeName {
		return (darkMode ? "dark" : "light");
	}

	/// Returns all of the elements that should be styled
	static List<Element> get appliedElements {
		return new List()
			..add(document.body)
			..add(querySelector("ur-meters"))
			..add(querySelector("ur-mailbox"))
			..addAll(querySelectorAll("ur-button"));
	}

	/// Switches to dark mode
	static void toDarkMode() {
		appliedElements.forEach((Element element) {
			element
				..classes.add(DARK_CLASS)
				..attributes[DARK_CLASS] = "true";
		});
	}

	/// Switches to light mode
	static void toLightMode() {
		appliedElements.forEach((Element element) {
			element
				..classes.remove(DARK_CLASS)
				..attributes[DARK_CLASS] = "false";
		});
	}
}