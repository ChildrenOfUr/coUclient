part of couclient;

class Meters {
  Element nameElement = querySelector('#playerName');

  Element energymeterImage = querySelector('#energyDisks .green');
  Element energymeterImageLow = querySelector('#energyDisks .red');

  Element currEnergyText = querySelector('#currEnergy');
  Element maxEnergyText = querySelector('#maxEnergy');

  Element moodmeterImageLow = querySelector('#leftDisk .hurt');
  Element moodmeterImageEmpty = querySelector('#leftDisk .dead');

  Element currMoodText = querySelector('#moodMeter .fraction .curr');
  Element maxMoodText = querySelector('#moodMeter .fraction .max');
  Element moodPercent = querySelector('#moodMeter .percent .number');

  Element currantElement = querySelector('#currCurrants');

  Element imgElement = querySelector('#currImagination');


  updateImgDisplay() {
    imgElement.text = commaFormatter.format(metabolics.getImg());
  }

  updateEnergyDisplay() {
    // Update energy elements
    currEnergyText.text = metabolics.getEnergy().toString();
    maxEnergyText.text = metabolics.getMaxEnergy().toString();
    String angle = ((120 - (metabolics.getEnergy() / metabolics.getMaxEnergy()) * 120).toInt()).toString();
    energymeterImage.style.transform = 'rotate(' + angle + 'deg)';
    energymeterImageLow.style.transform = 'rotate(' + angle + 'deg)';
    energymeterImageLow.style.opacity = ((1 - (metabolics.getEnergy() / metabolics.getMaxEnergy()))).toString();
  }

  updateMoodDisplay() {
    currMoodText.text = metabolics.getMood().toString();
    maxMoodText.text = metabolics.getMaxMood().toString();
    moodPercent.text = ((100 * ((metabolics.getMood() / metabolics.getMaxMood()))).toInt()).toString();
    moodmeterImageLow.style.opacity = ((0.7 - (metabolics.getMood() / metabolics.getMaxMood()))).toString();
    if (metabolics.getMood() <= 0) moodmeterImageEmpty.style.opacity = 1.toString(); else moodmeterImageEmpty.style.opacity = 0.toString();
  }

  updateCurrantsDisplay() {
    currantElement.text = commaFormatter.format(metabolics.getCurrants());
  }

  updateNameDisplay() {
    if (game.username.length >= 17)
      nameElement.text = game.username.substring(0, 15) + '...';
    else
      nameElement.text = game.username;
  }

  updateAll() {
    updateCurrantsDisplay();
    updateEnergyDisplay();
    updateImgDisplay();
    updateMoodDisplay();
  }

}
