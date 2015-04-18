//Copyright (c) 2014 The Polymer Project Authors. All rights reserved.
//This code may only be used under the BSD style license found at http://polymer.github.io/LICENSE.txt
//The complete set of authors may be found at http://polymer.github.io/AUTHORS.txt
//The complete set of contributors may be found at http://polymer.github.io/CONTRIBUTORS.txt
//Code distributed by Google as part of the polymer project is also
//subject to an additional IP rights grant found at http://polymer.github.io/PATENTS.txt

library core_overlay.positioning_test;

import 'dart:async';
import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:unittest/unittest.dart';
import 'package:unittest/html_config.dart' show useHtmlConfiguration;
import 'package:core_elements/core_overlay.dart';

void main() {
  useHtmlConfiguration();

  initPolymer().then((zone) => zone.run(() {
    return Polymer.onReady.then((e) {
      var basic = querySelector('#basic') as CoreOverlay;
      var overlay = querySelector('#overlay') as CoreOverlay;
      var template = querySelector('#myTemplate') as TemplateElement;

      test('core-overlay-positioning', () {
        return testWhenOpen(basic, () {
          // centered overlay
          var rect = basic.getBoundingClientRect();
          expect((rect.left - (window.innerWidth - rect.right)).abs(),
              lessThan(5), reason: 'overlay centered horizontally');
          expect((rect.top - (window.innerHeight - rect.bottom)).abs(),
              lessThan(5), reason: 'overlay centered vertically');
        }).then((_) {
          // does not retain positioning when centered and re-opened
          var listener = (e) {
            var dimensions = (e.target as CoreOverlay).jsElement['dimensions'];
            expect(dimensions['position']['h'], isNull);
            expect(dimensions['position']['v'], isNull);
          };
          var sub = basic.on['core-overlay-open-completed'].listen(listener);
          return testWhenOpen(basic, () {
            var rect = basic.getBoundingClientRect();
            expect((rect.left - (window.innerWidth - rect.right)).abs(),
                lessThan(5), reason: 'overlay centered horizontally');
            expect((rect.top - (window.innerHeight - rect.bottom)).abs(),
                lessThan(5), reason: 'overlay centered vertically');
          }).then((_) {
            sub.cancel();
          });
        }).then((_) {
          // css positioned overlay
          return testWhenOpen(overlay, () {
            var rect = overlay.getBoundingClientRect();
            expect(rect.left, 0, reason: 'positions via css');
            expect(rect.top, 0, reason: 'positions via css');
          });
        }).then((_) {
          // manual positioned overlay
          overlay.style.left = overlay.style.top = 'auto';
          overlay.style.right = '0px';
          return testWhenOpen(overlay, () {
            var rect = overlay.getBoundingClientRect();
            expect(rect.right, window.innerWidth, reason: 'positioned maually');
            expect((rect.top - (window.innerHeight - rect.bottom)).abs(),
                lessThan(5), reason: 'overlay centered vertically');
          });
        }).then((_) {
           // overflow, position top, left
          overlay.style.left = overlay.style.top = '0px';
          overlay.style.right = 'auto';
          overlay.style.width = overlay.style.height = 'auto';
          for (var i = 0; i < 20; i++) {
            overlay.append(template.content.clone(true));
          }
          return testWhenOpen(overlay, () {
            var rect = overlay.getBoundingClientRect();
            expect(window.innerWidth, greaterThanOrEqualTo(rect.right),
                reason: 'overlay constrained to window size');
            expect(window.innerHeight, greaterThanOrEqualTo(rect.bottom),
                reason: 'overlay constrained to window size');
          });
        }).then((_) {
          // overflow, position, bottom, right
          overlay.style.right = overlay.style.bottom = '0px';
          overlay.style.left = overlay.style.top = 'auto';
          return testWhenOpen(overlay, () {
            var rect = overlay.getBoundingClientRect();
            expect(window.innerWidth, greaterThanOrEqualTo(rect.right),
                reason: 'overlay constrained to window size');
            expect(window.innerHeight, greaterThanOrEqualTo(rect.bottom),
                reason: 'overlay constrained to window size');
          });
        }).then((_) {
          // overflow, unpositioned
          overlay.style.right = overlay.style.bottom = 'auto';
          overlay.style.left = overlay.style.top = 'auto';
          return testWhenOpen(overlay, () {
            var rect = overlay.getBoundingClientRect();
            expect(window.innerWidth, greaterThanOrEqualTo(rect.right),
                reason: 'overlay constrained to window size');
            expect(window.innerHeight, greaterThanOrEqualTo(rect.bottom),
                reason: 'overlay constrained to window size');
          });
        }).then((_) {
          // overflow, unpositioned, layered
          overlay.layered = true;
          return testWhenOpen(overlay, () {
            var rect = overlay.getBoundingClientRect();
            expect(window.innerWidth, greaterThanOrEqualTo(rect.right),
                reason: 'overlay constrained to window size');
            expect(window.innerHeight, greaterThanOrEqualTo(rect.bottom),
                reason: 'overlay constrained to window size');
          });
        });
      });
    });
  }));
}

Future testWhenOpen(CoreOverlay element, Function test) {
  var done = new Completer();

  var subscriptions = <StreamSubscription>[];
  subscriptions.add(element.on['core-overlay-open-completed'].listen((e) {
    test();
    new Future.delayed(new Duration(milliseconds: 1), () {
      element.opened = false;
    });
  }));
  subscriptions.add(element.on['core-overlay-close-completed'].listen((e) {
    subscriptions.forEach((s) => s.cancel());
    done.complete();
  }));

  element.opened = true;
  return done.future;
}
