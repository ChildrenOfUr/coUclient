part of couclient;

class RockWindow extends Modal {
  String id = 'rockWindow';

  RockWindow() {
    prepare();

    // Toggle window by clicking rock
    querySelector("#petrock").onClick.listen((_) {
      if (this.displayElement.hidden == true) {
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

    initConvo(String convo) {
      querySelector("#go-" + convo).onClick.listen((_) {
        querySelectorAll("#rwc-" + convo + " > div").style.display = "none";
        querySelector("#rwc-" + convo + "-1").style.display = "block";
        querySelector("#rwc-" + convo + " .go-rwc").scrollIntoView();
        switchContent("rwc-" + convo);
      });

      querySelectorAll("#rwc-" + convo + " .rwc-button").onClick.listen((e) {
        String id = e.target.getAttribute("goto");
        if (id == querySelector("#rwc-" + convo).getAttribute("endphrase")) {
          switchContent("rwc");
          super.close();
          querySelectorAll("#rwc-" + convo + " > div").style.display = "none";
          querySelector("#rwc-" + convo + "-1").style.display = "block";
          querySelector("#rwc-" + convo + " .go-rwc").scrollIntoView();
        } else {
          querySelectorAll("#rwc-" + convo + " > div").style.display = "none";
          querySelector("#rwc-" + convo + "-" + id).style.display = "block";
          querySelector("#rwc-" + convo + " .go-rwc").scrollIntoView();
        }
      });
    }

    initConvo("start");
    initConvo("motd");
    initConvo("bugs");
  }
}