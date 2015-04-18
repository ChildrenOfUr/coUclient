//Copyright (c) 2014 The Polymer Project Authors. All rights reserved.
//This code may only be used under the BSD style license found at http://polymer.github.io/LICENSE.txt
//The complete set of authors may be found at http://polymer.github.io/AUTHORS.txt
//The complete set of contributors may be found at http://polymer.github.io/CONTRIBUTORS.txt
//Code distributed by Google as part of the polymer project is also
//subject to an additional IP rights grant found at http://polymer.github.io/PATENTS.txt

library core_localstorage_dart.value_binding_test;

import 'dart:convert';
import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:unittest/unittest.dart';
import 'package:unittest/html_config.dart' show useHtmlConfiguration;
import 'common.dart';

@CustomTag('x-test')
class XTest extends PolymerElement {
  @published var value;
  XTest.created() : super.created();
}

@CustomTag('x-foo')
class XFoo extends PolymerElement {
  @published var value;
  XFoo.created() : super.created();
}

void main() {
  useHtmlConfiguration();
  window.localStorage['core-localstorage-test'] = '{"foo":"bar"}';

  initPolymer().then((zone) => zone.run(() {
    return Polymer.onReady.then((_) {
      var xTest = document.querySelector('x-test') as XTest;

      group('basic', () {

        test('initial value', () {
          expect(xTest.value, isNotNull);
          expect(xTest.value['foo'], 'bar');
        });

        test('set value', () {
          var newValue = {'foo': 'zot'};
          xTest.value = newValue;
          return flushLayoutAndRender().then((_) {
            var v = window.localStorage[xTest.$['localstorage'].name];
            v = JSON.decode(v);
            expect(v['foo'], newValue['foo']);
          });
        });

        test('save', () {
          xTest.value['foo'] = 'quux';
          xTest.$['localstorage'].save();
          return flushLayoutAndRender().then((_) {
            var v = window.localStorage[xTest.$['localstorage'].name];
            v = JSON.decode(v);
            expect(v['foo'], 'quux');
          });
        });

      });

    });
  }));
}

