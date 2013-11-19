part of coUclient;


startResizeListener() {
  int width = window.innerWidth - 80;
  int height = window.innerHeight - 180;
  querySelector('#GameScreen').style.width = width.toString()+'px';
  querySelector('#GameScreen').style.height = height.toString()+'px';
    window.onResize.listen((_){
    int width = window.innerWidth - 80;
    int height = window.innerHeight - 180;
    querySelector('#GameScreen').style.width = width.toString()+'px';
    querySelector('#GameScreen').style.height = height.toString()+'px';
    
    //TODO When the window becomes too small, we should spawn an overlay that tells the user this fact.
    
    
    });
}

