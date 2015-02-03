library itembox;

import 'dart:html';

import 'package:dnd/dnd.dart';
import 'package:polymer/polymer.dart'; //for dragging items into vendor interface



@CustomTag('ur-itembox')
class ItemBox extends PolymerElement {
  @published String item = '';
  @published int quantity = 0;

  Draggable dragItem;
  Dropzone dropBox;

  ItemBox.created() : super.created() {
    this.attributes.putIfAbsent('item', () => '');
    updateQuantityOpacity();
    initDragDrop();
    this.changes.listen((_) {
      updateQuantityOpacity();
      if (quantity <= 1) 
        shadowRoot.querySelector('#item-quantity').hidden = true;
      else 
        shadowRoot.querySelector('#item-quantity').hidden = false;
      //resetDragDrop();
      //updateDragDrop();
    });
  }

  updateQuantityOpacity() {
    if (quantity <= 1) 
      shadowRoot.querySelector('#item-quantity').hidden = true;
    else 
      shadowRoot.querySelector('#item-quantity').hidden = false;
  }


  initDragDrop() {
    dragItem = new Draggable(this, avatarHandler: new AvatarHandler.clone());
    dropBox = new Dropzone(this);

    // Hide the 'panel' element of our dragged object
    dragItem.onDrag.listen((_) {
      dragItem.avatarHandler.avatar.shadowRoot.querySelector('ur-panel').style
          ..backgroundColor = 'transparent'
          ..border = 'none';
    });


    dropBox.onDrop.listen((d) {
      // Don't drag nothingness
      if (d.draggableElement.attributes['item'] == '') return;

      // Add to similar item stacks, but don't add to different stacks
      if (d.dropzoneElement.attributes['item'] != '') {
        if (d.dropzoneElement.item == d.draggableElement.item) {
          d.draggableElement.attributes['quantity'] = (d.draggableElement.quantity + d.dropzoneElement.quantity).toString();
        } else return;
      }
      ;

      d.dropzoneElement.attributes['item'] = d.draggableElement.attributes['item'];
      d.dropzoneElement.attributes['quantity'] = d.draggableElement.attributes['quantity'];
      d.draggableElement.attributes['item'] = '';
      d.draggableElement.attributes['quantity'] = 0.toString();
    });
  }

}
