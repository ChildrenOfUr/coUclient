//Copyright (c) 2014 The Polymer Project Authors. All rights reserved.
//This code may only be used under the BSD style license found at http://polymer.github.io/LICENSE.txt
//The complete set of authors may be found at http://polymer.github.io/AUTHORS.txt
//The complete set of contributors may be found at http://polymer.github.io/CONTRIBUTORS.txt
//Code distributed by Google as part of the polymer project is also
//subject to an additional IP rights grant found at http://polymer.github.io/PATENTS.txt

library core_range.test;

import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:unittest/unittest.dart';
import 'package:unittest/html_config.dart' show useHtmlConfiguration;
import 'package:core_elements/core_range.dart';
import 'common.dart';

void main() {
  useHtmlConfiguration();

  initPolymer().then((zone) => zone.run(() {
    return Polymer.onReady.then((e) {
      var range = querySelector('core-range') as CoreRange;

      group('basic', () {

        test('check default', () {
          expect(range.min, 0);
          expect(range.max, 100);
          expect(range.value, 0);
        });

        test('set value', () {
          range.value = 50;
          return flushLayoutAndRender().then((_) {
            expect(range.value, 50);
            // test clamp value
            range.value = 60.1;
            return flushLayoutAndRender();
          }).then((_) {
            expect(range.value, 60);
          });
        });

        test('set max', () {
          range.max = 10;
          range.value = 11;
          return flushLayoutAndRender().then((_) {
            expect(range.value, range.max);
          });
        });
        
        test('test ratio', () {
          range.max = 10;
          range.value = 5;
          return flushLayoutAndRender().then((_) {
            expect(range.ratio, 50);
          });
        });
        
        test('set min', () {
          range.min = 10;
          range.max = 50;
          range.value = 30;
          return flushLayoutAndRender().then((_) {
            expect(range.ratio, 50);
            range.value = 0;
            return flushLayoutAndRender().then((_) {
              expect(range.value, range.min);
            });
          });
        });
        
        test('set step', () {
          range.min = 0;
          range.max = 10;
          range.value = 5.1;
          return flushLayoutAndRender().then((_) {
            expect(range.value, 5);
            range.step = 0.1;
            range.value = 5.1;
            return flushLayoutAndRender().then((_) {
              expect(range.value, 5.1);
            });
          });
        });

      });
    });
  }));
}
