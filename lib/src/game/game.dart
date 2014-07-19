part of couclient;

// GAME ENTRY AND MANAGEMENT //
class Game extends Pump {
  
  String username = 'null';
  String location = 'null';

  int energy = 100;
  int maxenergy = 100;
  int mood = 100;
  int maxmood = 100;
  int currants = 0;
  int img = 0;
  
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


// we can extend something like this to handle player/npc updates.
class Entity {
  update(num dt){}
}