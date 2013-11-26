part of coUclient;



List Layers = new List();
List gra = ['5FA3D4','FFC252'];
List dem = [4440,960];



// This will create the 'working' canvases that the main few will pull from.
prepStage() {
  
  CanvasElement gradient = querySelector('#gradient');
  
  
  var grd = gradient.context2D.createLinearGradient(0,0,960,4440);
  grd.addColorStop(0,gra[0]);
  grd.addColorStop(1,gra[1]);

  gradient.context2D.fillStyle=grd;
  gradient.context2D.fillRect(0,0,int.parse(gradient.style.width.replaceAll('px','')),int.parse(gradient.style.height.replaceAll('px','')));
  
  
}



