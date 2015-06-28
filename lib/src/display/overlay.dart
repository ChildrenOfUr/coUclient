part of couclient;

class Overlay {
  Overlay(String id) {
    overlay = querySelector("#" + id);
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
    String maxenergy = metabolics.maxEnergy.toString();
    overlay.querySelector("#newday-date").text = clock.dayofweek + ", the " + clock.day + " of " + clock.month;
    overlay.querySelector("#newday-refill-1").text = maxenergy;
    overlay.querySelector("#newday-refill-2").text = maxenergy;
    overlay.hidden = false;
    new Timer(new Duration (milliseconds: 100), () {
      overlay.querySelector("#newday-sun").classes.add("up");
      overlay.querySelector("#newday-refill-disc").classes.add("full");
    });
    // TODO: new day screen sound
  }

  close() {
    overlay.hidden = true;
    overlay.querySelector("#newday-sun").classes.remove("up");
    overlay.querySelector("#newday-refill-disc").classes.remove("full");
  }
}