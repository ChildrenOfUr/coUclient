library itembox;

import 'package:dnd/dnd.dart';
import 'package:polymer/polymer.dart';

@CustomTag('ur-itembox')
class ItemBox extends PolymerElement
{
	@published String item = '';
	@published int quantity = 0;

	Draggable _dragItem;
	Dropzone _dropBox;

	ItemBox.created() : super.created()
	{
		this.attributes.putIfAbsent('item', () => '');
		initDragDrop();
	}

	initDragDrop()
	{
		_dragItem = new Draggable(this, avatarHandler: new AvatarHandler.clone());
		_dropBox = new Dropzone(this);

		// Hide the 'panel' element of our dragged object
		_dragItem.onDrag.listen((_)
		{
			_dragItem.avatarHandler.avatar.shadowRoot.querySelector('ur-panel').style
				..backgroundColor = 'transparent'
				..border = 'none';
		});

		_dropBox.onDrop.listen((d)
		{
			// Don't drag nothingness
			if (d.draggableElement.item == '')
				return;

			// Add to similar item stacks, but don't add to different stacks
			if (d.dropzoneElement.item != '')
			{
				if (d.dropzoneElement.item == d.draggableElement.item)
				{
					int total = d.draggableElement.quantity + d.dropzoneElement.quantity;
					d.draggableElement.attributes['quantity'] = total.toString();
				}
				else
				{
					//since this swaps all the attributes of each element
					//it effectively swaps the elements
					Map<String,String> temp = {};
					d.draggableElement.attributes.forEach((key,value) => temp[key] = value);
					d.draggableElement.attributes = d.dropzoneElement.attributes;
					d.dropzoneElement.attributes = temp;
					return;
				}
			}

			d.dropzoneElement.attributes['item'] = d.draggableElement.attributes['item'];
			d.dropzoneElement.attributes['quantity'] = d.draggableElement.attributes['quantity'];
			d.draggableElement.attributes['item'] = '';
			d.draggableElement.attributes['quantity'] = 0.toString();
		});
	}
}