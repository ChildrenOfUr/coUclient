part of coUclient;


// Define each meter
RotatingMeter energyMeter;
FadingMeter moodMeter;
SpanElement currantMeter = querySelector('#CurrCurrants');

// Start each meter,
initializeMeters(){
  //Set up the energy Meter
    energyMeter = new RotatingMeter(querySelector('#EnergyIndicator'),
        querySelector('#EnergyIndicatorRed'),
        querySelector('#CurrEnergy'),
        querySelector('#MaxEnergy'),120,1000);
    energyMeter.setValue(1000);
    Commands
    ..add(['setEnergy','"setEnergy <value>" Changes the energy meter',setEnergy])
    ..add(['setMaxEnergy','"setMaxEnergy <value>" Changes the energy meters max value',setMaxEnergy]);
    
//Set up the mood Meter
    moodMeter = new FadingMeter(
        querySelector('#MoodCircleRed'),
        querySelector('#MoodCircleEmpty'),        
        querySelector('#CurrMood'),
        querySelector('#MaxMood'),
        querySelector('#MoodPercent')
        ,100);
    moodMeter.setValue(100);
    Commands
    ..add(['setMood','"setMood <value>" Changes the mood meter',setMood])
    ..add(['setMaxMood','"setMaxMood <value>" Changes the mood meters max value',setMaxMood]);

  //Set up the Currant Display
    setCurrants('0');
    Commands
    ..add(['setCurrants','"setCurrants <value>" Changes the current currants',setCurrants]);
}


// Console commands to manipulate Meters
// Energy Meter
setEnergy(String value){
  int intvalue = int.parse(value,onError:null);
  if (intvalue != null){
  energyMeter.setValue(intvalue);
  printConsole('Setting energy value to $value');}
}
setMaxEnergy(String value){
  int intvalue = int.parse(value,onError:null);
  if (intvalue != null){
  energyMeter.maxValue = intvalue;
  energyMeter.setValue(energyMeter.currValue);
  energyMeter.maxMeterText.text = value;
  printConsole('Setting the maximum energy value to $value');}
}

// Mood Meter
setMood(String value){
  int intvalue = int.parse(value,onError:null);
  if (intvalue != null){
  moodMeter.setValue(intvalue);
  printConsole('Setting mood value to $value');}
}
setMaxMood(String value){
  int intvalue = int.parse(value,onError:null);
  if (intvalue != null){
  moodMeter.maxValue = intvalue;
  moodMeter.setValue(moodMeter.currValue);
  moodMeter.maxMeterText.text = value;
  printConsole('Setting the maximum mood value to $value');}
}

setCurrants(String value){
  // Force an int
  int intvalue = int.parse(value,onError:null);
  if (intvalue != null){
  currantMeter.text = intvalue.toString();
  printConsole('Setting currants to $value');}  
}



// Manages the elements that display the date and time.
refreshClock(){
  List data = getDate();
  querySelector('#CurrDay').innerHtml = data[3].toString();
  querySelector('#CurrTime').innerHtml = data[4].toString();
  querySelector('#CurrDate').innerHtml = data[2].toString() + ' of ' + data[1].toString();
}












class FadingMeter {
 Element meterImageLow;
 Element meterImageEmpty;
 int currValue = 0;
 int maxValue;
 Element currMeterText;
 Element maxMeterText;
 Element meterPercent;
 
 FadingMeter(this.meterImageLow,this.meterImageEmpty,this.currMeterText,this.maxMeterText, this.meterPercent, this.maxValue) {
   maxMeterText.innerHtml = maxValue.toString();
 }
 setValue(int newValue)
 {
   currValue = newValue;
   currMeterText.parent.classes.toggle('changed', true);
   Timer t = new Timer(new Duration(seconds:1),() => currMeterText.parent.classes.toggle('changed'));
   currMeterText.text=currValue.toString();
   meterPercent.text=((100*((currValue/maxValue))).toInt()).toString();
   meterImageLow.style.opacity = ((0.7-(currValue/maxValue))).toString();
   if (currValue <= 0)
     meterImageEmpty.style.opacity = 1.toString();
   else
     meterImageEmpty.style.opacity = 0.toString();
 }

}


//Class for handling rotating meters.
class RotatingMeter{
  Element meterImage;
  Element meterImageLow;
  Element currMeterText;
  Element maxMeterText;
  int currValue;
  int maxValue;
  int emptyAngle = 10;
  int angleRange;
  RotatingMeter(this.meterImage,
                this.meterImageLow,
                this.currMeterText,
                this.maxMeterText,
                this.angleRange,
                this.maxValue){
    maxMeterText.innerHtml = maxValue.toString();
  }
  setValue(int newValue)
  {
    currValue = newValue;
    currMeterText.parent.parent.classes.toggle('changed',true);
    Timer t = new Timer(new Duration(seconds:1),() => currMeterText.parent.parent.classes.toggle('changed'));
       
    currMeterText.text=currValue.toString();
    String angle = ((angleRange - (currValue/maxValue)*angleRange).toInt()).toString();
    meterImage.style.transform = 'rotate(' +angle+ 'deg)';
    meterImageLow.style.transform = 'rotate(' +angle+ 'deg)';
    meterImageLow.style.opacity = ((1-(currValue/maxValue))).toString();
  }
}


