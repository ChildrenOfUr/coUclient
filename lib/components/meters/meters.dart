library meters;

import 'package:polymer/polymer.dart';
import 'package:intl/intl.dart';
import 'dart:html';
import 'dart:async';
import 'dart:math' show Random;

@CustomTag('ur-meters')
class Meters extends PolymerElement {
	@published String playername = '', serverAddress;
	@published int mood = 1, maxmood = 1, energy = 1, maxenergy = 1, imagination = 0;
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
			HttpRequest.requestCrossOrigin('$serverAddress/trimImage?username=' + playername).then((String response) {
				avatarDisplay.style.backgroundImage = "url(data:image/png;base64,$response)";
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
		// update username links
		(querySelector("#openProfilePageFromChatPanel") as AnchorElement).href = "http://childrenofur.com/profile?username=" + playername;
		// updates portrait
		updateAvatarDisplay();
		runCount++;
	}
}