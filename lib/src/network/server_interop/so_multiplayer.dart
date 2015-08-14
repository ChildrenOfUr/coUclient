part of couclient;

String multiplayerServer = "ws://${Configs.websocketServerAddress}/playerUpdate";
String streetEventServer = "ws://${Configs.websocketServerAddress}/streetUpdate";
String joined = "", creatingPlayer = "";
WebSocket streetSocket, playerSocket;
bool reconnect = true, firstConnect = true, serverDown = false;
Map<String, Player> otherPlayers = new Map();
Map<String, Quoin> quoins = new Map();
Map<String, Entity> entities = new Map();

multiplayerInit() {
  _setupPlayerSocket();
  _setupStreetSocket(currentStreet.label);
}

void addQuoin(Map map) {
  if (currentStreet == null) return;

  quoins[map['id']] = new Quoin(map);
}

void addNPC(Map map) {
  if (currentStreet == null) return;

  entities[map['id']] = new NPC(map);
}

void addPlant(Map map) {
  if (currentStreet == null) return;

  entities[map['id']] = new Plant(map);
}

void addDoor(Map map) {
  if (currentStreet == null) {
    return;
  } else {
    entities[map['id']] = new Door(map);
  }
}

void addItem(Map map) {
  if (currentStreet == null) {
    return;
  }

  entities[map['id']] = new GroundItem(map);
}

Future animate(ImageElement i, Map map) {
  Completer c = new Completer();
  Element fromObject = querySelector("#${map['fromObject']}");
  DivElement item = new DivElement();

  num fromX = num.parse(fromObject.attributes['translatex']) - camera.getX();
  num fromY = num.parse(fromObject.attributes['translatey']) - camera.getY() - fromObject.clientHeight;
  item.className = "item";
  item.style.width = (i.naturalWidth / 4).toString() + "px";
  item.style.height = i.naturalHeight.toString() + "px";
  item.style.transformOrigin = "50% 50%";
  item.style.backgroundImage = 'url(${map['url']})';
  item.style.transform = "translate(${fromX}px,${fromY}px)";
  //print("from: " + item.style.transform);
  querySelector("#GameScreen").append(item);

  //animation seems to happen instantaneously if there isn't a delay
  //between adding the element to the document and changing its properties
  //even this 1 millisecond delay seems to fix that - strange
  new Timer(new Duration(milliseconds: 1), () {
    Element playerParent = querySelector(".playerParent");
    item.style.transform =
    "translate(${playerParent.attributes['translatex']}px,${playerParent.attributes['translatey']}px) scale(2)";
    //print("to: " + item.style.transform);
  });
  new Timer(new Duration(seconds: 2), () {
    item.style.transform =
    "translate(${CurrentPlayer.posX}px,${CurrentPlayer.posY}px) scale(.5)";

    //wait 1 second for animation to finish and then remove
    new Timer(new Duration(seconds: 1), () {
      item.remove();
      c.complete();
    });
  });

  return c.future;
}