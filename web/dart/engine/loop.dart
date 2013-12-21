part of coUclient;

// Our gameloop
loop() {
  if (CurrentCamera is Camera)
    CurrentCamera.update();

  //Update Player (positon, input)
  if (CurrentPlayer is Player)
    CurrentPlayer.update();
  
}

