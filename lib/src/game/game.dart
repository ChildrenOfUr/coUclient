part of couclient;

// GAME ENTRY AND MANAGEMENT //
class Game extends Pump {
  
  
  // VARS //  
  List <Entity> _entities = [];
  
  
  // INITIALIZATION //
  Game() {
    // init stuff here
  }  
  
  
  // GAME LOOP //
  double lastTime = 0.0;
  DateTime startTime = new DateTime.now();
  loop(num delta) {
    double dt = (delta-lastTime)/1000;
    lastTime = delta;
    for (Entity entity in _entities)
      entity.update(dt);
    window.animationFrame.then(loop);
  }  
}



class Entity {
  update(num dt){}
}