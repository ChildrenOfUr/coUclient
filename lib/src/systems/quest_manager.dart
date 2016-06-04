part of couclient;

class QuestRewards {
	int energy = 0;
	int mood = 0;
	int img = 0;
	int currants = 0;
	List<QuestFavor> favor = new List();
}

class QuestFavor {
	String giantName;
	int favAmt = 0;
}

class Quest {
	String id, title, description;
	bool complete = false;
	List<String> prerequisites;
	List<Requirement> requirements;
	Conversation conversation_start, conversation_end, conversation_fail;
	QuestRewards rewards;
}

class Requirement {
	bool fulfilled;
	int numRequired, timeLimit, numFulfilled;
	String id, text, type, eventType, iconUrl;
	List<String> typeDone;
}

class QuestManager {
	static QuestManager _instance;
	WebSocket socket;

	QuestManager._() {
		_setupWebsocket();

		new Service('questChoice', (Map map) {
			print('sending choice: $map');
			socket.send(JSON.encode(map));
		});
	}

	factory QuestManager() {
		if (_instance == null) {
			_instance = new QuestManager._();
		}

		return _instance;
	}

	Future _setupWebsocket() async {
		String url = 'ws://${Configs.websocketServerAddress}/quest';
		socket = new WebSocket(url);

		socket.onOpen.listen((_) => socket.send(JSON.encode({'connect':true, 'email':game.email})));
		socket.onClose.listen((CloseEvent e) {
			logmessage('[Quest] Websocket closed: ${e.reason}');
			//wait 5 seconds and try to reconnect
			new Timer(new Duration(seconds: 5), () => _setupWebsocket());
		});
		socket.onError.listen((Event e) {
			logmessage('[Quest] Error ${e}');
		});

		socket.onMessage.listen((MessageEvent event) {
			Map map = JSON.decode(event.data);
			if (map['questComplete'] != null) {
				Quest quest = decode(JSON.encode(map['quest']), type: Quest);
				transmit('questComplete', quest);
				windowManager.rockWindow.createConvo(quest.conversation_end, rewards: quest.rewards);
				windowManager.rockWindow.switchContent('rwc-' + quest.conversation_end.id);
				windowManager.rockWindow.open();
			}
			if (map['questFail'] != null) {
				Quest quest = decode(JSON.encode(map['quest']), type: Quest);
				windowManager.rockWindow.createConvo(quest.conversation_fail);
				windowManager.rockWindow.switchContent('rwc-' + quest.conversation_fail.id);
				windowManager.rockWindow.open();
			}
			if (map['questOffer'] != null) {
				Quest quest = decode(JSON.encode(map['quest']), type: Quest);
				windowManager.rockWindow.createConvo(quest.conversation_start);
				windowManager.rockWindow.switchContent('rwc-' + quest.conversation_start.id);
				windowManager.rockWindow.open();
			}
			if (map['questInProgress'] != null) {
				Quest quest = decode(JSON.encode(map['quest']), type: Quest);
				transmit('questInProgress', quest);
			}
			if (map['questBegin'] != null) {
				Quest quest = decode(JSON.encode(map['quest']), type: Quest);
				transmit('questBegin', quest);
			}
			if (map['questUpdate'] != null) {
				Quest quest = decode(JSON.encode(map['quest']), type: Quest);
				transmit('questUpdate', quest);
			}
		});
	}
}