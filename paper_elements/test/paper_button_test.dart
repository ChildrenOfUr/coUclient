//Copyright (c) 2014 The Polymer Project Authors. All rights reserved.
//This code may only be used under the BSD style license found at http://polymer.github.io/LICENSE.txt
//The complete set of authors may be found at http://polymer.github.io/AUTHORS.txt
//The complete set of contributors may be found at http://polymer.github.io/CONTRIBUTORS.txt
//Code distributed by Google as part of the polymer project is also
//subject to an additional IP rights grant found at http://polymer.github.io/PATENTS.txt

library paper_elements.test.paper_button_test;

import 'dart:async';
import 'dart:html';
import 'dart:js';
import 'package:paper_elements/paper_button.dart';
import 'package:paper_elements/paper_shadow.dart';
import 'package:polymer/polymer.dart';
import 'package:unittest/unittest.dart';
import 'package:unittest/html_config.dart' show useHtmlConfiguration;
import 'common.dart';

void main() {
  useHtmlConfiguration();

  initPolymer().then((zone) => zone.run(() {
    return Polymer.onReady.then((_) {
      var b1 = document.getElementById('button1') as PaperButton;

      test('can set raised imperatively', () {
        expect(b1.shadowRoot.querySelector('paper-shadow'), isNull);
        b1.raised = true;
        return flushLayoutAndRender().then((_) {
          var shadow =
              b1.shadowRoot.querySelector('paper-shadow') as PaperShadow;
          expect(shadow, isNotNull);
        });
      });

      test('can set noink dynamically', () {
        var button = document.getElementById('button2') as PaperButton;
        button.$['lastEvent'] = {'x': 100, 'y': 100};
        button.$['ripple'] = {
          'downAction': () {
            expect(true, isFalse);
          },
          'upAction': () {
            expect(true, isFalse);
          }
        };
        button.setAttribute('noink', '');
        button.dispatchEvent(new Event('down'));
        button.dispatchEvent(new Event('up'));
        // would throw if it tries to ripple
        return new Future.delayed(new Duration(milliseconds: 10));
      });

      group('a11y', () {
        test('aria role is a button', () {
          expect('button', b1.attributes['role']);
        });

        test('aria-disabled is set', () {
          var button = document.getElementById('disabled') as PaperButton;
          expect(button.attributes['aria-disabled'], isNotNull);
          button.attributes.remove('disabled');
          context['Polymer'].callMethod('flush', []);
          return flushLayoutAndRender().then((_) {
            expect(button.attributes['aria-disabled'], isNull);
          });
        });

        test('space triggers the button', () {
          var ev = new CustomEvent('keydown', detail: {'key': 'space'});
          var sawClick = false;
          var listener = b1.on['click'].listen((_) => sawClick = true);
          b1.dispatchEvent(ev);
          expect(sawClick, isTrue);
          listener.cancel();
        });

        test('enter triggers the button', () {
          var ev = new CustomEvent('keydown', detail: {'key': 'enter'});
          var sawClick = false;
          var listener = b1.on['click'].listen((_) => sawClick = true);
          b1.dispatchEvent(ev);
          expect(sawClick, isTrue);
          listener.cancel();
        });
      });
    });
  }));
}
