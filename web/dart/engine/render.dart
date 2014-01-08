part of coUclient;

//TODO: comment the begining of files with brief descriptions as to what they do.


// Our renderloop
render() {
  // Update clock
  refreshClock();
  //Draw Street
  if (currentStreet is Street)
  currentStreet.render();
  

}


