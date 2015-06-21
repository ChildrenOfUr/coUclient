part of couclient;

class RockWindow extends Modal {
  String id = 'rockWindow';

  RockWindow() {
    prepare();

    // Toggle window by clicking rock
    querySelector("#petrock").onClick.listen((_) {
      if (this.window.hidden == true) {
        this.open();
      } else {
        this.close();
      }
    });

    switchContent(String id) {
      querySelectorAll("#rwc-holder .rockWindowContent").style.display = "none";
      querySelector("#" + id).style.display = "block";
    }

    // Back to main menu
    querySelectorAll("a.go-rwc").onClick.listen((_) {
      switchContent("rwc");
    });

    // Open MOTD
    querySelector("#go-motd").onClick.listen((_) {
      switchContent("rwc-motd");
    });

    // Getting Started
    querySelector("#go-start").onClick.listen((_) {
      switchContent(("rwc-start"));
    });

    querySelectorAll("#rwc-start .rwc-button").onClick.listen((e) {
      String id = e.target.getAttribute("goto");
      if (id == "6") {
        switchContent("rwc");
        this.close();
      } else {
        querySelectorAll("#rwc-start > div").style.display = "none";
        querySelector("#rwc-start-" + id).style.display = "block";
        querySelector("#rwc-start .go-rwc").scrollIntoView();
      }
    });
  }
}