//Copyright (c) 2014 The Polymer Project Authors. All rights reserved.
//This code may only be used under the BSD style license found at http://polymer.github.io/LICENSE.txt
//The complete set of authors may be found at http://polymer.github.io/AUTHORS.txt
//The complete set of contributors may be found at http://polymer.github.io/CONTRIBUTORS.txt
//Code distributed by Google as part of the polymer project is also
//subject to an additional IP rights grant found at http://polymer.github.io/PATENTS.txt

library core_shared_lib.test;

import 'dart:async';
import 'dart:html';

import 'package:polymer/polymer.dart';
import 'package:unittest/unittest.dart';
import 'package:unittest/html_config.dart' show useHtmlConfiguration;

void main() {
  useHtmlConfiguration();

  initPolymer().then((zone) => zone.run(() {
    return Polymer.onReady.then((_) {

      group('core-shared-lib', () {

        test('basic', () {
          var count = 0;
          var done = expectAsync((){});
          (querySelector('#t') as AutoBindingElement).model = {};
          var s = document.on['core-shared-lib-load'].listen((e) {
            if(++count == 2) {
              done();
            } else {
              expect(count < 2, isTrue);
              return new Future(() {}).then((_) => new Future(() {})).then((_) {
                (document.querySelector('#t') as AutoBindingElement).model = {};
              });
            }
          });
        });

      });

    });
  }));
}

