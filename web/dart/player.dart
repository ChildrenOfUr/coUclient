part of coUclient;

Player mysteryman;

class Player{
  
  int posX;
  int posY;
  
  int width;
  int height;
  
  ImageElement avatar;
  
  Player(){
    avatar = new ImageElement(src: "assets/sprites/avatar.png");
    //TODO: Remove hard-coded values used for testing
    posX = 0;
    posY = 400;
    width = 100;
    height = 172;
    
    mysteryman = this;
  }
  
  update(){
    if (playerInput.rightKey == true)
      posX += 5;
    if (playerInput.leftKey == true)
      posX -= 5;
    //primitive jumping
    if (playerInput.spaceKey == true)
      posY -= 10;
    //needs acceleration, some gravity const somewhere
    if (posY < 400)
      posY += 3;
    mysteryman = this;
  }
  
  render(){
    //Need scaling; some levels change player's apparent size
    middleCanvas.context2D.drawImageScaled(avatar, posX, posY, width, height);
  }
}