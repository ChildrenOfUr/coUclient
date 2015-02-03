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
    
    this.changes.listen((_) {
      if (quantity <= 1)
        shadowRoot.querySelector('#item-quantity').hidden = true;
      else
        shadowRoot.querySelector('#item-quantity').hidden = false;
    });
    
    
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
      if (d.dropzoneElement.attributes['item'].isNotEmpty) {
        if (d.dropzoneElement.item == d.draggableElement.item)
          d.dropzoneElement.quantity += d.draggableElement.quantity;
        else
          return;        
      };
      d.dropzoneElement.item = d.draggableElement.item;
      d.dropzoneElement.quantity = d.draggableElement.quantity;
      d.draggableElement.item = '';
      d.draggableElement.quantity = 0;
    });
  }
  
}