part of couclient;

class Meters {
  Element meter = querySelector('ur-meters');
  Element currantElement = querySelector('#currCurrants');
  Element avatarDisplay = querySelector("ur-meters /deep/ #moodAvatar");
  int runCount = 0;

  updateImgDisplay() {
    meter.attributes['imagination'] = metabolics.img.toString();
  }

  updateEnergyDisplay() {
    meter.attributes['energy'] = metabolics.energy.toString();
    meter.attributes['maxenergy'] = metabolics.maxEnergy.toString();
  }

  updateMoodDisplay() {
    meter.attributes['mood'] = metabolics.mood.toString();
    meter.attributes['maxmood'] = metabolics.maxMood.toString();
  }

  updateCurrantsDisplay() {
    currantElement.text = commaFormatter.format(metabolics.currants);
  }

  updateNameDisplay() {
    meter.attributes['playername'] = game.username;
  }

  updateAvatarDisplay() {
    if (runCount == 0 || runCount % 5 == 0) {
      // run on load, and once every 5 refreshes afterward to avoid overloading the server
      HttpRequest.requestCrossOrigin('http://' + Configs.utilServerAddress + '/getSpritesheets?username=' + game.username).then((String response) {
        Map spritesheets = JSON.decode(response);
        avatarDisplay.style.backgroundImage = 'url(' + spritesheets['base'] + ')';
        avatarDisplay.style.backgroundSize = '';
        avatarDisplay.style.backgroundPositionX = '';
        avatarDisplay.style.backgroundPositionY = '';
      });
    }
  }

  updateAll() {
    updateCurrantsDisplay();
    updateEnergyDisplay();
    updateImgDisplay();
    updateMoodDisplay();
    updateAvatarDisplay();
    runCount++;
  }
}
