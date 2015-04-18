//Copyright (c) 2014 The Polymer Project Authors. All rights reserved.
//This code may only be used under the BSD style license found at http://polymer.github.io/LICENSE.txt
//The complete set of authors may be found at http://polymer.github.io/AUTHORS.txt
//The complete set of contributors may be found at http://polymer.github.io/CONTRIBUTORS.txt
//Code distributed by Google as part of the polymer project is also
//subject to an additional IP rights grant found at http://polymer.github.io/PATENTS.txt

library paper_input.autogrow_test;

import 'dart:html';
import 'package:paper_elements/paper_autogrow_textarea.dart';
import 'package:polymer/polymer.dart';
import 'package:unittest/unittest.dart';
import 'package:unittest/html_config.dart' show useHtmlConfiguration;
import 'common.dart';

void main() {
  useHtmlConfiguration();

  initPolymer().then((zone) => zone.run(() => Polymer.onReady.then((_) {
    var a1 = querySelector('#autogrow1') as PaperAutogrowTextarea;
    var t1 = querySelector('#textarea1') as TextAreaElement;

    group('basic', () {

      tearDown(() {
        t1.value = '';
        dispatchInputEvent(t1);
        a1.rows = 1;
        a1.maxRows = 0;
        return flushLayoutAndRender();
      });

      test('empty input has height', () {
        expect(a1.offsetHeight, greaterThan(0));
      });

      // Dart Note: We don't replicate the 'accepts number input' test since
      // only Strings are valid values for inputs and textareas in dart.

      test('grows with more rows of input', () {
        t1.value = 'foo\nbar';
        dispatchInputEvent(t1);
        var h1 = a1.offsetHeight;
        t1.value = 'foo\nbar\nbaz';
        dispatchInputEvent(t1);
        return flushLayoutAndRender().then((_) {
          var h2 = a1.offsetHeight;
          expect(h2, greaterThan(h1));
          expect(a1.getBoundingClientRect(), t1.getBoundingClientRect());
        });
      });

      test('honors the rows attribute', () {
        var h1 = a1.offsetHeight;
        a1.rows = 2;
        return flushLayoutAndRender().then((_) {
          var h2 = a1.offsetHeight;
          between(h2, h1, 3 * h1);
        });
      });

      test('honors the maxRows attribute', () {
        var h1 = a1.offsetHeight;
        a1.maxRows = 2;
        t1.value = 'foo\nbar\nbaz\nzot';
        dispatchInputEvent(t1);
        return flushLayoutAndRender().then((_) {
          var h2 = a1.offsetHeight;
          expect(h2, lessThan(3 * h1));
        });
      });

      test('mirror text is visibility:hidden', () {
        expect(a1.$['mirror'].getComputedStyle().visibility, 'hidden');
      });

      test('grows with a long word', () {
        var h1 = a1.offsetHeight;

        t1.value = new List<String>.filled(1000, '').join("P");
        dispatchInputEvent(t1);

        return flushLayoutAndRender().then((_) {
          var h2 = a1.offsetHeight;
          expect(h2, greaterThan(h1));
          expect(a1.getBoundingClientRect(), t1.getBoundingClientRect());
        });
      });
    });
  })));
}

void dispatchInputEvent(Element target) {
  var e = new Event('input', canBubble: true);
  target.dispatchEvent(e);
}

void between(num val, num val1, num val2) {
  expect(val > val1 && val < val2, isTrue);
}
