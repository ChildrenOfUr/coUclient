part of couclient;

String fromKeyCode(int keyCode)
{
	String keyPressed = "";
	if (keyCode == 8) keyPressed = "backspace"; //  backspace
	if (keyCode == 9) keyPressed = "tab"; //  tab
	if (keyCode == 13) keyPressed = "enter"; //  enter
	if (keyCode == 16) keyPressed = "shift"; //  shift
	if (keyCode == 17) keyPressed = "ctrl"; //  ctrl
	if (keyCode == 18) keyPressed = "alt"; //  alt
	if (keyCode == 19) keyPressed = "pause/break"; //  pause/break
	if (keyCode == 20) keyPressed = "caps lock"; //  caps lock
	if (keyCode == 27) keyPressed = "escape"; //  escape
	if (keyCode == 32) keyPressed = "space"; // space;
	if (keyCode == 33) keyPressed = "page up"; // page up, to avoid displaying alternate character and confusing people
	if (keyCode == 34) keyPressed = "page down"; // page down
	if (keyCode == 35) keyPressed = "end"; // end
	if (keyCode == 36) keyPressed = "home"; // home
	if (keyCode == 37) keyPressed = "left arrow"; // left arrow
	if (keyCode == 38) keyPressed = "up arrow"; // up arrow
	if (keyCode == 39) keyPressed = "right arrow"; // right arrow
	if (keyCode == 40) keyPressed = "down arrow"; // down arrow
	if (keyCode == 45) keyPressed = "insert"; // insert
	if (keyCode == 46) keyPressed = "delete"; // delete
	if (keyCode == 91) keyPressed = "left window"; // left window
	if (keyCode == 92) keyPressed = "right window"; // right window
	if (keyCode == 93) keyPressed = "select key"; // select key
	if (keyCode == 96) keyPressed = "numpad 0"; // numpad 0
	if (keyCode == 97) keyPressed = "numpad 1"; // numpad 1
	if (keyCode == 98) keyPressed = "numpad 2"; // numpad 2
	if (keyCode == 99) keyPressed = "numpad 3"; // numpad 3
	if (keyCode == 100) keyPressed = "numpad 4"; // numpad 4
	if (keyCode == 101) keyPressed = "numpad 5"; // numpad 5
	if (keyCode == 102) keyPressed = "numpad 6"; // numpad 6
	if (keyCode == 103) keyPressed = "numpad 7"; // numpad 7
	if (keyCode == 104) keyPressed = "numpad 8"; // numpad 8
	if (keyCode == 105) keyPressed = "numpad 9"; // numpad 9
	if (keyCode == 106) keyPressed = "multiply"; // multiply
	if (keyCode == 107) keyPressed = "add"; // add
	if (keyCode == 109) keyPressed = "subtract"; // subtract
	if (keyCode == 110) keyPressed = "decimal point"; // decimal point
	if (keyCode == 111) keyPressed = "divide"; // divide
	if (keyCode == 112) keyPressed = "F1"; // F1
	if (keyCode == 113) keyPressed = "F2"; // F2
	if (keyCode == 114) keyPressed = "F3"; // F3
	if (keyCode == 115) keyPressed = "F4"; // F4
	if (keyCode == 116) keyPressed = "F5"; // F5
	if (keyCode == 117) keyPressed = "F6"; // F6
	if (keyCode == 118) keyPressed = "F7"; // F7
	if (keyCode == 119) keyPressed = "F8"; // F8
	if (keyCode == 120) keyPressed = "F9"; // F9
	if (keyCode == 121) keyPressed = "F10"; // F10
	if (keyCode == 122) keyPressed = "F11"; // F11
	if (keyCode == 123) keyPressed = "F12"; // F12
	if (keyCode == 144) keyPressed = "num lock"; // num lock
	if (keyCode == 145) keyPressed = "scroll lock"; // scroll lock
	if (keyCode == 225) keyPressed = "alt"; //right alt
     
	return keyPressed;
}