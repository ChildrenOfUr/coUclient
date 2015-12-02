part of couclient;

class MenuKeys {
  // Maps key to valid keycodes
  // Use int for single binding, and List<int> for multiple (eg. numpad and number row)
  static final Map<String, dynamic> KEY_CODES = {
    "A": 65,
    "B": 66,
    "C": 67,
    "D": 68,
    "E": 69,
    "F": 70,
    "G": 71,
    "H": 72,
    "I": 73,
    "J": 74,
    "K": 75,
    "L": 76,
    "M": 77,
    "N": 78,
    "O": 79,
    "P": 80,
    "Q": 81,
    "R": 82,
    "S": 83,
    "T": 84,
    "U": 85,
    "V": 86,
    "W": 87,
    "X": 88,
    "Y": 89,
    "Z": 90,
    "1": [
      49,
      97
    ],
    "2": [
      50,
      98
    ],
    "3": [
      51,
      99
    ],
    "4": [
      52,
      100
    ],
    "5": [
      53,
      101
    ],
    "6": [
      54,
      102
    ],
    "7": [
      55,
      103
    ],
    "8": [
      56,
      104
    ],
    "9": [
      57,
      105
    ],
    "0": [
      48,
      97
    ]
  };

  // Returns if the keycode provided will trigger the given key
  static bool keyCodeMatches(int keyCode, dynamic key) {
    key = key.toString().toUpperCase();

    if (KEY_CODES[key] is int) {
      // Keycode matches? (1 key :: 1 keycode)
      return KEY_CODES[key] == keyCode;
    } else if (KEY_CODES[key] is List<int>) {
      // Keycode matches? (1 key :: multiple keycodes)
      return (KEY_CODES[key] as List<int>).where((int code) => code == keyCode).toList().length > 0;
    } else {
      return false;
    }
  }

  // Resets the keyboard event listener list
  static void clearListeners() {
    // Cancel all listeners to prevent future duplication
    _listeners.forEach((StreamSubscription listener) {
      listener.cancel();
    });

    // Remove all items to allow for garbage collection
    _listeners.clear();
  }

  // List of keyboard listeners (one for each menu item)
  static List<StreamSubscription> _listeners = [];

  // Start listening for a menu item
  static void addListener(int index, Function callback) {
    _listeners.add(document.onKeyDown.listen((KeyboardEvent e) {
      // Probably not absolutely needed, but good practice
      e
        ..stopPropagation()
        ..preventDefault();

      if (keyCodeMatches(e.keyCode, index)) {
        // Stop listening for the keys after the menu is gone
        clearListeners();
        // Run the callback
        Function.apply(callback, []);
      }
    }));
  }
}
