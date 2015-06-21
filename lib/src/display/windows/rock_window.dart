part of couclient;

class RockWindow extends Modal {
  String id = 'rockWindow';

  RockWindow() {
    prepare();

    querySelector("#petrock").onClick.listen((_) {
      if (this.window.hidden == true) {
        this.open();
      } else {
        this.close();
      }
    });
  }
}