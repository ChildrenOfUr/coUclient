part of couclient;

UserInterface display = new UserInterface();
class UserInterface {
  
  //NumberFormat for having commas in the currants and iMG displays
  NumberFormat commaFormatter = new NumberFormat("#,###");
  
  Storage session = window.sessionStorage;
  
  // If you need to change an element somewhere else, put the declaration in this class.
  // You can then access it with 'ui.yourElement'. This way we keep everything in one spot
  /////////////////////ELEMENTS//////////////////////////////////////////////
  // you won! element
  Element youWon = querySelector('#youWon');

  // Initial play button
  Element playButton = querySelector('#playButton');
  
  // Initial loading screen elements
  Element loadStatus = querySelector("#loading #loadstatus");
  Element loadStatus2 = querySelector("#loading #loadstatus2");
  Element loadingScreen = querySelector('#loading'); 
  
  // Name Meter Variables
  Element nameElement = querySelector('#playerName'); 

  // Time Meter Variables
  Element currDay = querySelector('#currDay'); 
  Element currTime = querySelector('#currTime'); 
  Element currDate = querySelector('#currDate'); 

  // Location and Map elements
  Element currLocation = querySelector('#currLocation'); 
  Element mapButton = querySelector('#mapButton');
  
  // Currant Meter Variables
  Element currantElement = querySelector('#currCurrants'); 

  // Img Meter Variables
  Element imgElement = querySelector('#currImagination');

  // Music Meter Variables
  Element titleElement = querySelector('#trackTitle'); 
  Element artistElement = querySelector('#trackArtist'); 
  AnchorElement SClinkElement = querySelector('#SCLink'); 
  Element volumeGlyph = querySelector('#volumeGlyph');
  InputElement volumeSlider = querySelector('#volumeSlider *');
  

  // Energy Meter Variables
  Element energymeterImage = querySelector('#energyDisks .green'); 
  Element energymeterImageLow = querySelector('#energyDisks .red'); 
  Element currEnergyText = querySelector('#currEnergy'); 
  Element maxEnergyText = querySelector('#maxEnergy'); 

  // Mood Meter Variables
  Element moodmeterImageLow =  querySelector('#leftDisk .hurt'); 
  Element moodmeterImageEmpty = querySelector('#leftDisk .dead'); 
  Element currMoodText = querySelector('#moodMeter .fraction .curr'); 
  Element maxMoodText = querySelector('#moodMeter .fraction .max'); 
  Element moodPercent = querySelector('#moodMeter .percent .number'); 
  /////////////////////ELEMENTS//////////////////////////////////////////////
  
  
  // Declare/Set initial variables here
  /////////////////////VARS//////////////////////////////////////////////////
  String name = 'null';
  
  String location = 'null';
  
  int energy = 100;
  int maxenergy = 100;  
  
  int mood = 100;
  int maxmood = 100;
  
  int currants = 0;  
  
  int img = 0;
  
  bool muted = false;
  int volume = 0;
  String SCsong = '-';
  String SCartist = '-';
  String SClink = '';
  
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
    
    session['volume'] = '10'; // initial value
    volumeGlyph.onClick.listen((_) {
      if (muted == true) {
        volume = int.parse(session['volume']);
        muted = false;
        volumeSlider.value = volume.toString();
      }
      else if (muted == false) {
        session['volume'] = volume.toString();
        muted = true;
        volumeSlider.value = '0';
      }
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
    if (commaFormatter.format(img) != imgElement.text)
    imgElement.text = commaFormatter.format(img);
    
    
    // Update currant display
    if (commaFormatter.format(currants) != currantElement.text)
    currantElement.text = commaFormatter.format(currants);
    
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
    if (name != nameElement.text)
      nameElement.text = name;
    
   
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
    
    // Update the location text
    if (location.length >= 20)
            location = location.substring(0, 17) + '...';
    if (location != currLocation.text)
          currLocation.text = location;
    
    
    // Update the audio icon
    if (muted == true && volumeGlyph.classes.contains('fa-volume-up')) {
      volumeGlyph.classes
        ..remove('fa-volume-up')
        ..add('fa-volume-off');
    }
    if (muted == false && volumeGlyph.classes.contains('fa-volume-off')) {
      volumeGlyph.classes
        ..remove('fa-volume-off')
        ..add('fa-volume-up');
    }
    
    // Update the volume slider
    if (int.parse(volumeSlider.value) == 0)
      muted = true;
    else
      muted = false;
    if (volume != int.parse(volumeSlider.value))
      volume = int.parse(volumeSlider.value);
    
    // Update the soundcloud widget
    if (SCsong != titleElement.text)
    titleElement.text = SCsong;
    if (SCartist != artistElement.text)
    artistElement.text = SCartist;   
    if (SClink != SClinkElement.href)
      SClinkElement.href = SClink;
        
    
    
    
    
  }

  
}