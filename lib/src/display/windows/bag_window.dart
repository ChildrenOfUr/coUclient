part of couclient;

class BagWindow extends Modal {
  String id = 'bagWindow';

  BagWindow() {
    prepare();
    // INVENTORY WINDOW LISTENERS
    view.inventorySearch.onClick.listen((_) {
      this.open();
    });
  }
}
