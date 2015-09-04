part of couclient;

class QuestManager {
	static QuestManager _instance;

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
		WebSocket socket = new WebSocket(url);
		socket.onOpen.listen((_) => socket.send(JSON.encode({
			                                                    'connect':true,
			                                                    'email':game.email
		                                                    })));

		await for (MessageEvent event in socket.onMessage) {
			Map map = JSON.decode(event.data);
			if(map['questComplete'] != null) {
				toast('${map['questComplete']['title']} completed!');
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