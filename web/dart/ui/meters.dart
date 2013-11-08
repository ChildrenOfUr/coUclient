part of coUclient;


// Define each meter
RotatingMeter energyMeter;
SpanElement currantMeter = query('#CurrCurrants');

// Start each meter,
initializeMeters(){
  //Set up the energy Meter
    energyMeter = new RotatingMeter(query('#EnergyIndicator'),
        query('#EnergyIndicatorRed'),
        query('#CurrEnergy'),
        query('#MaxEnergy'),120,1000);
    energyMeter.setValue(1000);
    Commands
    ..add(['setEnergy','"setEnergy <value>" Changes the energy meter',setEnergy])
    ..add(['setMaxEnergy','"setMaxEnergy <value>" Changes the energy meters max value',setMaxEnergy]);

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
  query('#CurrDay').innerHtml = data[3].toString();
  query('#CurrTime').innerHtml = data[4].toString();
  query('#CurrDate').innerHtml = data[2].toString() + ' of ' + data[1].toString();
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
    currMeterText.parent.classes.toggle('changed');
    Timer t = new Timer(new Duration(seconds:1),() => currMeterText.parent.classes.toggle('changed'));
       
    currMeterText.text=currValue.toString();
    String angle = ((angleRange - (currValue/maxValue)*angleRange).toInt()).toString();
    meterImage.style.transform = 'rotate(' +angle+ 'deg)';
    meterImageLow.style.transform = 'rotate(' +angle+ 'deg)';
    meterImageLow.style.opacity = ((1-(currValue/maxValue))).toString();
  }
}


