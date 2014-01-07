part of coUclient;

Street currentStreet;

Future load_streets(){
  // allows us to load street files as though they are json files.
  jsonExtensions.add('street');
  final c = new Completer();
  // just loads the database file of street urls, nothing more.
  new Asset('./assets/streets.json').load()
      .then((Asset streetList) {
        
        // Load each street file into memory. They're just json so it's probably not a big deal.
        List toLoad = [];
        for (String url in streetList.get().values)
        toLoad.add(new Asset(url).load());
        
        return Future.wait(toLoad);
        });
}




class Street {    
  String label;
  
  Map _data;
  
  int width;
  int height;
  
  //the outer bounds of the street
  int top;
  int bottom;
  int left;
  int right;
  
  String gradientTop;
  String gradientBottom;

  Street(String streetName){
     _data = ASSET[streetName].get();
  }
  
  
 Future <List> load(){
   currentStreet = null; 
   
    List decosToLoad = [];
    
    for (Map layer in _data['dynamic']['layers'].values)
    {
      for (Map deco in layer['decos'])
      {
        if (decosToLoad.contains('http://revdancatt.github.io/CAT422-glitch-location-viewer/img/scenery/' + deco['filename'] + '.png')
            == false)
        decosToLoad.add('http://revdancatt.github.io/CAT422-glitch-location-viewer/img/scenery/' + deco['filename'] + '.png');
      }      
    }
    
    List assetsToLoad = [];
    for (String deco in decosToLoad){
      assetsToLoad.add(new Asset(deco));}
         
    
    Batch decos = new Batch(assetsToLoad);
    currentStreet = this;
    return decos.load(setStreetLoadBar);
  }  
}

setStreetLoadBar(int percent){
  querySelector('#MapLoadingBar').style.width = (percent + 1).toString() + '%';
}
