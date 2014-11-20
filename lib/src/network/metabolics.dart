part of couclient;

/**
 *
 * This class will be responsible for querying the database and writing back to it
 * with the details of the player (currants, mood, etc.)
 *
**/

Metabolics metabolics = new Metabolics();

class Metabolics {
  int _currants = 0;
  int _energy = 50;
  int _maxenergy = 100;
  int _mood = 50;
  int _maxmood = 100;
  int _img = 0;

  void init() {
    view.meters.updateAll();

    //load currants (for now)
    if (localStorage["currants"] != null) setCurrants(int.parse(localStorage["currants"]));
  }

  /*//will return a future containing the result of the action
	Future<int> get(String metabolic)
	{
		Completer c = new Completer();
		new Timer(new Duration(milliseconds:100), () => c.complete(1337));
		return c.future;
	}

	//will return a future describing the success of the action
	Future<bool> set(String metabolic, dynamic newValue)
	{
		Completer c = new Completer();
		new Timer(new Duration(milliseconds:100), () => c.complete(true));
		return c.future;
	}*/

  setEnergy(int newValue) {
    if (newValue <= 0)
      newValue = 0;
    if (newValue > _maxenergy) return;
    _energy = newValue;
    view.meters.updateEnergyDisplay();
  }

  setMaxEnergy(int newValue) {
    if (newValue <= 0)
      newValue = 0;
    _maxenergy = newValue;
    if (_energy > _maxenergy)
    _energy = _maxenergy;
    view.meters.updateEnergyDisplay();
  }

  setMood(int newValue) {
    if (newValue <= 0)
      newValue = 0;
    if (newValue > _maxmood) return;
    _mood = newValue;
    view.meters.updateMoodDisplay();
  }

  setMaxMood(int newValue) {
    if (newValue <= 0)
      newValue = 0;
    _maxmood = newValue;
    if (_mood > _maxmood)
    _mood = newValue;
    view.meters.updateMoodDisplay();
  }

  setCurrants(int newValue) {
    if (newValue <= 0)
      newValue = 0;
    _currants = newValue;
    localStorage["currants"] = newValue.toString();
    view.meters.updateCurrantsDisplay();
  }

  setImg(int newValue) {
    if (newValue <= 0)
      newValue = 0;
    _img = newValue;
    view.meters.updateImgDisplay();
  }

  int getCurrants() {
    return _currants;
  }

  int getEnergy() {
    return _energy;
  }
  int getMaxEnergy() {
    return _maxenergy;
  }

  int getMood() {
    return _mood;
  }
  int getMaxMood() {
    return _maxmood;
  }

  int getImg() {
    return _img;
  }
}
