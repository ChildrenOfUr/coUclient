//Copyright (c) 2014 The Polymer Project Authors. All rights reserved.
//This code may only be used under the BSD style license found at http://polymer.github.io/LICENSE.txt
//The complete set of authors may be found at http://polymer.github.io/AUTHORS.txt
//The complete set of contributors may be found at http://polymer.github.io/CONTRIBUTORS.txt
//Code distributed by Google as part of the polymer project is also
//subject to an additional IP rights grant found at http://polymer.github.io/PATENTS.txt

library core_input.test;

import 'dart:html';

import 'package:polymer/polymer.dart';
import 'package:unittest/unittest.dart';
import 'package:unittest/html_config.dart' show useHtmlConfiguration;
import 'package:core_elements/core_input.dart';

void main() {
  useHtmlConfiguration();

  initPolymer().then((zone) => zone.run(() {
    return Polymer.onReady.then((_) {
      var i1 = querySelector('#input1') as CoreInput;

      group('prevent invalid input', () {

        test('cannot enter invalid input', () {
          i1.value = '123';
          dispatchInputEvent(i1);
          expect(i1.value, '');
        });

        test('preserves valid input after entering invalid input', () {
          var value = 'abc';
          i1.value = value;
          dispatchInputEvent(i1);
          expect(i1.value, value);
          i1.value = '${value}123';
          dispatchInputEvent(i1);
          expect(i1.value, value);
        });

      });
    });
  }));
}

void dispatchInputEvent(InputElement target) {
  var e = new Event('input', canBubble: true);
  target.dispatchEvent(e);
}
