library meters;

import 'package:polymer/polymer.dart';
import 'package:intl/intl.dart';
import 'dart:html';

@CustomTag('ur-meters')
class Meters extends PolymerElement {
  Meters.created() : super.created() {
    update();
  }
 
  @published String playername;
  @published int mood;
  @published int maxmood;
  @published int energy;
  @published int maxenergy;

  @published int imagination;  
  
  NumberFormat commaFormatter = new NumberFormat("#,###");  

  update() {
    // update energy disk angles
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