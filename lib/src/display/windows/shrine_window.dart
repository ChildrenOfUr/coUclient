part of couclient;

class ShrineWindow extends Modal {
  String id = 'shrineWindow';

  ShrineWindow() {
    prepare();

    String giantName = "Alph"; // TODO: make this dynamic
    int favor = 300; // TODO: make this dynamic
    int maxFavor = 1000; // TODO: make this dynamic

    List<Element> insertGiantName = querySelectorAll(".insert-giantname").toList();
    insertGiantName.forEach((placeholder) => placeholder.text = giantName);

    int percent = ((100 / maxFavor) * favor).round();
    Map<String,String> progressAttributes = {
      "percent": percent.toString(),
      "status": favor.toString() + " of " + maxFavor.toString() + " favor towards an Emblem of " + giantName
    };
    querySelector("#shrine-window-favor").attributes = progressAttributes;
  }
}