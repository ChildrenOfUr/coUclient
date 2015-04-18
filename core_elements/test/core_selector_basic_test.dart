//Copyright (c) 2014 The Polymer Project Authors. All rights reserved.
//This code may only be used under the BSD style license found at http://polymer.github.io/LICENSE.txt
//The complete set of authors may be found at http://polymer.github.io/AUTHORS.txt
//The complete set of contributors may be found at http://polymer.github.io/CONTRIBUTORS.txt
//Code distributed by Google as part of the polymer project is also
//subject to an additional IP rights grant found at http://polymer.github.io/PATENTS.txt

library core_selector.test.basic;

import 'dart:async' as async;
import 'dart:html' as dom;
import 'dart:js' as js;
import 'package:polymer/polymer.dart';
import 'package:unittest/unittest.dart';
import 'package:unittest/html_config.dart' show useHtmlConfiguration;
import 'package:core_elements/core_selector.dart' show CoreSelector;
import 'common.dart';

void oneMutation(dom.Element node, options, Function cb) {
  var o = new dom.MutationObserver((List<dom.MutationRecord>
      mutations, dom.MutationObserver observer) {
    cb();
    observer.disconnect();
  });
  o.observe(node, attributes: options['attributes']);
}

void main() {
  useHtmlConfiguration();

  initPolymer().then((zone) => zone.run(() {
    Polymer.onReady.then((e) {

      group('core-selector', () {

        test('basic', () {
          // selector1
          var s = (dom.document.querySelector('#selector1') as CoreSelector);
          expect(s.selectedClass, equals('core-selected'));
          expect(s.multi, isFalse);
          expect(s.valueattr, equals('name'));
          expect(s.items.length, equals(5));

          // selector2
          s = (dom.document.querySelector('#selector2') as CoreSelector);
          expect(s.selected, equals('item3'));
          expect(s.selectedClass, equals('my-selected'));
          // setup listener for core-select event
          var selectEventCounter = 0;
          s.on['core-select'].listen((dom.CustomEvent e) {
            // TODO(zoechi)if (e.detail['isSelected']) { // event detail is null https://code.google.com/p/dart/issues/detail?id=19315
            var detail = new js.JsObject.fromBrowserObject(e)['detail'];
            if (detail['isSelected']) {
              selectEventCounter++;
              // selectedItem and detail.item should be the same
              expect(detail['item'], equals(s.selectedItem));
            }
          });
          // set selected
          s.selected = 'item5';
          return flushLayoutAndRender().then((_) {
            // check core-select event
            expect(selectEventCounter, equals(1));
            // check selected class
            expect(s.children[4].classes.contains('my-selected'), isTrue);
            // check selectedItem
            expect(s.selectedItem, equals(s.children[4]));
            // selecting the same value shouldn't fire core-select
            selectEventCounter = 0;
            s.selected = 'item5';
            // TODO(ffu): would be better to wait for something to happen
            // instead of not to happen
            return flushLayoutAndRender().then((_) {
              expect(selectEventCounter, equals(0));
            });
          });
        });

      });

    });
  }));
}

