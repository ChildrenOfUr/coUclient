part of couclient;


class StreetService {
  String _dataUrl = 'https://robertmcdermot.com:8383/data';

  StreetService() {

  }

  void requestStreet(String StreetID) {
    HttpRequest.request(_dataUrl + "/street", method: "POST", requestHeaders: {
        "content-type": "application/json"
    }, sendData: JSON.encode({
        'street': StreetID
    })).then((HttpRequest data) {
      print(data.response);
      Map serverdata = JSON.decode(data.response);

      if (serverdata['ok'] == 'no') {
        print('Error: Server refused.');
        return;
      }

      prepareStreet(serverdata['streetJSON']);

    });
  }

}


prepareStreet(String streetJSON){

    if (JSON.decode(streetJSON)['tsid'] == null) return;
    Map<String,dynamic> street = JSON.decode(streetJSON);
    String label = street['label'];
    String tsid = street['tsid'];

    // TODO, this should happen automatically on the Server, since it'll know which street we're on.
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
  }