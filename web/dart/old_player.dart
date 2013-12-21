part of coUclient;

Player CurrentPlayer;

class Player{
  
  int posX;
  int posY;
  
  int width;
  int height;
  
  ImageElement avatar;
  
  //for testing purposes
  //if false, player can move around with wasd and arrows, no falling
  bool doPhysicsApply = true;
  
  CanvasElement playerCanvas;
  
  Player(){
    avatar = new ImageElement(src: "assets/sprites/avatar.png");
    //TODO: Remove hard-coded values used for testing
    posX = 0;
    posY = 550;
    width = 100;
    height = 172;
    
    CurrentPlayer = this;
  }
  
  update(){
    //should be more general value 'speed'
    if (playerInput.rightKey == true)
      posX += 5;
    if (playerInput.leftKey == true)
      posX -= 5;
    //primitive jumping
    if (playerInput.spaceKey == true)
      posY -= 10;
    
    //needs acceleration, some gravity const somewhere
    //for jumps/falling
    
    if (doPhysicsApply == false){
      if (playerInput.downKey == true)
        posY += 5;
      if (playerInput.upKey == true)
        posY -= 5;
    }
    if (doPhysicsApply == true) {
      if (posY < 400){
        posY += 3;
      }
    }
    
    if (posX < 0)
      posX = 0;
    if (posX > CurrentStreet.width - width)
      posX = CurrentStreet.width - width;
    if (posY < 0)
      posY = 0;
    if (posY > CurrentStreet.height + height)
      posY = CurrentStreet.height + height;

    CurrentPlayer = this;
  }
  
  render(){
    //Need scaling; some levels change player's apparent size
    gameCanvas.context2D.drawImageScaled(avatar, posX, posY, width, height);
  }
}