part of couclient;

class CalendarWindow extends Modal {
  String id = 'calendarWindow';

  CalendarWindow() {
    prepare();
    Element calendarE = querySelector("#calendar-view");

    // get calendar data //

    calendarE.innerHtml = '''
      <div id="cal-nothing">
        <p>Nothing to see here...</p>
        <img src="files/system/windows/piglet.png">
        <p class="italic">...yet.</p>
      </div>
    ''';

    // launch //

    querySelector("#time").onClick.listen((_) {
        if (this.modalWindow.hidden) {
	        this.open();
        } else {
	        this.close();
        }
    });

    document.onKeyDown.listen((KeyboardEvent k) {
	    if(inputManager == null)
		    return;

	    if((k.keyCode == inputManager.keys["CalendarBindingPrimary"]
	    || k.keyCode == inputManager.keys["CalendarBindingAlt"])
	    && !inputManager.ignoreKeys) {
		    if(this.modalWindow.hidden) {
			    this.open();
		    } else {
			    this.close();
		    }
	    }
    });
  }
}