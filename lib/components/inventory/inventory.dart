library inventory;

import 'package:cou_toolkit/toolkit/itembox/itembox.dart';
import 'package:polymer/polymer.dart';

@CustomTag('ur-inventory')
class UrInventory extends PolymerElement {

  List <ItemBox> boxes;
  
  UrInventory.created() : super.created() {

  }

}
