part of couclient;

class NetChatManager {
  WebSocket _connection;
  String _chatServerUrl = 'ws://${Configs.websocketServerAddress}/chat';

  NetChatManager() {
    setupWebsocket(_chatServerUrl);

    new Service(['chatEvent'], (event) {
      if (event["statusMessage"] == "ping") {
        //used to keep the connection alive
        transmit('outgoingChatEvent', {'statusMessage':'pong'});
      } else if (event["muted"] != null) {
        if (event["toastClick"] == "__EMAIL_COU__") {
          new Toast(event["toastText"], onClick: (_) {
            window.open("mailto:publicrelations@childrenofur.com", "_blank");
          });
        }
      } else {
        for (Chat convo in openConversations) {
          if (convo.title == "Local Chat" && (event['channel'] == 'all' || event['street'] == currentStreet.label))
            convo.processEvent(event);
          else if (convo.title == event['channel'] && convo.title != "Local Chat")
            convo.processEvent(event);
        }
      }
    });

    new Service(['chatListEvent'], (event) {
      for (Chat convo in openConversations) {
        if (convo.title == event['channel']) {
          convo.displayList(event['users']);
        }
      }
    });

    new Service(['startChat'], (event) {
      new Chat(event as String);
    });

    new Service(['outgoingChatEvent'], (event) {
      if (_connection.readyState == WebSocket.OPEN) {
        post(event);
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
        ..['tsid'] = currentStreet.streetData['tsid']
        ..['street'] = currentStreet.label
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
      if (data['statusMessage'] == 'list') {
        transmit('chatListEvent', data);
      } else {
        transmit('chatEvent', data);
      }
    })
      ..onClose.listen((_) {
      //wait 5 seconds and try to reconnect
      new Timer(new Duration(seconds: 5), () => setupWebsocket(url));
    })
      ..onError.listen((Event e) {
      logmessage('[Chat] Socket error "$e"');
    });
  }

  static void updateTabUnread() {
    Element rightSide = querySelector("#rightSide");
    Element tab = rightSide.querySelector(".toggleSide");
    bool unreadmessages = false;
    for (Element e in rightSide.querySelectorAll("ul li.chatSpawn")) {
      if (e.classes.contains("unread")) {
        unreadmessages = true;
        break;
      }
    }
    if (unreadmessages) {
      tab.classes.add("unread");
    } else {
      tab.classes.remove("unread");
    }
  }
}