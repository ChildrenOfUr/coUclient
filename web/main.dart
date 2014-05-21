import 'dart:html';
import 'dart:async';

import 'package:glitchTime/glitch-time.dart';// The script that spits out time!

main() {
  display
    ..init()
    ..name = 'Paul'
    ..img = 100
    ..currants = 100
    ..energy = 10
    ..maxenergy = 100
    ..mood = 10
    ..maxmood = 100;
    gameLoop(lastTime);
}
// Declare our game_loop
double lastTime = 0.0;
gameLoop(num delta)
{
  double dt = (delta-lastTime)/1000;
  display.update();
  lastTime = delta;
  window.animationFrame.then(gameLoop);
}


// Strictly for changing appearance

UserInterface display = new UserInterface();
class UserInterface {
  
  //NumberFormat for having commas in the currants and iMG displays
  //NumberFormat commaFormatter = new NumberFormat("#,###");
  
  // If you need to change an element somewhere else, put the declaration in this class.
  // You can then access it with 'ui.yourElement'. This way we keep everything in one spot
  /////////////////////ELEMENTS//////////////////////////////////////////////
  // you won! element
  Element youWon = querySelector('#youWon');

  // Initial play button
  Element playButton = querySelector('#playButton');
  
  // Initial loading screen elements
  Element loadStatus = querySelector("#loading #loadstatus"); //done
  Element loadStatus2 = querySelector("#loading #loadstatus2"); //done
  Element loadingScreen = querySelector('#loading'); //done
  
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
  /////////////////////ELEMENTS//////////////////////////////////////////////
  
  
  // Declare/Set initial variables here
  /////////////////////VARS//////////////////////////////////////////////////
  String name;
  
  int energy = 0;
  int maxenergy = 100;  
  
  int mood = 100;
  int maxmood = 100;
  
  int currants = 0;  
  
  int img = 0;
  /////////////////////VARS//////////////////////////////////////////////////
  
  // start listening for events
  init(){
    window.onBeforeUnload.listen((_) {
      youWon.hidden = false;
    });
    
    playButton.onClick.listen((_) {
      loadingScreen.style.opacity = '0';
      new Timer(new Duration(seconds:1),() => loadingScreen.remove());
      playButton.remove();
    });
  }

  // update the userinterface
  update(){
    // Update Clock
    List data = getDate();
    
    if (data[4] != currTime.text) {
      currDay.text = data[3].toString();
      currTime.text = data[4];
      currDate.text = data[2].toString() + ' of ' + data[1].toString();
    }

    // Update img display
    if (img.toString() != imgMeter.text)
    imgMeter.text = img.toString();//commaFormatter.format(img);
    
    
    // Update currant display
    if (currants.toString() != currantMeter.text)
    currantMeter.text = currants.toString();//commaFormatter.format(currants);
    
    // Update mood elements
    if(maxmood <= 0) {
      maxmood = 1;   }
    if (mood.toString() != currMoodText.text || maxmood.toString() != maxMoodText.text) {
      currMoodText.text=mood.toString();
      maxMoodText.text=maxmood.toString();
      moodPercent.text=((100*((mood/maxmood))).toInt()).toString();
      moodmeterImageLow.style.opacity = ((0.7-(mood/maxmood))).toString();
      if (mood <= 0)
        moodmeterImageEmpty.style.opacity = 1.toString();
      else
        moodmeterImageEmpty.style.opacity = 0.toString();
    }

    // Update name display  
    if (name.length >= 17)
        name = name.substring(0, 15) + '...';
    if (name != nameMeter.text)
      nameMeter.text = name;
    
   
    // Update energy elements
    if(maxenergy <= 0) {
      maxenergy = 1;   }
    if (currEnergyText.text != energy.toString())
    currEnergyText.text = energy.toString();
    if (maxEnergyText.text != maxenergy.toString())
    maxEnergyText.text = maxenergy.toString();
    String angle = ( (120 - (energy/maxenergy)*120).toInt() ).toString();
    energymeterImage.style.transform = 'rotate(' +angle+ 'deg)';
    energymeterImageLow.style.transform = 'rotate(' +angle+ 'deg)';
    energymeterImageLow.style.opacity = ((1-(energy/maxenergy))).toString();
  }

  setSong(){}
  
}














