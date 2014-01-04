part of coUclient;

Street currentStreet;

Batch streets;

Future load_streets(){
  // allows us to load street files as though they are json files.
  jsonExtensions.add('street');
  final c = new Completer();
  // just loads the database file of street urls, nothing more.
  new Asset('./assets/streets.json').load()
      .then((Asset streetList) {
        print(streetList.get());
        c.complete(streetList);});
        return c.future;
        
}




class Street {    
  String label;
  
  int width;
  int height;
  
  //the outer bounds of the street
  int top;
  int bottom;
  int left;
  int right;
  
  String gradientTop;
  String gradientBottom;

  Street(String ID){

    
  }
  
  
  load(){
    currentStreet = this;
  }  
}