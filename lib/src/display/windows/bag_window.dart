part of couclient;

class BagWindow extends Modal {
  String id = 'bagWindow';

  BagWindow() {
    prepare();
    // INVENTORY WINDOW LISTENERS
    ui.inventorySearch.onClick.listen((_) {
      this.open();
    });

  }


}
