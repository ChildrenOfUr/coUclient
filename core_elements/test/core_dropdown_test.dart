//Copyright (c) 2014 The Polymer Project Authors. All rights reserved.
//This code may only be used under the BSD style license found at http://polymer.github.io/LICENSE.txt
//The complete set of authors may be found at http://polymer.github.io/AUTHORS.txt
//The complete set of contributors may be found at http://polymer.github.io/CONTRIBUTORS.txt
//Code distributed by Google as part of the polymer project is also
//subject to an additional IP rights grant found at http://polymer.github.io/PATENTS.txt

library core_dropdown.test;

import 'dart:async';
import 'dart:html';
import 'package:core_elements/core_dropdown.dart';
import 'package:polymer/polymer.dart';
import 'package:unittest/unittest.dart';
import 'package:unittest/html_config.dart' show useHtmlConfiguration;
import 'common.dart';

void main() {
  useHtmlConfiguration();

  initPolymer().then((zone) => zone.run(() {
    return Polymer.onReady.then((_) {
      var d1 = querySelector('#dropdown1') as CoreDropdown;
      var t1 = querySelector('#trigger1');
      var d2 = querySelector('#dropdown2') as CoreDropdown;
      var t2 = querySelector('#trigger2');
      var d3 = querySelector('#dropdown3') as CoreDropdown;
      var t3 = querySelector('#trigger3');
      var d4 = querySelector('#dropdown4') as CoreDropdown;
      var t4 = querySelector('#trigger4');
      var d5 = querySelector('#dropdown5') as CoreDropdown;
      var t5 = querySelector('#trigger5');
      var d6 = querySelector('#dropdown6') as CoreDropdown;
      var t6 = querySelector('#trigger6');

      test('default', () {
        return testPosition(d1, t1);
      });

      test('bottom alignment', () {
        return testPosition(d2, t2);
      });

      test('right alignment', () {
        return testPosition(d3, t3);
      });

      test('layered', () {
        return testPosition(d4, t4);
      });

      test('layered, bottom alignment', () {
        return testPosition(d5, t5);
      });

      test('layered, right alignment', () {
        return testPosition(d6, t6);
      });

    });
  }));
}

Future testPosition(CoreDropdown dropdown, HtmlElement trigger) {
  dropdown.open();
  return flushLayoutAndRender().then((_) =>
      new Future.delayed(new Duration(milliseconds: 200), () {})).then((_) {
    var dr = dropdown.getBoundingClientRect();
    var tr = trigger.getBoundingClientRect();
    if (dropdown.halign == 'left') {
      expect(dr.left, closeTo(tr.left, 1));
    } else {
      expect(dr.right, closeTo(tr.right, 1));
    }
    if (dropdown.valign == 'top') {
      expect(dr.top, closeTo(tr.top, 1));
    } else {
      expect(dr.bottom, closeTo(tr.bottom, 1));
    }
  });
}
