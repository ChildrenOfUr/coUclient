part of couclient;

class Meters {
  NumberFormat commaFormatter = new NumberFormat("#,###");

  updateImgDisplay() {
    view.imgElement.text = commaFormatter.format(metabolics.getImg());
  }

  updateEnergyDisplay() {
    // Update energy elements
    view.currEnergyText.text = metabolics.getEnergy().toString();
    view.maxEnergyText.text = metabolics.getMaxEnergy().toString();
    String angle = ((120 - (metabolics.getEnergy() / metabolics.getMaxEnergy()) * 120).toInt()).toString();
    view.energymeterImage.style.transform = 'rotate(' + angle + 'deg)';
    view.energymeterImageLow.style.transform = 'rotate(' + angle + 'deg)';
    view.energymeterImageLow.style.opacity = ((1 - (metabolics.getEnergy() / metabolics.getMaxEnergy()))).toString();
  }

  updateMoodDisplay() {
    view.currMoodText.text = metabolics.getMood().toString();
    view.maxMoodText.text = metabolics.getMaxMood().toString();
    view.moodPercent.text = ((100 * ((metabolics.getMood() / metabolics.getMaxMood()))).toInt()).toString();
    view.moodmeterImageLow.style.opacity = ((0.7 - (metabolics.getMood() / metabolics.getMaxMood()))).toString();
    if (metabolics.getMood() <= 0) view.moodmeterImageEmpty.style.opacity = 1.toString(); else view.moodmeterImageEmpty.style.opacity = 0.toString();
  }

  updateCurrantsDisplay() {
    view.currantElement.text = commaFormatter.format(metabolics.getCurrants());
  }
  
  updateAll() {
    updateCurrantsDisplay();
    updateEnergyDisplay();
    updateImgDisplay();
    updateMoodDisplay();
  }

}
