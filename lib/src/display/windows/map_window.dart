part of couclient;

class MapWindow extends Modal {
  String id = 'mapWindow';

  MapWindow() {

    prepare();
    // MAPWINDOW LISTENERS //
    ui.mapButton.onClick.listen((_) {
      this.open();
      worldMap = new WorldMap(currentStreet.hub_id);
    });
  }


}
