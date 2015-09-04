library meters;

import 'package:polymer/polymer.dart';
import 'package:intl/intl.dart';
import 'dart:html';
import 'dart:async';
import 'dart:math' show Random;
import 'dart:convert';

@CustomTag('ur-meters')
class Meters extends PolymerElement {
	@published String playername = '', serverAddress, avatarImageData = '';
	@published int mood = 1, maxmood = 1, energy = 1, maxenergy = 1, imagination = 0;
	@published bool debug = false;

	NumberFormat commaFormatter = new NumberFormat("#,###");

	Meters.created() : super.created() {
		if (debug == true) {
			Random r = new Random();
			new Timer.periodic(new Duration(seconds:1), (_) {
				energy = r.nextInt(maxenergy);
				mood = r.nextInt(maxmood);
				imagination = r.nextInt(999999);
			});
		}
	}

	void playernameChanged(String oldValue) {
		updateAvatarDisplay();
	}

	Future updateAvatarDisplay() async {
		avatarImageData = await HttpRequest.requestCrossOrigin('$serverAddress/trimImage?username=' + playername);
	}
}