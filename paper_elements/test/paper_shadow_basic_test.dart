//Copyright (c) 2014 The Polymer Project Authors. All rights reserved.
//This code may only be used under the BSD style license found at http://polymer.github.io/LICENSE.txt
//The complete set of authors may be found at http://polymer.github.io/AUTHORS.txt
//The complete set of contributors may be found at http://polymer.github.io/CONTRIBUTORS.txt
//Code distributed by Google as part of the polymer project is also
//subject to an additional IP rights grant found at http://polymer.github.io/PATENTS.txt

library paper_shadow.basic_test;

import 'dart:async';
import 'dart:html';
import 'package:paper_elements/paper_shadow.dart';
import 'package:polymer/polymer.dart';
import 'package:unittest/unittest.dart';
import 'package:unittest/html_config.dart' show useHtmlConfiguration;

void main() {
  useHtmlConfiguration();

  initPolymer().then((zone) => zone.run(() {
    Polymer.onReady.then((_) {
      var s1 = querySelector('#s1') as PaperShadow;

      test('default', () {
        expect(s1.$['shadow-bottom'].getComputedStyle().boxShadow,
            isNot('none'));
      });

      test('shadows are pointer-events: none', () {
        var done = new Completer();
        var foo = querySelector('#foo');
        document.onClick.take(1).listen((e) {
          expect(e.target, foo);
          done.complete();
        });
        foo.click();
        return done.future;
      });

    });
  }));
}
