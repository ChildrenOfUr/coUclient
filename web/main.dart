import 'dart:html';

import 'package:glitchTime/glitch-time.dart';// The script that spits out time!

main() {
  display
    ..refreshClock()
    ..setName('Test Player')
    ..setMaxEnergy(100)
    ..setEnergy(100)
    ..setImg(100);
  
  
}








// Strictly for changing appearance
UserInterface display = new UserInterface();
class UserInterface {
  
  //NumberFormat for having commas in the currants and iMG displays
  //NumberFormat commaFormatter = new NumberFormat("#,###");
  
  
  Element youWon = querySelector('youWon');

  // Name Meter Variables
  Element nameMeter = querySelector('#playerName'); //done

  // Time Meter Variables
  Element currDay = querySelector('#currDay'); //done
  Element currTime = querySelector('#currTime'); //done
  Element currDate = querySelector('#currDate'); //done

  // Currant Meter Variables
  Element currantMeter = querySelector('#currCurrants'); //done

// Img Meter Variables
  Element imgMeter = querySelector('#currImagination');

  // Music Meter Variables
  Element titleMeter = querySelector('#trackTitle'); //done
  Element artistMeter = querySelector('#trackArtist'); //done
  AnchorElement scLink = querySelector('#SCLink'); //done

  // Energy Meter Variables
  Element energymeterImage = querySelector('#energyDisks .green'); //done
  Element energymeterImageLow = querySelector('#energyDisks .red'); //done
  Element currEnergyText = querySelector('#currEnergy'); //done
  Element maxEnergyText = querySelector('#maxEnergy'); //done

  // Mood Meter Variables
  Element moodmeterImageLow =  querySelector('#leftDisk .hurt'); //done
  Element moodmeterImageEmpty = querySelector('#leftDisk .dead'); //done
  Element currMoodText = querySelector('#moodMeter .fraction .curr'); //done
  Element maxMoodText = querySelector('#moodMeter .fraction .max'); //done
  Element moodPercent = querySelector('#moodMeter .percent .number'); //done
  
  init(){
    window.onBeforeUnload.listen((_) {
      youWon.hidden = false;
    });
    this.setMaxEnergy(100);
    this.setEnergy(100);
  }

  setName(String name){
    if (name.length >= 17)
        name = name.substring(0, 15) + '...';
      nameMeter.text = name;
  }
  
  setImg(int img){
    imgMeter.text = img.toString();//commaFormatter.format(img);
  }
  
  int _maxenergy = 0;
  int _currenergy = 0;
  setEnergy(int energy){
        _currenergy = energy;
        currEnergyText.text=energy.toString();
        String angle = ((120 - (energy/_maxenergy)*120).toInt()).toString();
        energymeterImage.style.transform = 'rotate(' +angle+ 'deg)';
        energymeterImageLow.style.transform = 'rotate(' +angle+ 'deg)';
        energymeterImageLow.style.opacity = ((1-(energy/_maxenergy))).toString();    
  }
  setMaxEnergy(int energy){
    _maxenergy = energy;
    maxEnergyText.text=energy.toString();
    setEnergy(_currenergy);
  }
  
  setMood(int mood){}
  setMaxMood(int mood){}
  
  setSong(){}
 
  refreshClock() {
    List data = getDate();
    currDay.innerHtml = data[3].toString();
    currTime.innerHtml = data[4].toString();
    currDate.innerHtml = data[2].toString() + ' of ' + data[1].toString();
  }
}














