part of coUclient;



startResizeListener() {
  resize();
    window.onResize.listen((_) => resize());
}

resize(){
  Element chatPane = querySelector('#ChatPane');
  Element gameScreen = querySelector('#GameScreen');
  
  int width = window.innerWidth - 80 - 40 - chatPane.clientWidth;
  int height = window.innerHeight - 180;
  
  
  chatPane.style.right;
  chatPane.clientWidth;
  
  gameScreen.style.width = width.toString()+'px';
  gameScreen.style.height = height.toString()+'px';
  
  chatPane.style.height = (height + 50).toString()+'px';
  
  for (Element child in gameScreen.children)
  {
    child.style.width = gameScreen.style.width;
    child.style.height = gameScreen.style.height;
  }
   
  
  
  
  
  //TODO When the window becomes too small, we should spawn an overlay that tells the user this fact.
}

