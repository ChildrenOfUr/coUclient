part of couclient;

String multiplayerServer = "${Configs.ws}//${Configs.websocketServerAddress}/playerUpdate";
String streetEventServer = "${Configs.ws}//${Configs.websocketServerAddress}/streetUpdate";
String joined = "",
	creatingPlayer = "";
WebSocket streetSocket, playerSocket;
bool reconnect = true,
	firstConnect = true,
	serverDown = false;
Map<String, Player> otherPlayers = new Map();
Map<String, Quoin> quoins = new Map();
Map<String, Entity> entities = new Map();
Map<String, bool> addingLocks = {};

multiplayerInit() {
	_setupPlayerSocket();
	_setupStreetSocket(currentStreet.label);
}

void addQuoin(Map<String, dynamic> map) {
	String id = map['id'];
	if(addingLocks[id] ?? false) {
		return;
	}

	if (currentStreet != null && currentStreet.loaded) {
		addingLocks[id] = true;
		quoins[id] = new Quoin(map);
	}
}

void addNPC(Map map) {
	String id = map['id'];
	if(addingLocks[id] ?? false) {
		return;
	}

	if (currentStreet != null && currentStreet.loaded) {
		addingLocks[id] = true;
		entities[id] = new NPC(map);
	}
}

void addPlant(Map map) {
	String id = map['id'];
	if(addingLocks[id] ?? false) {
		return;
	}

	if (currentStreet != null && currentStreet.loaded) {
		addingLocks[id] = true;
		entities[id] = new Plant(map);
	}
}

void addDoor(Map<String, dynamic> map) {
	String id = map['id'];
	if(addingLocks[id] ?? false) {
		return;
	}

	if (currentStreet != null && currentStreet.loaded) {
		addingLocks[id] = true;
		entities[id] = new Door(map);
	}
}

void addItem(Map map) {
	String id = map['id'];
	if(addingLocks[id] ?? false) {
		return;
	}

	if (currentStreet != null && currentStreet.loaded) {
		addingLocks[id] = true;
		entities[id] = new GroundItem(map);
	}
}