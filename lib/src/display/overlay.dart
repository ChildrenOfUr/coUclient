part of couclient;

class Overlay {
  Overlay(String id) {
    overlay = querySelector("#" + id);
    overlay.querySelector(".closeButton").onClick.listen((_) => close());
  }

  Element overlay;

  open() {
    overlay.hidden = false;
  }

  close() {
    overlay.hidden = true;
  }
}

// SET UP OVERLAYS //

Overlay newDay;
Overlay imgMenu;

void setUpOverlays() {
  newDay = new NewDayOverlay("newday");
  imgMenu = new Overlay("pauseMenu");
}

class NewDayOverlay extends Overlay {
  NewDayOverlay(String id):super(id) {
    new Service([#newDay], (Message event) {
      open();
    });
    new Service([#newDayFake], (Message event) {
      open();
    });
  }

  open() {
    //TODO: get real value
    int energy = 100;
    overlay.querySelector("#newday-date").text = clock.dayofweek + ", the " + clock.day + " of " + clock.month;
    overlay.querySelector("#newday-refill-1").text = energy.toString();
    overlay.querySelector("#newday-refill-2").text = energy.toString();
    overlay.hidden = false;
    new Timer(new Duration (milliseconds: 100), () {
      overlay.querySelector("#newday-sun").classes.add("up");
      overlay.querySelector("#newday-refill-disc").classes.add("full");
    });
  }

  close() {
    overlay.hidden = true;
    overlay.querySelector("#newday-sun").classes.remove("up");
    overlay.querySelector("#newday-refill-disc").classes.remove("full");
  }
}