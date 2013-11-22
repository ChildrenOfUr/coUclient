part of coUclient;

// TODO: When the mirrors api becomes rockin' stable we'll rewrite this file to be more efficient.
// OOOOH maybe streams, I love me a good stream!
// Also, perhaps we can turn this into a library, no sense cluttering up our gamey sorce with this stuff. 
// We'll make a nice interface.

UserInterface ui = new UserInterface();

class UserInterface {
  // Name Meter Variables
  DivElement nameMeter = querySelector('#PlayerName');
  
  // Currant Meter Variables
  SpanElement currantMeter = querySelector('#CurrCurrants');
  
  // Energy Meter Variables
  Element _energymeterImage = querySelector('#EnergyIndicator');
  Element _energymeterImageLow = querySelector('#EnergyIndicatorRed');
  Element _currEnergyText = querySelector('#CurrEnergy');
  Element _maxEnergyText = querySelector('#MaxEnergy');
  int _energy = 100;
  int _maxenergy = 100;
  int _emptyAngle = 10;
  int _angleRange = 120;// Do not change!
  
  // Mood Meter Variables
  Element _moodmeterImageLow =  querySelector('#MoodCircleRed');
  Element _moodmeterImageEmpty = querySelector('#MoodCircleEmpty');
  int _mood = 100;
  int _maxmood = 100;
  Element _currMoodText = querySelector('#CurrMood');
  Element _maxMoodText = querySelector('#MaxMood');
  Element _moodPercent = querySelector('#MoodPercent');
  

  UserInterface(){
    _maxEnergyText.innerHtml = _maxenergy.toString();}
  
  init(){
    //Set up the Currant Display
    setCurrants('0');
    
    // Add all the user interface commands
    Commands
    ..add(['setenergy','"setenergy <value>" Changes the energy meter',setEnergy])
    ..add(['setmaxenergy','"setmaxenergy <value>" Changes the energy meters max value',setMaxEnergy])
    
    ..add(['setmood','"setmood <value>" Changes the mood meter',setMood])
    ..add(['setmaxmood','"setmaxmood <value>" Changes the mood meters max value',setMaxMood])
    
    ..add(['setcurrants','"setcurrants <value>" Changes the currant meters value',setCurrants])
    
    ..add(['setname','"setname <value>" Changes the players displayed name',setName]);
    
    
    // This should actually pull from an online source..
    setEnergy('100');
    setMaxEnergy('100');
    setMood('100');
    setMaxMood('100');
    
  }
  
  _setEnergy(int newValue){
    _energy = newValue;
    _currEnergyText.parent.parent.classes.toggle('changed',true);
    Timer t = new Timer(new Duration(seconds:1),() => _currEnergyText.parent.parent.classes.toggle('changed'));
    _currEnergyText.text=_energy.toString();
    String angle = ((_angleRange - (_energy/_maxenergy)*_angleRange).toInt()).toString();
    _energymeterImage.style.transform = 'rotate(' +angle+ 'deg)';
    _energymeterImageLow.style.transform = 'rotate(' +angle+ 'deg)';
    _energymeterImageLow.style.opacity = ((1-(_energy/_maxenergy))).toString();    
  }
 
  _setMood(int newValue){
    _mood = newValue;
    _currMoodText.parent.classes.toggle('changed', true);
    Timer t = new Timer(new Duration(seconds:1),() => _currMoodText.parent.classes.toggle('changed'));
    _currMoodText.text=_mood.toString();
    _moodPercent.text=((100*((_mood/_maxmood))).toInt()).toString();
    _moodmeterImageLow.style.opacity = ((0.7-(_mood/_maxmood))).toString();
    if (_mood <= 0)
      _moodmeterImageEmpty.style.opacity = 1.toString();
    else
      _moodmeterImageEmpty.style.opacity = 0.toString();
  }

  _setCurrants(int newValue){
    currantMeter.text = newValue.toString();    
    //TODO: write a little bit of code to add commas into our currant string.
  }
  
  _setName(String newValue){
    if (newValue.length >= 17)
      newValue = newValue.substring(0, 15) + '...';
    nameMeter.text = newValue;
  }
  
}


// Console commands to manipulate Meters
// Energy Meter
setEnergy(String value){
  int intvalue = int.parse(value,onError:null);
  if (intvalue != null){
  ui._setEnergy(intvalue);
  printConsole('Setting energy value to $value');}
}
setMaxEnergy(String value){
  int intvalue = int.parse(value,onError:null);
  if (intvalue != null){
  ui._maxenergy = intvalue;
  ui._setEnergy(ui._maxenergy);
  ui._maxEnergyText.text = value;
  printConsole('Setting the maximum energy value to $value');}
}


// Mood Meter
setMood(String value){
  int intvalue = int.parse(value,onError:null);
  if (intvalue != null){
    ui._setMood(intvalue);
  printConsole('Setting mood value to $value');}
}
setMaxMood(String value){
  int intvalue = int.parse(value,onError:null);
  if (intvalue != null){
  ui._mood = intvalue;
  ui._setMood(ui._mood);
  ui._maxMoodText.text = value;
  printConsole('Setting the maximum mood value to $value');}
}

// Currants Meter
setCurrants(String value){
  // Force an int
  int intvalue = int.parse(value,onError:null);
  if (intvalue != null){
  ui._setCurrants(intvalue);
  printConsole('Setting currants to $value');}  
}

// Name Meter
setName(String value){
  ui._setName(value);
  printConsole('Setting name to "$value"');  
}


// Manages the elements that display the date and time.
refreshClock(){
  List data = getDate();
  querySelector('#CurrDay').innerHtml = data[3].toString();
  querySelector('#CurrTime').innerHtml = data[4].toString();
  querySelector('#CurrDate').innerHtml = data[2].toString() + ' of ' + data[1].toString();
}