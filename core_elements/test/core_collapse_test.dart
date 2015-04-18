//Copyright (c) 2014 The Polymer Project Authors. All rights reserved.
//This code may only be used under the BSD style license found at http://polymer.github.io/LICENSE.txt
//The complete set of authors may be found at http://polymer.github.io/AUTHORS.txt
//The complete set of contributors may be found at http://polymer.github.io/CONTRIBUTORS.txt
//Code distributed by Google as part of the polymer project is also
//subject to an additional IP rights grant found at http://polymer.github.io/PATENTS.txt

library polymer_collapse.test;

import 'dart:async';
import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:unittest/unittest.dart';
import 'package:unittest/html_config.dart' show useHtmlConfiguration;
import 'package:core_elements/core_collapse.dart' show CoreCollapse;
import 'common.dart';

void main() {
  useHtmlConfiguration();

  initPolymer().then((zone) => zone.run(() {
    return Polymer.onReady.then((_) {

      var collapse = querySelector('#collapse') as CoreCollapse;

      var delay = 200;
      var collapseHeight;

      group('basic', () {

        test('verify attribute', () {
          expect(collapse.opened, true);
        });

        test('verify height', () {
          return flushLayoutAndRender().then((_) {
            return new Future.delayed(new Duration(milliseconds: delay), () {
              collapseHeight = getCollapseComputedStyle().height;
              expect(collapseHeight, isNot('0px'));
            });
          });
        });

        test('test opened: false', () {
          collapse.opened = false;
          return flushLayoutAndRender().then((_) {
            return new Future.delayed(new Duration(milliseconds: delay), () {
              expect(getCollapseComputedStyle().height, '0px');
            });
          });
        });

        test('test opened: true', () {
          collapse.opened = true;
          return flushLayoutAndRender().then((_) {
            return new Future.delayed(new Duration(milliseconds: delay), () {
              expect(getCollapseComputedStyle().height, collapseHeight);
            });
          });
        });

      });

    });
  }));
}

dynamic getCollapseComputedStyle() {
  HtmlElement b = querySelector('#collapse');
  return b.getComputedStyle();
}
