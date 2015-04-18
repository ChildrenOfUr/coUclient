//Copyright (c) 2014 The Polymer Project Authors. All rights reserved.
//This code may only be used under the BSD style license found at http://polymer.github.io/LICENSE.txt
//The complete set of authors may be found at http://polymer.github.io/AUTHORS.txt
//The complete set of contributors may be found at http://polymer.github.io/CONTRIBUTORS.txt
//Code distributed by Google as part of the polymer project is also
//subject to an additional IP rights grant found at http://polymer.github.io/PATENTS.txt

library core_toolbar.test;

import 'dart:html';
import 'dart:async';

import 'package:polymer/polymer.dart';
import 'package:unittest/unittest.dart';
import 'package:unittest/html_config.dart' show useHtmlConfiguration;
import 'package:core_elements/core_toolbar.dart';
import 'common.dart';

void main() {
  useHtmlConfiguration();

  initPolymer().then((zone) => zone.run(() {
    return Polymer.onReady.then((_) {
      var toolbar = querySelector('core-toolbar') as CoreToolbar;

      group('basic', () {
      
        test('check default height', () {
          expect(toolbar.offsetHeight, 64);
        });
        
        test('check medium-tall height', () {
          toolbar.classes.add('medium-tall');
          return flushLayoutAndRender().then((_) {
            expect(toolbar.offsetHeight, 128);
          });
        });
        
        test('check tall height', () {
          toolbar.classes.add('tall');
          return flushLayoutAndRender().then((_) {
            expect(toolbar.offsetHeight, 192);
          });
        });
        
        test('item at top', () {
          var item = document.createElement('div');
          toolbar.append(item);
          return flushLayoutAndRender().then((_) {
            expect(item.getDestinationInsertionPoints()[0].parent,
                toolbar.$['topBar']);
          });
        });
        
        test('item at middle', () {
          var item = document.createElement('div');
          item.classes.add('middle');
          toolbar.append(item);
          return flushLayoutAndRender().then((_) {
            expect(item.getDestinationInsertionPoints()[0].parent,
                toolbar.$['middleBar']);
          });
        });
        
        test('item at bottom', () {
          var item = document.createElement('div');
          item.classes.add('bottom');
          toolbar.append(item);
          return flushLayoutAndRender().then((_) {
            expect(item.getDestinationInsertionPoints()[0].parent,
                toolbar.$['bottomBar']);
          });
        });
        
      });
    });
  }));
}

