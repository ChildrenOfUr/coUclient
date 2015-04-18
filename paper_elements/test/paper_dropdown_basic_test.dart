//Copyright (c) 2014 The Polymer Project Authors. All rights reserved.
//This code may only be used under the BSD style license found at http://polymer.github.io/LICENSE.txt
//The complete set of authors may be found at http://polymer.github.io/AUTHORS.txt
//The complete set of contributors may be found at http://polymer.github.io/CONTRIBUTORS.txt
//Code distributed by Google as part of the polymer project is also
//subject to an additional IP rights grant found at http://polymer.github.io/PATENTS.txt

library paper_dropdown.basic_test;

import 'dart:async';
import 'dart:html';
import 'package:paper_elements/paper_dropdown.dart';
import 'package:polymer/polymer.dart';
import 'package:unittest/unittest.dart';
import 'package:unittest/html_config.dart' show useHtmlConfiguration;
import 'common.dart';

void main() {
  useHtmlConfiguration();

  initPolymer().then((zone) => zone.run(() {
    return Polymer.onReady.then((_) {
      var d1 = querySelector('#dropdown1') as PaperDropdown;
      var t1 = querySelector('#trigger1');
      d1.relatedTarget = t1;
      var d2 = querySelector('#dropdown2') as PaperDropdown;
      var t2 = querySelector('#trigger2');
      d2.relatedTarget = t2;
      var d3 = querySelector('#dropdown3') as PaperDropdown;
      var t3 = querySelector('#trigger3');
      d3.relatedTarget = t3;

      test('default', () {
        d1.opened = true;
        return flushLayoutAndRender().then((_) => wait(200)).then((_) {
          assertPosition(d1, t1);
        });
      });

      test('bottom alignment', () {
        d2.valign = 'bottom';
        d2.opened = true;
        return flushLayoutAndRender().then((_) => wait(200)).then((_) {
          assertPosition(d2, t2);
        });
      });

      test('right alignment', () {
        d3.halign = 'right';
        d3.opened = true;
        return flushLayoutAndRender().then((_) => wait(200)).then((_) {
          assertPosition(d3, t3);
        });
      });
    });
  }));
}

Future wait(int milliseconds) =>
    new Future.delayed(new Duration(milliseconds: milliseconds), () {});

void assertPosition(PaperDropdown dropdown, Element trigger) {
  var dr = dropdown.getBoundingClientRect();
  var tr = trigger.getBoundingClientRect();
  if (dropdown.halign == 'left') {
    expect(dr.left, tr.left);
  } else {
    expect(dr.right, tr.right);
  }
  if (dropdown.valign == 'top') {
    expect(dr.top, tr.top);
  } else {
    expect(dr.bottom, tr.bottom);
  }
}
