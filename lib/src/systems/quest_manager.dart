part of couclient;

class QuestRewards {
	int energy, mood, img, currants;
	List<QuestFavor> favor;
}

class QuestFavor {
	String giantName;
	int favAmt;
}

class Quest {
	String id, title, questText, completionText;
	bool complete = false;
	List<Quest> prerequisites = [];
	List<Requirement> requirements = [];
	Conversation conversation_start, conversation_end, conversation_fail;
	QuestRewards rewards;
}

class Requirement {
	int numRequired;
	String id, text, type, eventType;
}

class QuestManager {
	static QuestManager _instance;
	static WebSocket socket;

	QuestManager._() {
		_setupWebsocket();
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
		Map connectMap = {
			'connect':true,
			'email':game.email
		};
		socket.onOpen.listen((_) => socket.send(JSON.encode(connectMap)));

		await for (MessageEvent event in socket.onMessage) {
			Map map = JSON.decode(event.data);
			if (map['questComplete'] != null) {
				Quest quest = decode(JSON.encode(map['quest']), type: Quest);
				windowManager.rockWindow.createConvo(quest.conversation_end, rewards: quest.rewards);
				windowManager.rockWindow.switchContent('rwc-'+quest.conversation_end.id);
				windowManager.rockWindow.open();
			}
			if (map['questFail'] != null) {
				Quest quest = decode(JSON.encode(map['quest']), type: Quest);
				windowManager.rockWindow.createConvo(quest.conversation_fail);
				windowManager.rockWindow.switchContent('rwc-'+quest.conversation_fail.id);
				windowManager.rockWindow.open();
			}
			if (map['questOffer'] != null) {
				Quest quest = decode(JSON.encode(map['quest']), type: Quest);
				windowManager.rockWindow.createConvo(quest.conversation_start);
				windowManager.rockWindow.switchContent('rwc-'+quest.conversation_start.id);
				windowManager.rockWindow.open();
			}
		}
		socket.onClose.listen((CloseEvent e) {
			logmessage('[Quest] Websocket closed: ${e.reason}');
			//wait 5 seconds and try to reconnect
			new Timer(new Duration(seconds: 5), () => _setupWebsocket());
		});
		socket.onError.listen((ErrorEvent e) {
			logmessage('[Quest] Error ${e.error}');
		});
	}
}