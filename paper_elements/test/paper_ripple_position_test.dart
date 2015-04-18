//Copyright (c) 2014 The Polymer Project Authors. All rights reserved.
//This code may only be used under the BSD style license found at http://polymer.github.io/LICENSE.txt
//The complete set of authors may be found at http://polymer.github.io/AUTHORS.txt
//The complete set of contributors may be found at http://polymer.github.io/CONTRIBUTORS.txt
//Code distributed by Google as part of the polymer project is also
//subject to an additional IP rights grant found at http://polymer.github.io/PATENTS.txt

library paper_ripple.position_test;

import 'dart:async';
import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:unittest/unittest.dart';
import 'package:unittest/html_config.dart' show useHtmlConfiguration;
import 'common.dart';

void main() {
  useHtmlConfiguration();

  initPolymer().then((zone) => zone.run(() {
    Polymer.onReady.then((_) {

      test('tall container', () {
        var ripple1 = querySelector('.ripple-1 paper-ripple');
        var center = centerOf(ripple1);
        var e = new MouseEvent('down', canBubble: true, clientX: center['x'],
            clientY: center['y']);
        ripple1.dispatchEvent(e);
        return flushLayoutAndRender().then((_) {
          var wave = querySelector('.ripple-1 /deep/ .wave');
          expectCloseTo(centerOf(ripple1), centerOf(wave));
        });
      });

      test('wide container', () {
        var ripple2 = querySelector('.ripple-2 paper-ripple');
        var center = centerOf(ripple2);
        var e = new MouseEvent('down', canBubble: true, clientX: center['x'],
            clientY: center['y']);
        ripple2.dispatchEvent(e);
        return flushLayoutAndRender().then((_) {
          var wave = querySelector('.ripple-2 /deep/ .wave');
          expectCloseTo(centerOf(ripple2), centerOf(wave));
        });
      });

    });
  }));
}

expectCloseTo(Map a, Map b) {
  expect(a['x'], closeTo(b['x'], 1));
  expect(a['y'], closeTo(b['y'], 1));
}

centerOf(Element node) {
  var rect = node.getBoundingClientRect();
  return {
    'x': (rect.left + rect.width / 2).round(),
    'y': (rect.top + rect.height / 2).round(),
  };
}
