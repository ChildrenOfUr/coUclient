part of couclient;

class Meters {  
  Element meter = querySelector('ur-meters');
  Element currantElement = querySelector('#currCurrants');

  updateImgDisplay() {
    meter.attributes['imagination'] = commaFormatter.format(metabolics.getImg());
  }

  updateEnergyDisplay() {
    meter.attributes['energy'] = metabolics.getEnergy().toString();
    meter.attributes['maxenergy'] = metabolics.getMaxEnergy().toString();
  }

  updateMoodDisplay() {
    meter.attributes['mood'] = metabolics.getMood().toString();
    meter.attributes['maxmood'] = metabolics.getMaxMood().toString();
  }

  updateCurrantsDisplay() {
    currantElement.text = commaFormatter.format(metabolics.getCurrants());
  }

  updateNameDisplay() {
    meter.attributes['playername'] = game.username;
  }

  updateAll() {
    updateCurrantsDisplay();
    updateEnergyDisplay();
    updateImgDisplay();
    updateMoodDisplay();
  }

}
