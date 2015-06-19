part of couclient;

class ShrineWindow extends Modal {
  String id = 'shrineWindow';

  ShrineWindow() {
    prepare();

    String giantName = "Alph";
    int favor = 300;
    int maxFavor = 1000;

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