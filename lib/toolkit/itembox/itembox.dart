library meters;

import 'package:polymer/polymer.dart';
import 'dart:html';
import 'package:dnd/dnd.dart'; //for dragging items into vendor interface

@CustomTag('ur-itembox')
class ItemBox extends PolymerElement {
  ItemBox.created() : super.created() {
    Element box = querySelector('ur-panel');

    this.onDrop.listen((MouseEvent de) {
      item = de.dataTransfer.getData('text/html');
    });

    this.onDragStart.listen((MouseEvent de) {
      if (item != '') {
        print('$item != ""');
        de.dataTransfer.setData('text/html', item);
        return false;
      };
    });

  }


  @published String item = '';
}
