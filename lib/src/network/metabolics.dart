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
  int _energy = 100;
  int _maxenergy = 100;
  int _mood = 100;
  int _maxmood = 100;
  int _img = 0;
  int _emptyAngle = 10;
  int _angleRange = 120;// Do not change!

  void init() {
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
    if (newValue > _maxenergy) return;

    _energy = newValue;
    ui.currEnergyText.parent.parent.classes.toggle('changed', true);
    Timer t = new Timer(new Duration(seconds: 1), () => ui.currEnergyText.parent.parent.classes.toggle('changed'));
    ui.currEnergyText.text = _energy.toString();
    String angle = ((_angleRange - (_energy / _maxenergy) * _angleRange).toInt()).toString();
    ui.energymeterImage.style.transform = 'rotate(' + angle + 'deg)';
    ui.energymeterImageLow.style.transform = 'rotate(' + angle + 'deg)';
    ui.energymeterImageLow.style.opacity = ((1 - (_energy / _maxenergy))).toString();
  }

  setMood(int newValue) {
    if (newValue > _maxmood) return;
    _mood = newValue;

    new Message(#moodDisplayEvent, {
      'mood': _mood
    });

    if (_mood <= 0) ui.moodmeterImageEmpty.style.opacity = 1.toString(); else ui.moodmeterImageEmpty.style.opacity = 0.toString();
  }

  setCurrants(int newValue) {
    _currants = newValue;
    localStorage["currants"] = newValue.toString();
    ui.currantElement.text = commaFormatter.format(newValue);
  }

  setImg(int newValue) {
    _img = newValue;
    ui.imgElement.text = commaFormatter.format(newValue);
  }

  int getCurrants() {
    return _currants;
  }

  int getEnergy() {
    return _energy;
  }

  int getMood() {
    return _mood;
  }

  int getImg() {
    return _img;
  }
}
