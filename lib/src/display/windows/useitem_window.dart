part of couclient;

class UseWindow extends Modal {
  String id = 'useWindow' + random.nextInt(9999999).toString(), itemName;
  static Map<String, UseWindow> instances = {};
  List<Map> recipeList;
  Element well;

  factory UseWindow(String itemName) {
    if (instances[itemName] == null) {
      instances[itemName] = new UseWindow._(itemName);
    } else {
      instances[itemName].open();
    }
    return instances[itemName];
  }

  UseWindow._(this.itemName) {
    load().then((Element el) {
      querySelector("#windowHolder").append(el);
      prepare();
      open();
    });
  }

  Future<Element> load() async {

    // Header

    Element closeButton = new Element.tag("i")
      ..classes.add("fa-li")
      ..classes.add("fa")
      ..classes.add("fa-times")
      ..classes.add("close");

    Element icon = new Element.tag("i")
      ..classes.add("fa-li")
      ..classes.add("fa")
      ..classes.add("fa-bars");

    SpanElement titleSpan = new SpanElement()
      ..text = "Using a $itemName";

    Element header = new Element.header()
      ..append(icon)
      ..append(titleSpan);

    // Container

    well = new Element.tag("ur-well")
      ..classes.add("useitem-well")
      ..append(await listRecipes(false));

    DivElement window = new DivElement()
      ..id = id
      ..classes.add("window")
      ..classes.add("useWindow")
      ..append(closeButton)
      ..append(header)
      ..append(well);

    return(window);
  }

  Future<Element> listRecipes([bool clearWell = true]) async {
    if (clearWell) {
      well
        ..children.clear()
        ..classes.remove("col3");
    }

    recipeList = JSON.decode(await HttpRequest.requestCrossOrigin("http://${Configs.utilServerAddress}/recipes/list?tool=$itemName&email=${game.email}"));

    DivElement recipeContainer = new DivElement()
      ..classes.add("useitem-recipes")
      ..hidden = false;

    if (recipeList.length > 0) {
      recipeList.forEach((Map recipe) {
        DivElement image = new DivElement()
          ..classes.add("useitem-recipe-image")
          ..style.backgroundImage = "url(${recipe["output_map"]["iconUrl"]})";

        DivElement info = new DivElement()
          ..classes.add("useitem-recipe-text")
          ..text = recipe["output_map"]["name"];

        DivElement recipeBtn = new DivElement()
          ..classes.addAll(["useitem-recipe", "white-btn"])
          ..append(image)
          ..append(info)
          ..onClick.listen((_) => openRecipe(recipe["id"]));

        recipeContainer.append(recipeBtn);
      });
    } else {
      SpanElement noRecipes = new SpanElement()
        ..classes.add("useitem-norecipes")
        ..text = "You don't know how to make anything with this.";

      recipeContainer.append(noRecipes);
    }

    return recipeContainer;
  }

  openRecipe(String id) {
    Map recipe = getRecipe(id);

    // output info

    DivElement backToList = new DivElement()
      ..classes.addAll(["recipeview-backtolist", "white-btn"])
      ..setInnerHtml('<i class="fa fa-chevron-left"></i>&emsp;Cancel')
      ..onClick.listen((_) async => well.append(await listRecipes()));

    DivElement itemImage = new DivElement()
      ..classes.add("recipeview-image")
      ..style.backgroundImage = "url(${recipe["output_map"]["iconUrl"]})";

    DivElement itemName = new DivElement()
      ..classes.add("recipeview-text")
      ..text = recipe["output_map"]["name"];

    DivElement leftCol = new DivElement()
      ..classes.add("recipeview-leftcol")
      ..append(backToList)
      ..append(itemImage)
      ..append(itemName);

    // qty controls

    DivElement qtyParent = new DivElement()
      ..classes.add("recipeview-qtyparent");

    DivElement makeBtn = new DivElement()
      ..classes.addAll(["rv-makebtn", "white-btn"])
      ..onClick.listen((_) => makeRecipe(id)) //TODO: user-input qty `(id, qty)`
      ..text = "Do It!";
    //TODO: disable if cannot make item (server must report canMake from inventory)

    DivElement centerCol = new DivElement()
      ..classes.add("recipeview-centercol")
      ..append(qtyParent)
      ..append(makeBtn);

    // ingredients

    DivElement ingTitle = new DivElement()
      ..classes.add("recipeview-ing-title")
      ..text = "Ingredients";

    TableElement ingList = new TableElement()
      ..classes.add("recipeview-ing-list");

    (recipe["input"] as List<Map>).forEach((Map ingmap) {
      TableCellElement img = new TableCellElement()
        ..style.backgroundImage = "url(${ingmap["iconUrl"]})"
        ..classes.add("rv-ing-list-img");

      TableCellElement text = new TableCellElement()
        ..setInnerHtml("<b>${ingmap["qtyReq"]}x</b> " + ingmap["name"]);

      Element status = new Element.tag("i");
      if (ingmap["userHas"] == true) {
        status
          ..classes.addAll(["fa", "fa-check", "fa-fw", "rv-green"])
          ..title = "You have enough";
      } else {
        status
          ..classes.addAll(["fa", "fa-times", "fa-fw", "rv-red"])
          ..title = "You don't have enough";
      }

      TableCellElement statusCol = new TableCellElement()
        ..append(status);

      TableRowElement item = new TableRowElement()
        ..append(img)
        ..append(text)
        ..append(statusCol);

      ingList.append(item);
    });

    DivElement rightCol = new DivElement()
      ..classes.add("recipeview-rightcol")
      ..append(ingTitle)
      ..append(ingList);

    // display
    well
      ..children.clear()
      ..append(leftCol)
      ..append(centerCol)
      ..append(rightCol)
      ..classes.add("col3");
  }

  Future makeRecipe(String id, [int qty = 1]) async {
    Map recipe = getRecipe(id);

    int time = recipe["time"] * qty;

    int current = 1;

    ImageElement animation = new ImageElement()
      ..src = await HttpRequest.requestCrossOrigin("http://${Configs.utilServerAddress}/recipes/getAnimUrl?tool=${recipe["tool"]}");

    DivElement animationParent = new DivElement()
      ..classes.add("makerecipe-anim")
      ..append(animation);

    Element progBar = new Element.tag("ur-progress")
      ..attributes["percent"] = "1"
      ..attributes["status"] = "Making ${current.toString()} of ${qty.toString()}...";

    // display
    well
      ..children.clear()
      ..append(animationParent)
      ..append(progBar);

    return;
  }

  Map getRecipe(String id) {
    return recipeList.where((Map r) => r["id"] == id).first;
  }

  @override
  close() {
    instances[itemName].displayElement.hidden = true;
    super.close();
  }
}