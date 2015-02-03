library meters;

import 'package:polymer/polymer.dart';
import 'package:intl/intl.dart';
import 'dart:html';
import 'dart:async';
import 'dart:math' show Random;

@CustomTag('ur-meters')
class Meters extends PolymerElement {
  Meters.created() : super.created() {
    update();
    changes.listen( (_) {
      update();
    });
    if (debug == true) {
      Random r = new Random();
      new Timer.periodic(new Duration(seconds:1), (_) {
        energy = r.nextInt(maxenergy);
        mood = r.nextInt(maxmood);
        imagination = r.nextInt(999999);
      
      });
    }
  }
 
  @published String playername;
  @published int mood;
  @published int maxmood;
  @published int energy;
  @published int maxenergy;
  @published int imagination;  
  
  NumberFormat commaFormatter = new NumberFormat("#,###");  

  @published bool debug;
  
  update() {
    // update energy disk angles and opacities
    shadowRoot.querySelector('#energyDisks .green')
      ..style.transform = 'rotate(${120 - (energy / maxenergy) * 120}deg)';
    shadowRoot.querySelector('#energyDisks .red')
      ..style.transform = 'rotate(${120 - (energy / maxenergy) * 120}deg)';    
      
    shadowRoot.querySelector('#leftDisk .hurt')
      ..style.opacity = '${0.7 - (mood / maxmood)}';
    
    shadowRoot.querySelector('#leftDisk .dead')
      ..style.opacity = (mood <= 0 ? 1 : 0).toString();
  }
}