library itembox;

import 'dart:html';

import 'package:dnd/dnd.dart';
import 'package:polymer/polymer.dart'; //for dragging items into vendor interface

@CustomTag('ur-itembox')
class ItemBox extends PolymerElement {
  @published String item = '';
  @published int quantity = 0;

  ItemBox.created() : super.created() {
    this.attributes.putIfAbsent('item', () => '');
    
    Draggable dragItem = new Draggable(this,
        avatarHandler: new AvatarHandler.clone());
    Dropzone dropBox = new Dropzone(this);
    
    dragItem.onDrag.listen((_) {
      dragItem.avatarHandler.avatar.shadowRoot.querySelector('ur-panel').style
        ..backgroundColor = 'transparent'
        ..border = 'none';
    });
    
    dropBox.onDrop.listen((d) {      
      if (d.draggableElement.attributes['item'].isEmpty) return;
      if (d.dropzoneElement.attributes['item'].isNotEmpty) return;
      d.dropzoneElement.attributes['item'] = d.draggableElement.attributes['item'];
      d.draggableElement.attributes['item'] = '';
    });
  }
}