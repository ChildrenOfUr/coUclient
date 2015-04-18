//Copyright (c) 2014 The Polymer Project Authors. All rights reserved.
//This code may only be used under the BSD style license found at http://polymer.github.io/LICENSE.txt
//The complete set of authors may be found at http://polymer.github.io/AUTHORS.txt
//The complete set of contributors may be found at http://polymer.github.io/CONTRIBUTORS.txt
//Code distributed by Google as part of the polymer project is also
//subject to an additional IP rights grant found at http://polymer.github.io/PATENTS.txt
library core_selector.test.content;

import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:unittest/unittest.dart';
import 'package:unittest/html_config.dart' show useHtmlConfiguration;

import 'common.dart';
import 'package:core_elements/core_selector.dart';

@CustomTag('test-core-selector')
class TestCoreSelector extends PolymerElement {
  @published String selected;

  TestCoreSelector.created() : super.created();

  CoreSelector get selector => $['selector'];
}

void main() {
  useHtmlConfiguration();

  initPolymer().then((zone) => zone.run(() {
    Polymer.onReady.then((e) {
      var s = document.querySelector('test-core-selector') as TestCoreSelector;
      
      group('content', () {
      
        test('get selected', () {
          return flushLayoutAndRender().then((_) {
            // check selected class
            expect(s.children[0].classes.contains('core-selected'), true);
          });
        });

        test('set selected', () {
          // set selected
          s.selected = 'item1';
          return flushLayoutAndRender().then((_) {
            // check selected class
            expect(s.children[1].classes.contains('core-selected'), true);
          });
        });
        
        test('get items', () {
          expect(s.selector.items.length, s.children.length);
        });
        
        test('activate event', () {
          s.children[2].dispatchEvent(new CustomEvent('tap', canBubble: true));
          return flushLayoutAndRender().then((_) {
            // check selected class
            expect(s.children[2].classes.contains('core-selected'), true);
          });
        });
        
        test('add item dynamically', () {
          var item = document.createElement('div');
          item.id = 'item4';
          item.text = 'item4';
          s.append(item);
          // set selected
          s.selected = 'item4';
          return flushLayoutAndRender().then((_) {
            // check selected class
            expect(s.children[4].classes.contains('core-selected'), true);
          });
        });
      });
      
    });
  }));
}
