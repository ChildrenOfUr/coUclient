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


  // INITIALIZATION //
  Game() {
    // init stuff here
	  load_streets()
	  	.then((_) => new Street('test').load()
	  	.then((_)
		{
		  	metabolics.init();
		  	multiplayerInit();
			CurrentPlayer = new Player();

			CurrentPlayer.loadAnimations()
			.then((_)
			{
				CurrentPlayer.currentAnimation = CurrentPlayer.animations['idle'];
			})
			.then((_) => loop(0.0));
		}));
  }

  // GAME LOOP //
  double lastTime = 0.0;
  DateTime startTime = new DateTime.now();

  loop(num delta) {
    double dt = (delta-lastTime)/1000;
    lastTime = delta;

    update(dt);
    render();
    window.animationFrame.then(loop);
  }
}