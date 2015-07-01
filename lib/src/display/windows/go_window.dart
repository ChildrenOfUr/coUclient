part of couclient;

class GoWindow extends Modal {
  String id = 'goWindow';

  ElementList streets = querySelectorAll("#locations a");
  Element container = querySelector("#locations");
  InputElement search = querySelector("#goWindow input[type='text']");

  GoWindow() {
    prepare();

    container.onClick.listen((e) {
      go(e.target.attributes['tsid']);
    });

    search.onInput.listen((e) {
      filter(search.value.toLowerCase());
    });
    
    view.tpButton.onClick.listen((_) => this.open());
    querySelector("#rwc-gowindow").onClick.listen((_) => this.open());
  }

  go(tsid) {
    tsid = tsid.trim();
    view.mapLoadingScreen.className = "MapLoadingScreenIn";
    view.mapLoadingScreen.style.opacity = "1.0";
    minimap.containerE.hidden = true;
    //changes first letter to match revdancatt's code - only if it starts with an L
    if (tsid.startsWith("L")) tsid = tsid.replaceFirst("L", "G");
    streetService.requestStreet(tsid);
    if (localStorage['closeTpWindowOnClick'] == "true") {
      this.close();
    }
  }

  ElementList hubheadings = querySelectorAll("#locations h2");

  filter(input) {
    if (input != "") {
      hubheadings.style.display = "none";
    } else {
      hubheadings.style.display = "block";
    }

    streets.forEach((link) {
      if (link.text.toLowerCase().contains(input) == false) {
        link.style.display = "none";
      } else {
        link.style.display = "block";
      }
    });
  }
}