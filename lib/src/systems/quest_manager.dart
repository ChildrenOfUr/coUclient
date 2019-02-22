part of couclient;

@JsonSerializable()
class QuestRewards {
	int energy = 0;
	int mood = 0;
	int img = 0;
	int currants = 0;
	List<QuestFavor> favor = [];

	QuestRewards();
	factory QuestRewards.fromJson(Map<String, dynamic> json) => _$QuestRewardsFromJson(json);
	Map<String, dynamic> toJson() => _$QuestRewardsToJson(this);
}

@JsonSerializable()
class QuestFavor {
	String giantName;
	int favAmt = 0;

	QuestFavor();
	factory QuestFavor.fromJson(Map<String, dynamic> json) => _$QuestFavorFromJson(json);
	Map<String, dynamic> toJson() => _$QuestFavorToJson(this);
}

@JsonSerializable()
class Quest {
	String id, title, description;
	bool complete = false;
	List<String> prerequisites;
	List<Requirement> requirements;
	Conversation conversation_start, conversation_end, conversation_fail;
	QuestRewards rewards;

	Quest();
	factory Quest.fromJson(Map<String, dynamic> json) => _$QuestFromJson(json);
	Map<String, dynamic> toJson() => _$QuestToJson(this);
}

@JsonSerializable()
class Requirement {
	bool fulfilled;
	int numRequired, timeLimit, numFulfilled;
	String id, text, type, eventType, iconUrl;
	List<String> typeDone;

	Requirement();
	factory Requirement.fromJson(Map<String, dynamic> json) => _$RequirementFromJson(json);
	Map<String, dynamic> toJson() => _$RequirementToJson(this);
}

class QuestManager {
	static QuestManager _instance;
	WebSocket socket;

	QuestManager._() {
		_setupWebsocket();

		new Service('questChoice', (Map map) {
			socket.send(jsonEncode(map));
		});
	}

	factory QuestManager() {
		if (_instance == null) {
			_instance = new QuestManager._();
		}

		return _instance;
	}

	Future _setupWebsocket() async {
		String url = '${Configs.ws}//${Configs.websocketServerAddress}/quest';
		socket = new WebSocket(url);

		socket.onOpen.listen((_) => socket.send(jsonEncode({'connect':true, 'email':game.email})));
		socket.onClose.listen((CloseEvent e) {
			logmessage('[Quest] Websocket closed: ${e.reason}');
			//wait 5 seconds and try to reconnect
			new Timer(new Duration(seconds: 5), () => _setupWebsocket());
		});
		socket.onError.listen((Event e) {
			logmessage('[Quest] Error ${e}');
		});

		socket.onMessage.listen((MessageEvent event) {
			Map map = jsonDecode(event.data);
			if (map['questComplete'] != null) {
				Quest quest = Quest.fromJson(map['quest']);
				transmit('questComplete', quest);
				windowManager.rockWindow.createConvo(quest.conversation_end, rewards: quest.rewards);
				windowManager.rockWindow.switchContent('rwc-' + quest.conversation_end.id);
				windowManager.rockWindow.open();
			}
			if (map['questFail'] != null) {
				Quest quest = Quest.fromJson(map['quest']);
				windowManager.rockWindow.createConvo(quest.conversation_fail);
				windowManager.rockWindow.switchContent('rwc-' + quest.conversation_fail.id);
				windowManager.rockWindow.open();
			}
			if (map['questOffer'] != null) {
				Quest quest = Quest.fromJson(map['quest']);
				windowManager.rockWindow.createConvo(quest.conversation_start);
				windowManager.rockWindow.switchContent('rwc-' + quest.conversation_start.id);
				windowManager.rockWindow.open();
			}
			if (map['questInProgress'] != null) {
				Quest quest = Quest.fromJson(map['quest']);
				transmit('questInProgress', quest);
			}
			if (map['questBegin'] != null) {
				Quest quest = Quest.fromJson(map['quest']);
				transmit('questBegin', quest);
			}
			if (map['questUpdate'] != null) {
				Quest quest = Quest.fromJson(map['quest']);
				transmit('questUpdate', quest);
			}
		});
	}
}