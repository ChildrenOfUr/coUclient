library meters;

import 'package:polymer/polymer.dart';
import 'package:intl/intl.dart';
import 'dart:html';

@CustomTag('ur-meters')
class Meters extends PolymerElement {
  Meters.created() : super.created();
 
  @published String playername;
  @published int mood;
  @published int maxmood;
  @published int energy;
  @published int maxenergy;

  @published int imagination;
  
  @observable String img;

  NumberFormat commaFormatter = new NumberFormat("#,###");  
}