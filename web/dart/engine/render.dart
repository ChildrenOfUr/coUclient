part of coUclient;

//TODO: comment the begining of files with brief descriptions as to what they do.


// Our renderloop
render() {
  // Update clock
  refreshClock();
    
  //Draw Street
  if (CurrentStreet is Street)
  CurrentStreet.render();
  
  //Clear canvas (very expensive)
  //Minimizes clearing for now
  if (CurrentCamera is Camera)
    gameCanvas.width = gameCanvas.width;
  
  //Draw Player
  if (CurrentPlayer is Player)
    CurrentPlayer.render();
}


Camera CurrentCamera;

//Replaces Map Camera. Necessary for handling camera as an object
//Repositions itself to match player's position

//TODO: Map should not be hard-coded to follow player, follow object should be variable
class Camera{
  
  int x;
  int y;
  
  Camera(){
    //~/ is truncating division; result -> int
    x = CurrentPlayer.posX-gameScreen.clientWidth~/2;
    y = CurrentPlayer.posY-gameScreen.clientHeight~/2;
  }
  
  update(){
    x = CurrentPlayer.posX-gameScreen.clientWidth~/2;
    y = CurrentPlayer.posY-gameScreen.clientHeight~/2;
    
    //Camera can't go outside the bounds of the lvl
    if (x < 0)
      x = 0;
    if (x > CurrentStreet.width - gameScreen.clientWidth)
      x = CurrentStreet.width - gameScreen.clientWidth;
    if (y < 0)
      y = 0;
    if (y > CurrentStreet.height-gameScreen.clientHeight)
      y = CurrentStreet.height-gameScreen.clientHeight;
  }
}



