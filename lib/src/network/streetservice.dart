part of couclient;

class StreetService {
  String _dataUrl = 'https://server.childrenofur.com:8383/data';

  Future requestStreet(String StreetID) {

    Completer c = new Completer();

    HttpRequest.request(_dataUrl + "/street", method: "POST", requestHeaders: {
        "content-type": "application/json"
    }, sendData: JSON.encode({
        'street': StreetID, 'sessionToken': SESSION_TOKEN
    })).then((HttpRequest data) {
      Map serverdata = JSON.decode(data.response);

      if (serverdata['ok'] == 'no') {
        print('Error: Server refused.');
      }

      if(metabolics.metabolics != null)
    	  metabolics.setCurrentStreet(StreetID);
      c.complete(prepareStreet(serverdata['streetJSON']));

    });
    return c.future;
  }
}


Future prepareStreet(Map streetJSON){

    Completer c = new Completer();

    if (streetJSON['tsid'] == null) c.complete(null);
    Map<String,dynamic> streetAsMap = streetJSON;
    String label = streetAsMap['label'];
    String tsid = streetAsMap['tsid'];

    // TODO, this should happen automatically on the Server, since it'll know which street we're on.
    //send changeStreet to chat server
    Map map = new Map();
    map["statusMessage"] = "changeStreet";
    map["username"] = game.username;
    map["newStreetLabel"] = label;
    map["newStreetTsid"] = tsid;
    map["oldStreet"] = sessionStorage['playerStreet'];
    new Message(#outgoingChatEvent,map);

    view.streetLoadingImage.src = streetAsMap['loading_image']['url'];
    view.streetLoadingImage.onLoad.first.then((_)
    {
		String hubName = new DataMaps().data_maps_hubs[streetAsMap['hub_id']]()['name'];
		view.mapLoadingContent.style.opacity = "1.0";
		view.nowEntering.setInnerHtml('<h2>Entering</h2><h1>' + label + '</h1><h2>in ' + hubName/* + '</h2><h3>Home to: <ul><li>A <strong>Generic Goods Vendor</strong></li></ul>'*/);
		new Timer(new Duration(seconds:1),()
		{
			new Asset.fromMap(streetAsMap,label);
			c.complete(new Street(streetAsMap).load());
		});
	});

	return c.future;
  }