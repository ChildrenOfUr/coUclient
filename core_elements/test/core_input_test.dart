//Copyright (c) 2014 The Polymer Project Authors. All rights reserved.
//This code may only be used under the BSD style license found at http://polymer.github.io/LICENSE.txt
//The complete set of authors may be found at http://polymer.github.io/AUTHORS.txt
//The complete set of contributors may be found at http://polymer.github.io/CONTRIBUTORS.txt
//Code distributed by Google as part of the polymer project is also
//subject to an additional IP rights grant found at http://polymer.github.io/PATENTS.txt

library core_input.test;

import 'dart:html';

import 'package:polymer/polymer.dart';
import 'package:unittest/unittest.dart';
import 'package:unittest/html_config.dart' show useHtmlConfiguration;
import 'package:core_elements/core_input.dart';
import 'common.dart';

class MyModel extends Object with Observable {
  @observable
  String stringValue;

  @observable
  bool isInvalid;

  int _changeHandlerCount = 0;
  int _inputHandlerCount = 0;

  changeHandler(e) => _changeHandlerCount++;
  inputHandler(e) => _inputHandlerCount++;
}

const INITIAL_VALUE = 'Initial value';
const INPUT_VALUE = 'Input value';
const NUMBER_VALUE = '1234';
const PASSWORD_VALUE = 'My secret password 19 !\'§\$';

void main() {
  useHtmlConfiguration();

  initPolymer().then((zone) => zone.run(() {
    return Polymer.onReady.then((_) {

      group('core-input', () {
        // TODO(zoechi) test required http://stackoverflow.com/questions/24572472
        test('type="text"', () {
          var input = querySelector('#typeText') as CoreInput;
          expect(input.value, equals('Some content'));
        });

        test('bind value', () {
          var template =
              querySelector('#bindValueTemplate') as AutoBindingElement;
          var model = template.model = new MyModel()
              ..stringValue = INITIAL_VALUE;
          return flushLayoutAndRender().then((_) {
            var input = querySelector('#bindValue') as CoreInput;
            input.value = INPUT_VALUE;
            dispatchInputEvent(input);
            expect(model.stringValue, equals(INPUT_VALUE));
            final MODEL_VALUE = 'Model value';
            model.stringValue = MODEL_VALUE;
            return flushLayoutAndRender().then((_) {
              expect(input.value, equals(MODEL_VALUE));
            });
          });
        });

        test('change and input event', () {
          var template =
              querySelector('#changeAndInputEventTemplate') as AutoBindingElement;
          var model = template.model = new MyModel();

          return flushLayoutAndRender().then((_) {
            var input = querySelector('#changeAndInputEvent') as CoreInput;
            input.dispatchEvent(new CustomEvent('change', detail: {'source': 'changeAndInputEventTest}'}));
            input.dispatchEvent(new CustomEvent('input', canBubble: true, detail: {'source': 'changeEventTest'}));
            expect(model._changeHandlerCount, 1);
            expect(model._inputHandlerCount, 1);
          });
        });

        test('validate number', () {
          var template =
              querySelector('#validateNumberTemplate') as AutoBindingElement;
          var model = template.model = new MyModel()
              ..stringValue = INITIAL_VALUE;

          return flushLayoutAndRender().then((_) {
            var input = querySelector('#validateNumber') as CoreInput;
            input.value = INPUT_VALUE;
            dispatchInputEvent(input);
            expect(model.stringValue, equals(INPUT_VALUE));
            expect(input.checkValidity(), isFalse);

            model.stringValue = NUMBER_VALUE;
            return flushLayoutAndRender().then((_) {
              expect(input.value, equals(NUMBER_VALUE));
              expect(input.checkValidity(), isTrue);
            });
          });
        });

        test('type="password"', () {
          var template =
              querySelector('#passwordTemplate') as AutoBindingElement;
          var model = template.model = new MyModel()..stringValue = '';

          return flushLayoutAndRender().then((_) {
            var input = querySelector('#password') as CoreInput;
            expect(input.attributes['type'].toLowerCase(), equals('password'));

            input.value = PASSWORD_VALUE;
            dispatchInputEvent(input);
            expect(model.stringValue, equals(PASSWORD_VALUE));

            final MODEL_VALUE = 'another password';
            model.stringValue = MODEL_VALUE;
            return flushLayoutAndRender().then((_) {
              expect(input.value, equals(MODEL_VALUE));
              expect(input.checkValidity(), isTrue);
            });
          });
        });

      });

    });
  }));
}

void dispatchInputEvent(InputElement target) {
  var e = new Event('input', canBubble: true);
  target.dispatchEvent(e);
}
