library itembox;

import 'package:polymer/polymer.dart';
import 'dart:html';
import 'package:dnd/dnd.dart'; //for dragging items into vendor interface

@CustomTag('ur-itembox')
class ItemBox extends PolymerElement {
  ItemBox.created() : super.created() {
    Draggable dragItem = new Draggable(this,
        avatarHandler: new AvatarHandler.clone());
    Dropzone dropBox = new Dropzone(this);
    
    dropBox.onDrop.listen((d) {
      //if (d.dropzoneElement.attributes['item'].trim() != '') return;
      
      d.dropzoneElement.attributes['item'] = d.draggableElement.attributes['item'];
      d.draggableElement.attributes['item'] = '';
    });
  }


  @published String item = '';
}
