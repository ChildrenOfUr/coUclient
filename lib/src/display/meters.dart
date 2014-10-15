part of couclient;


class MeterManager {
  int energy = 100;
  int maxenergy = 100;
  int mood = 100;
  int maxmood = 100;

  // Recieve events
  MeterManager() {
    // remove placeholders
    updateMoodDisplay();
    updateEnergyDisplay();
    updateCurrantsDisplay(0);
    updateImgDisplay(0);


    COMMANDS
        ..['mood'] = (String mood) {
          updateMoodDisplay(int.parse(mood));
        }
        ..['energy'] = (String energy) {
          updateEnergyDisplay(int.parse(energy));
        }
        ..['maxmood'] = (String mood) {
          updateMoodDisplay(null, int.parse(mood));
        }
        ..['maxenergy'] = (String energy) {
          updateEnergyDisplay(null, int.parse(energy));
        }
        ..['currants'] = (String currants) {
          updateCurrantsDisplay(int.parse(currants));
        }
        ..['img'] = (String img) {
          updateImgDisplay(int.parse(img));
        };

  }
  updateImgDisplay(int newImg) {
    // Update img display
    if (commaFormatter.format(newImg) != ui.imgElement.text) ui.imgElement.text = commaFormatter.format(newImg);
  }

  updateEnergyDisplay([int newEnergy, newMaxEnergy]) {
    // See if either of the vars needs to change
    if (newEnergy == null) newEnergy = energy; else energy = newEnergy;
    if (newMaxEnergy == null) newMaxEnergy = maxenergy; else maxenergy = newMaxEnergy;

    // Update energy elements
    if (maxenergy <= 0) {
      maxenergy = 1;
    }
    if (ui.currEnergyText.text != newEnergy.toString()) ui.currEnergyText.text = newEnergy.toString();
    if (ui.maxEnergyText.text != maxenergy.toString()) ui.maxEnergyText.text = maxenergy.toString();
    String angle = ((120 - (newEnergy / maxenergy) * 120).toInt()).toString();
    ui.energymeterImage.style.transform = 'rotate(' + angle + 'deg)';
    ui.energymeterImageLow.style.transform = 'rotate(' + angle + 'deg)';
    ui.energymeterImageLow.style.opacity = ((1 - (newEnergy / maxenergy))).toString();
  }

  updateMoodDisplay([int newMood, int newMaxMood]) {
    // See if either of the vars needs to change
    if (newMood == null) newMood = mood; else mood = newMood;
    if (newMaxMood == null) newMaxMood = maxmood; else maxmood = newMaxMood;

    // Update mood elements
    if (newMaxMood <= 0) {
      newMaxMood = 1;
    }
    if (newMood.toString() != ui.currMoodText.text || newMaxMood.toString() != ui.maxMoodText.text) {
      ui.currMoodText.text = newMood.toString();
      ui.maxMoodText.text = newMaxMood.toString();
      ui.moodPercent.text = ((100 * ((newMood / newMaxMood))).toInt()).toString();
      ui.moodmeterImageLow.style.opacity = ((0.7 - (newMood / newMaxMood))).toString();
      if (newMood <= 0) ui.moodmeterImageEmpty.style.opacity = 1.toString(); else ui.moodmeterImageEmpty.style.opacity = 0.toString();
    }
  }

  updateCurrantsDisplay(int newCurrants) {
    // Update currant display
    if (commaFormatter.format(newCurrants) != ui.currantElement.text) ui.currantElement.text = commaFormatter.format(newCurrants);
  }
}
