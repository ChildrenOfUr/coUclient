part of coUclient;

//TODO: comment the begining of files with brief descriptions as to what they do.


// Our renderloop
render() {
  // Update clock
  refreshClock();
    
  //Draw Street
  //if (CurrentStreet is Street)
  //CurrentStreet.render();
  

}



Entity camera = world.createEntity()
..addComponent(new CameraPosition(200,200))
..addToWorld();


