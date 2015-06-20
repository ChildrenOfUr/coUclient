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
        String imageUrl = spritesheets['base'];
        avatarDisplay.style.backgroundImage = 'url(' + imageUrl + ')';

        ImageElement portrait = new ImageElement();
        portrait.src = imageUrl;
        int nWidth = portrait.naturalWidth;

        // TODO: improve this sizing method
        if (nWidth < 1500) {
          avatarDisplay.style.backgroundSize = '1050px';
          avatarDisplay.style.backgroundPositionX = '0';
        } else if (nWidth >= 1500 && nWidth < 2000) {
          avatarDisplay.style.backgroundSize = '1500px';
          avatarDisplay.style.backgroundPositionX = '-10px';
        } else if (nWidth >= 2000 && nWidth < 3000) {
          avatarDisplay.style.backgroundSize = '2000px';
          avatarDisplay.style.backgroundPositionX = '-25px';
          avatarDisplay.style.backgroundPositionY = '-5px';
        }
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