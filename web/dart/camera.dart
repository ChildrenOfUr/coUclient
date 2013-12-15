part of coUclient;
Camera CurrentCamera;
//TODO: Change to init

//Replaces Map Camera. Necessary for handling camera as an object
//Repositions itself incrementally to match player's position, as in Glitch
//TODO: Map should not be hard-coded to follow player, follow object should be variable
class Camera{
  int x;
  int y;
  Camera(){
    //~/ is truncating division; result -> int
    x = mysteryman.posX-gameScreen.clientWidth~/2;
    y = mysteryman.posY-gameScreen.clientHeight~/2;
  }
  
  update(){
    x = mysteryman.posX-gameScreen.clientWidth~/2;
    y = mysteryman.posY-gameScreen.clientHeight~/2;
  }
}