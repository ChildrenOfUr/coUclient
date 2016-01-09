part of couclient;

String multiplayerServer = "ws://${Configs.websocketServerAddress}/playerUpdate";
String streetEventServer = "ws://${Configs.websocketServerAddress}/streetUpdate";
String joined = "",
	creatingPlayer = "";
WebSocket streetSocket, playerSocket;
bool reconnect = true,
	firstConnect = true,
	serverDown = false;
Map<String, Player> otherPlayers = new Map();
Map<String, Quoin> quoins = new Map();
Map<String, Entity> entities = new Map();

multiplayerInit() {
	_setupPlayerSocket();
	_setupStreetSocket(currentStreet.label);
}

void addQuoin(Map map) {
	if (currentStreet != null) {
		quoins[map['id']] = new Quoin(map);
	}
}

void addNPC(Map map) {
	if (currentStreet != null) {
		entities[map['id']] = new NPC(map);
	}
}

void addPlant(Map map) {
	if (currentStreet != null) {
		entities[map['id']] = new Plant(map);
	}
}

void addDoor(Map map) {
	if (currentStreet != null) {
		entities[map['id']] = new Door(map);
	}
}

void addItem(Map map) {
	if (currentStreet != null) {
		entities[map['id']] = new GroundItem(map);
	}
}