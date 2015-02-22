part of couclient;

class NetChatManager {
  WebSocket _connection;
  String _chatServerUrl = 'ws://$websocketServerAddress/chat';

  NetChatManager() {
    setupWebsocket(_chatServerUrl);

    new Service([#chatEvent], (Message event) {
    	if (event.content["statusMessage"] == "ping") //used to keep the connection alive
    		new Message(#outgoingChatEvent, {'statusMessage':'pong'});
    	else
    	{
    		for (Chat convo in openConversations)
    		{
    			if (convo.title == "Local Chat" && (event.content['channel'] == 'all' || event.content['street'] == currentStreet.label))
    				convo.processEvent(event.content);
    			else if (convo.title == event.content['channel'] && convo.title != "Local Chat")
    				convo.processEvent(event.content);
    		}
    	}
    });

    new Service([#chatListEvent], (Message event) {
      for (Chat convo in openConversations) {
        if (convo.title == event.content['channel']) convo.addAlert("Players in this Channel:  ${event.content['users']}".replaceAll('[', '').replaceAll(']', ''));
      }
    });

    new Service([#startChat], (Message event) {
      Chat chat = new Chat(event.content as String);
    });

    new Service([#outgoingChatEvent], (Message<Map> event) {
      if (_connection.readyState == WebSocket.OPEN) {
        post(event.content);
      }
      return;
    });

  }



  post(Map data) {
    _connection.sendString(JSON.encoder.convert(data));
  }

  void setupWebsocket(String url) {
    _connection = new WebSocket(url)
        ..onOpen.listen((_) {
          // First event, tells the server who we are.
          post(new Map()
          	  ..['tsid'] = streetService.currentTsid
              ..['username'] = game.username
              ..['statusMessage'] = 'join');

          // Get a List of the other players online
          post(new Map()
              ..['hide'] = 'true'
              ..['username'] = game.username
              ..['statusMessage'] = 'list'
              ..['channel'] = 'Global Chat');
        })
        ..onMessage.listen((MessageEvent event) {
          Map data = JSON.decoder.convert(event.data);
          if (data['statusMessage'] == 'list') new Message(#chatListEvent, data); else new Message(#chatEvent, data);
        })
        ..onClose.listen((_) {
          //wait 5 seconds and try to reconnect
          new Timer(new Duration(seconds: 5), () => setupWebsocket(url));
        })
        ..onError.listen((message) {
          // Send the Error to the bus.
          new Message(#err, 'Problem with Websocket, check console');
        });
  }
}
