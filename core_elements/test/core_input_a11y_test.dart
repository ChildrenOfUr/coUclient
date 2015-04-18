//Copyright (c) 2014 The Polymer Project Authors. All rights reserved.
//This code may only be used under the BSD style license found at http://polymer.github.io/LICENSE.txt
//The complete set of authors may be found at http://polymer.github.io/AUTHORS.txt
//The complete set of contributors may be found at http://polymer.github.io/CONTRIBUTORS.txt
//Code distributed by Google as part of the polymer project is also
//subject to an additional IP rights grant found at http://polymer.github.io/PATENTS.txt

library core_input.a11y_test;

import 'dart:html';

import 'package:initialize/initialize.dart' as init;
import 'package:polymer/polymer.dart';
import 'package:unittest/unittest.dart';
import 'package:unittest/html_config.dart' show useHtmlConfiguration;
import 'package:core_elements/core_input.dart';
import 'common.dart';

void main() {
  useHtmlConfiguration();
  initPolymer().then((zone) => zone.run(() {
    return Polymer.onReady.then((_) {
      CoreInput i1 = querySelector('#input1');
      CoreInput i2 = querySelector('#input2');

      test('aria-label set to placeholder', () {
        expect(i1.attributes['aria-label'], 'label');
        i1.setAttribute('placeholder', 'new label');
        return flushLayoutAndRender().then((_) {
          expect(i1.attributes['aria-label'], 'new label');
        });
      });

      test('aria-disabled is set', () {
        expect(i2.attributes.containsKey('aria-disabled'), true);
        i2.attributes.remove('disabled');
        return flushLayoutAndRender().then((_) {
          expect(i2.attributes.containsKey('aria-disabled'), false);
        });
      });
    });
  }));
}
