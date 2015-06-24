library meters;

import 'package:polymer/polymer.dart';
import 'package:intl/intl.dart';
import 'dart:html';
import 'dart:async';
import 'dart:math' show Random;
import 'dart:convert';
import "package:couclient/configs.dart";

@CustomTag('ur-meters')
class Meters extends PolymerElement {
	@published String playername;
	@published int mood, maxmood, energy, maxenergy, imagination;
	@published bool debug;
	int runCount;

	NumberFormat commaFormatter = new NumberFormat("#,###");
	Element greenDisk, redDisk, hurtDisk, deadDisk, avatarDisplay;

	Meters.created() : super.created() {
		runCount = 0;
		avatarDisplay = shadowRoot.querySelector("#moodAvatar");
		greenDisk = shadowRoot.querySelector('#energyDisks .green');
		redDisk = shadowRoot.querySelector('#energyDisks .red');
		hurtDisk = shadowRoot.querySelector('#leftDisk .hurt');
		deadDisk = shadowRoot.querySelector('#leftDisk .dead');

		changes.listen((_) => update());

		if(debug == true) {
			Random r = new Random();
			new Timer.periodic(new Duration(seconds:1), (_) {
				energy = r.nextInt(maxenergy);
				mood = r.nextInt(maxmood);
				imagination = r.nextInt(999999);
			});
		}
	}

	updateAvatarDisplay() {
		if (runCount < 5 || runCount % 5 == 0) {
			// run on load, and once every 5 refreshes afterward to avoid overloading the server
			HttpRequest.requestCrossOrigin('http://' + Configs.utilServerAddress + '/getSpritesheets?username=' + playername).then((String response) {
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

	update() {
		// update energy disk angles and opacities
		greenDisk.style.transform = 'rotate(${120 - (energy / maxenergy) * 120}deg)';
		redDisk.style.transform = 'rotate(${120 - (energy / maxenergy) * 120}deg)';
		redDisk.style.opacity = (1 - energy/maxenergy).toString();
		hurtDisk.style.backfaceVisibility = 'visible';
		hurtDisk.style.opacity = '${0.7 - (mood / maxmood)}';
		deadDisk.style.opacity = (mood <= 0 ? 1 : 0).toString();
		// updates portrait
		updateAvatarDisplay();
		runCount++;
	}
}