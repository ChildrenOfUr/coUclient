part of couclient;

StreetService streetService = new StreetService();
// GAME ENTRY AND MANAGEMENT //
class Game {

  String username = sessionStorage['playerName'];
  String location = sessionStorage['playerStreet'];

  int energy = 100;
  int maxenergy = 100;
  int mood = 100;
  int maxmood = 100;
  int currants = 0;
  int img = 0;


  // INITIALIZATION //
  Game() {
    streetService.requestStreet(location)
    .then((_) {

    // Networking
    new NetChatManager();
    new Message(#startChat, 'Global Chat');
    new Message(#startChat, 'Local Chat');
    
    windowManager.motdWindow.open();
    
    metabolics.init();
    multiplayerInit();
    CurrentPlayer = new Player(username);
    view.meters.updateNameDisplay();
    audio.setSong('highlands');

    CurrentPlayer.loadAnimations().then((_) {
      CurrentPlayer.currentAnimation = CurrentPlayer.animations['idle'];
    }).then((_) => loop(0.0));

    });

  }

  // GAME LOOP //
  double lastTime = 0.0;
  DateTime startTime = new DateTime.now();

  loop(num delta) {
    double dt = (delta - lastTime) / 1000;
    lastTime = delta;

    update(dt);
    render();
    window.animationFrame.then(loop);
  }
}
