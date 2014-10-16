part of couclient;

class NetworkDataManager {
  WebSocket _connection;
  String _webSocketUrl = 'wss://robertmcdermot.com:8282/data';
  
  
  AuthManager() {
    setupWebsocket(_webSocketUrl);
  }

  post(Map data) {
    _connection.sendString(JSON.encoder.convert(data));
  }

  void setupWebsocket(String url) {
    _connection = new WebSocket(url)
        ..onOpen.listen((_) {
          // First event, request our tokens.
          post(new Map()
              ..['request'] = 'tokens'
              ..['persona'] = {'assertion':'null','audience':window.location.href});
        })
        
        ..onMessage.listen((MessageEvent message) {
          Map data = JSON.decoder.convert(message.data);
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





  listenForStreets(){
    window.onMessage.listen((MessageEvent event)
  {
    if (JSON.decode(event.data)['tsid'] == null) return;
    Map<String,dynamic> street = JSON.decode(event.data);
    String label = street['label'];
    String tsid = street['tsid'];

    //send changeStreet to chat server
    Map map = new Map();
    map["statusMessage"] = "changeStreet";
    map["username"] = ui.username;
    map["newStreetLabel"] = label;
    map["newStreetTsid"] = tsid;
    map["oldStreet"] = currentStreet.label;
    new Message(#outgoingChatEvent,map);

    ui.streetLoadingImage.src = street['loading_image']['url'];
    ui.streetLoadingImage.onLoad.first.then((_)
    {
      String hubName = new DataMaps().data_maps_hubs[street['hub_id']]()['name'];
      ui.mapLoadingContent.style.opacity = "1.0";
      ui.nowEntering.setInnerHtml('<h2>Entering</h2><h1>' + label + '</h1><h2>in ' + hubName/* + '</h2><h3>Home to: <ul><li>A <strong>Generic Goods Vendor</strong></li></ul>'*/);
      new Timer(new Duration(seconds:1),()
            {
        new Asset.fromMap(street,label);
                new Street(label).load();
      });
    });
  });
  }