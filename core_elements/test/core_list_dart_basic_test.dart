//Copyright (c) 2014 The Polymer Project Authors. All rights reserved.
//This code may only be used under the BSD style license found at http://polymer.github.io/LICENSE.txt
//The complete set of authors may be found at http://polymer.github.io/AUTHORS.txt
//The complete set of contributors may be found at http://polymer.github.io/CONTRIBUTORS.txt
//Code distributed by Google as part of the polymer project is also
//subject to an additional IP rights grant found at http://polymer.github.io/PATENTS.txt

library core_list_dart.test;

import 'dart:async';
import 'dart:html';
import 'dart:math';

import 'package:polymer/polymer.dart';
import 'package:unittest/unittest.dart';
import 'package:unittest/html_config.dart' show useHtmlConfiguration;
import 'package:core_elements/core_list_dart.dart';
import 'package:template_binding/template_binding.dart';
import 'common.dart';

CoreList list;
var height = 80;
var physicalCount;
var index = 0;

void main() {
  useHtmlConfiguration();

  initPolymer().then((zone) => zone.run(() => Polymer.onReady.then((_) {
    list = querySelector('core-list-dart') as CoreList;
    physicalCount = (list.offsetHeight / height).ceil();

    // Dart specific tests
    group('core-list-dart tests', () {

      test('calling updateSize with no data doesn\'t throw', () {
        list.data = null;
        return dirtyCheck().then((_) {
          list.updateSize();
        });
      });

      test('clicking on a selected item toggles it', () {
        list.data = toObservable([generateItem()]);
        return dirtyCheck().then((_) {
          // Select first item
          var item = document.elementFromPoint(list.clientWidth - 50, 0);
          var event = new MouseEvent('tap', canBubble: true, view: window);
          item.dispatchEvent(event);
          return dirtyCheck().then((_) {
            expect(list.selection.id, list.data[0].id);
            item.dispatchEvent(event);
            return dirtyCheck().then((_) {
              expect(list.selection, isNull);
            });
          });
        });
      });

    });

    // Port of JS tests
    test('core-list basic', () {
      // Initialize list with two items
      list.data = toObservable([generateItem(), generateItem()]);
      return dirtyCheck().then((_) {
        // (+1 for template)
        expect(list.children.length, 3,
            reason: 'children.length should be 3 (1 template + count of data '
              'elements');
        checkTopItem('after initialization');
      }).then((_) {
        // Select first item
        var item = document.elementFromPoint(list.clientWidth - 50, 0);
        expect(item, isNotNull, reason: 'item should exist at top of list');
        item.dispatchEvent(
            new MouseEvent('tap', canBubble: true, view: window));
        return dirtyCheck().then((_) {
          expect(list.selection, isNotNull);
          expect(list.selection.id, list.data[0].id,
              reason: 'first item should be selected; selected id was '
                '${list.selection.id}');
        });
      }).then((_) {
        // Select second item
        var item = document.elementFromPoint(list.clientWidth - 50, height);
        item.dispatchEvent(
            new MouseEvent('tap', view: window, canBubble: true));
        return dirtyCheck().then((_) {
          expect(list.selection, isNotNull);
          expect(list.selection.id, list.data[1].id,
              reason: 'second item should be selected; selection '
                '${list.selection.id}');
        });
      }).then((_) {
        // Enable multiple-selection, and select the first item (for total of
        // 2 selected)
        list.multi = true;
        var item = document.elementFromPoint(list.clientWidth - 50, 0);
        item.dispatchEvent(
            new MouseEvent('tap', view: window, canBubble: true));
        return dirtyCheck().then((_) {
          expect(list.selection, isNotNull);
          expect(list.selection.length, 2,
              reason: 'selection length should be 2');
          // Note, selection is maintained in order, so last item selected is
          // last in selection
          expect(list.selection[0].id, list.data[1].id);
          expect(list.selection[1].id, list.data[0].id,
              reason: 'first and second should be selected; selected ids :'
                '${list.selection[0].id}, ${list.selection[1].id}');
        });
      }).then((_) {
        // Delete one item
        list.data.length = 1;
        return dirtyCheck().then((_) {
          expect(list.children.length, 3,
              reason: 'children.length should stay 3 (1 template, plus 2 '
                  'originally created items)');
          expect(list.children[2].attributes['hidden'], isNotNull,
              reason: 'last element should be hidden');
          expect(list.selection.length, 1,
              reason: 'selection length should be 1');
          expect(list.selection[0].id, list.data[0].id,
              reason: 'first element should be selected');
        });
      }).then((_) {
        // Deselect first item
        var item = document.elementFromPoint(list.clientWidth - 50, 0);
        item.dispatchEvent(
            new MouseEvent('tap', view: window, canBubble: true));
        return dirtyCheck().then((_) {
          expect(list.selection.length, 0,
              reason: 'selection length should be 0');
        });
      }).then((_) {
        // Add many more than viewport
        var more = physicalCount * 20;
        while (more-- != 0) {
          list.data.add(generateItem());
        }
        return dirtyCheck().then((_) {
          // (+1 for template)
          expect(list.children.length, greaterThan(physicalCount + 1),
            reason: 'children.length should be $physicalCount (1 template + '
                'max number of elements');
        });
      })
      // Scroll down
      .then(wait).then((_) => scrollItemsAndCheck(physicalCount))
      .then(wait).then((_) => scrollItemsAndCheck(physicalCount))
      .then(wait).then((_) => scrollItemsAndCheck(physicalCount))
      .then(wait).then((_) => scrollItemsAndCheck(physicalCount))
      .then(wait).then((_) => scrollItemsAndCheck(physicalCount))
      .then(wait).then((_) => scrollItemsAndCheck(physicalCount))
      .then(wait).then((_) => scrollItemsAndCheck(physicalCount))
      .then(wait).then((_) => scrollItemsAndCheck(physicalCount))
      .then(wait).then((_) => scrollItemsAndCheck(physicalCount))
      .then(wait).then((_) => scrollItemsAndCheck(physicalCount))
      .then(wait).then((_) => scrollItemsAndCheck(physicalCount))
      .then(wait).then((_) => scrollItemsAndCheck(physicalCount))
      .then(wait).then((_) => scrollItemsAndCheck(physicalCount))
      // Scroll back up
      .then(wait).then((_) => scrollItemsAndCheck(-physicalCount))
      .then(wait).then((_) => scrollItemsAndCheck(-physicalCount))
      .then(wait).then((_) => scrollItemsAndCheck(-physicalCount))
      .then(wait).then((_) => scrollItemsAndCheck(-physicalCount))
      .then(wait).then((_) => scrollItemsAndCheck(-physicalCount))
      .then(wait).then((_) => scrollItemsAndCheck(-physicalCount))
      .then(wait).then((_) => scrollItemsAndCheck(-physicalCount))
      .then(wait).then((_) => scrollItemsAndCheck(-physicalCount))
      .then(wait).then((_) => scrollItemsAndCheck(-physicalCount))
      .then(wait).then((_) => scrollItemsAndCheck(-physicalCount))
      .then(wait).then((_) => scrollItemsAndCheck(-physicalCount))
      .then(wait).then((_) => scrollItemsAndCheck(-physicalCount))
      .then(wait).then((_) => scrollItemsAndCheck(-physicalCount))
      .then((_) {
        // Scroll all the way to bottom
        list.scrollTop = 99999999;
        index = list.data.length - (list.offsetHeight / height).ceil();
        return dirtyCheck().then((_) {
          checkTopItem('at bottom of list');
        });
      }).then((_) {
        // Select item
        var item = document.elementFromPoint(list.clientWidth - 50, 0);
        item.dispatchEvent(
            new MouseEvent('tap', view: window, canBubble: true));
        return dirtyCheck().then((_) {
          expect(list.selection.length, 1,
              reason: 'selection length should be 1');
          expect(list.selection[0].id, list.data[index].id,
              reason: 'top item at bottom of list (index $index) should be '
                  'selected');
        });
      }).then((_) {
        // Delete one item from bottom
        list.data.length = list.data.length - 1;
        var lastIndex = index;
        index = list.data.length - (list.offsetHeight / height).ceil();
        return dirtyCheck().then((_) {
          checkTopItem(
              'at bottom of list after deleting one item from end of list');
          expect(list.selection.length, 1,
              reason: 'selection length should be 1');
          expect(list.selection[0].id, list.data[lastIndex].id,
              reason: 'previously selected item (index $lastIndex) should stay '
                  'selected');
        });
      }).then((_) {
        // Delete half of the items from the bottom
        list.data.length = list.data.length - (list.data.length / 2).floor();
        var lastIndex = index;
        index = list.data.length - (list.offsetHeight / height).ceil();
        return dirtyCheck().then((_) {
          checkTopItem('at bottom of list after deleting half of items from '
              'end of list');
          expect(list.selection.length, 0,
              reason: 'selection length should be 0');
        });
      }).then((_) {
        // Delete from top
        list.data.removeRange(0, (list.data.length / 2).floor());
        index = list.data.length - (list.offsetHeight / height).ceil();
        return dirtyCheck().then((_) {
          // TODO(jakemac): This fails, restore once it passes.
          //  checkTopItem('at bottom of list after deleting half of items '
          //      'from top of list');
        });
      }).then((_) {
        // Delete from top again
        list.data.removeRange(0, (list.data.length / 2).floor());
        index = list.data.length - (list.offsetHeight / height).ceil();
        return dirtyCheck().then((_) {
          // TODO(jakemac): This fails, restore once it passes.
          // checkTopItem('at bottom of list after deleting half of items '
          //    'from top of list (again)');
        });
      });
    });
  })));
}

Future wait(_) {
  return new Future.delayed(new Duration(milliseconds: 100), () {});
}

Future dirtyCheck() {
  scheduleMicrotask(Observable.dirtyCheck);
  // TODO(jakemac): Extra delay makes everything less flaky. Why is this needed?
  return flushLayoutAndRender().then(wait);
}

var rand = new Random();
class ListModel {
  final int id;
  final bool checked;
  final int value;
  final int type;
  ListModel(this.id, this.checked, this.value, this.type);
}

// Helper to create random items
ListModel generateItem() => new ListModel(
    rand.nextInt(10000), rand.nextBool(), rand.nextInt(10000), rand.nextInt(3));

// Helper to assert top item is rendered as expected
void checkTopItem(positionDescription) {
  // Measure from top-right (to avoid template children)
  var item = document.elementFromPoint(list.clientWidth - 50, 0);
  expect(item, isNotNull);
  var templateInstance = nodeBind(item).templateInstance;
  expect(templateInstance, isNotNull);
  var model = templateInstance.model.model;
  expect(model, isNotNull);
  expect(model.index, index,
      reason: 'top item index should be $index positionDescription');
  expect(model.selected, false,
      reason: 'top item should start out with selected == false');
  expect(model.model, list.data[index],
      reason: 'top item model should be data[$index]  $positionDescription');
  expect(item.querySelector('#index').text, '$index',
      reason: 'top item index content should be $index $positionDescription');
  expect(item.querySelector('#id').text, '${list.data[index].id}',
      reason: 'top item id content should be ${list.data[index].id} '
          '$positionDescription');
  expect(item.querySelector('#checkbox').checked, list.data[index].checked,
      reason: 'top item checkbox should be ${list.data[index].checked} '
          'positionDescription');
  expect(item.querySelector('#input').value, '${list.data[index].value}',
      reason: 'top item input should be ${list.data[index].value}  '
          'positionDescription');
  expect(item.querySelector('#select').selectedIndex, list.data[index].type,
      reason: 'top item select should be ${list.data[index].type} '
          'positionDescription');
}

void scrollItemsAndCheck(count) {
  index += count;
  list.scrollTop += count * height;
  checkTopItem('when scrolled to item $index');
}
