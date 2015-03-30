library meters;

import 'package:polymer/polymer.dart';
import 'package:intl/intl.dart';
import 'dart:html';
import 'dart:async';
import 'dart:math' show Random;

@CustomTag('ur-meters')
class Meters extends PolymerElement
{
	@published String playername;
	@published int mood, maxmood, energy, maxenergy, imagination;
	@published bool debug;

	NumberFormat commaFormatter = new NumberFormat("#,###");
	Element greenDisk, redDisk, hurtDisk, deadDisk;

	Meters.created() : super.created()
	{
		greenDisk = shadowRoot.querySelector('#energyDisks .green');
		redDisk = shadowRoot.querySelector('#energyDisks .red');
		hurtDisk = shadowRoot.querySelector('#leftDisk .hurt');
		deadDisk = shadowRoot.querySelector('#leftDisk .dead');

		changes.listen((_) => update());

		if(debug == true)
		{
			Random r = new Random();
			new Timer.periodic(new Duration(seconds:1), (_)
			{
				energy = r.nextInt(maxenergy);
				mood = r.nextInt(maxmood);
				imagination = r.nextInt(999999);
			});
		}
	}

	update()
	{
		// update energy disk angles and opacities
		greenDisk.style.transform = 'rotate(${120 - (energy / maxenergy) * 120}deg)';
		redDisk.style.transform = 'rotate(${120 - (energy / maxenergy) * 120}deg)';
		hurtDisk.style.backfaceVisibility = 'visible';
		hurtDisk.style.opacity = '${0.7 - (mood / maxmood)}';
		deadDisk.style.opacity = (mood <= 0 ? 1 : 0).toString();
	}
}