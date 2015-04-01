part of couclient;

StreetService streetService = new StreetService();
// GAME ENTRY AND MANAGEMENT //
class Game {

  String username = sessionStorage['playerName'];
  String location = sessionStorage['playerStreet'];
  String email = sessionStorage['playerEmail'];

  // INITIALIZATION //
  Game(Metabolics m) {
    streetService.requestStreet(location)
    .then((_) {

    // Networking
    new NetChatManager();
    new Message(#startChat, 'Global Chat');
    new Message(#startChat, 'Local Chat');

    windowManager.motdWindow.open();

    metabolics.init(m);
    multiplayerInit();
    CurrentPlayer = new Player(username);
    view.meters.updateNameDisplay();

    //stop the loading music
    audio.stopSound(audio.currentAudioInstance);

    //play appropriate song for street (or just highlands for now)
    audio.setSong('highlands');

    CurrentPlayer.loadAnimations().then((_) {
      CurrentPlayer.currentAnimation = CurrentPlayer.animations['idle'];
    }).then((_) => loop(0.0));

    });

  }

  // GAME LOOP //
  double lastTime = 0.0;
  DateTime startTime = new DateTime.now();
  bool ignoreGamepads = false;

  loop(num delta) {
    double dt = (delta - lastTime) / 1000;
    lastTime = delta;

    try
    {
    	if(!ignoreGamepads)
    		inputManager.updateGamepad();
    }
    catch(err)
    {
    	ignoreGamepads = true;
    	print('Sorry, this browser does not support the gamepad API');
    }

    update(dt);
    render();
    window.animationFrame.then(loop);
  }
}
