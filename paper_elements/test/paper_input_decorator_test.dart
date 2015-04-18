//Copyright (c) 2014 The Polymer Project Authors. All rights reserved.
//This code may only be used under the BSD style license found at http://polymer.github.io/LICENSE.txt
//The complete set of authors may be found at http://polymer.github.io/AUTHORS.txt
//The complete set of contributors may be found at http://polymer.github.io/CONTRIBUTORS.txt
//Code distributed by Google as part of the polymer project is also
//subject to an additional IP rights grant found at http://polymer.github.io/PATENTS.txt

library paper_elements.test.paper_input_decorator_test;

import 'dart:async';
import 'dart:html';
import 'dart:js';
import 'package:core_elements/core_input.dart';
import 'package:core_elements/core_style.dart';
import 'package:paper_elements/paper_input_decorator.dart';
import 'package:paper_elements/paper_char_counter.dart';
import 'package:polymer/polymer.dart';
import 'package:unittest/unittest.dart';
import 'package:unittest/html_config.dart' show useHtmlConfiguration;
import 'common.dart';

void main() {
  useHtmlConfiguration();

  initPolymer().then((zone) => zone.run(() {
    Polymer.onReady.then((_) {
      test('label is invisible if value is not null', () {
        var result = cloneAndAppendTemplate('default');
        result.input.value = 'foobar';
        result.decorator.updateLabelVisibility(result.input.value);
        expect(result.decorator.jsElement['_labelVisible'], isFalse);
      });

      test('label is invisible if floating label and focused', () {
        var nodes = cloneAndAppendTemplate('floating-label');
        return ensureFocus(nodes.input).then((_) {
          expect(nodes.decorator.jsElement['_labelVisible'], isFalse);
        });
      });

      test('label is invisible if value = 0', () {
        var nodes = cloneAndAppendTemplate('default');
        nodes.input.value = '0';
        nodes.decorator.updateLabelVisibility(nodes.input.value);
        expect(nodes.decorator.jsElement['_labelVisible'], isFalse);
      });

      test('labelVisible overrides label visibility', () {
        var nodes = cloneAndAppendTemplate('default');
        nodes.decorator.labelVisible = false;
        expect(nodes.input.value, isEmpty);
        expect(nodes.decorator.jsElement['_labelVisible'], isFalse);
      });

      test('labelVisible works in an attribute', () {
        var nodes = cloneAndAppendTemplate('label-visible-false');
        expect(nodes.decorator.jsElement['_labelVisible'], isNot(true));
      });

      test('can create inputs lazily', () {
        var nodes = cloneAndAppendTemplate('no-input');
        var input = document.createElement('input');
        input.value = 'foobar';
        nodes.decorator.append(input);
        expect(nodes.decorator.jsElement['_labelVisible'], isNot(true));
      });

      test('tapping on floating label focuses input', () {
        var nodes = cloneAndAppendTemplate('floating-label-filled');
        var floatedLabel =
            nodes.decorator.shadowRoot.querySelector('.floated-label');
        floatedLabel.dispatchEvent(new MouseEvent('Down'));
        floatedLabel.dispatchEvent(new MouseEvent('Up'));
        return flushLayoutAndRender().then((_) {
          assertNodeHasFocus(nodes.input);
        });
      });

      test('floating label and the error message are the same color', () {
        var nodes = cloneAndAppendTemplate('error');
        return flushLayoutAndRender().then((_) {
          var s1 = nodes.decorator.$['floatedLabelText'].getComputedStyle();
          var s2 = nodes.decorator.shadowRoot.querySelector('.error-text')
              .getComputedStyle();
          expect(s1.color, s2.color);
        });
      });

      test('auto-validate input validates after creation', () {
        var nodes = cloneAndAppendTemplate('auto-validate');
        return flushLayoutAndRender().then((_) {
          expect(nodes.decorator.isInvalid, isTrue);
        });
      });

      test('char-counter is invalid when input exceeds maxLength', () {
        var nodes = cloneAndAppendTemplate('char-counter');
        var counter =
            nodes.decorator.querySelector('.counter') as PaperCharCounter;
        expect(nodes.input.maxLength, 5);
        nodes.input.id = "the-input";
        counter.target = "the-input";
        return new Future(() {}).then((_) {
          // TODO(jakemac): Remove when the following issue is fixed
          // https://github.com/Polymer/paper-input/issues/173
          counter.jsElement.callMethod('ready', []);
          return flushLayoutAndRender().then((_) {
            nodes.input.value = "nanananabatman";
            nodes.input.dispatchEvent(new Event('input'));
            return flushLayoutAndRender().then((_) {
              expect(counter.jsElement['_isCounterInvalid'], isTrue);
              expect(nodes.decorator.isInvalid, isTrue);
              expect(counter.classes.contains('invalid'), isTrue);
            });
          });
        });
      });

      test('char-counter is visible', () {
        var nodes = cloneAndAppendTemplate('char-counter');
        var counter =
            nodes.decorator.querySelector('.counter') as PaperCharCounter;
        expect(nodes.input.maxLength, isNot(0));
        expect(nodes.decorator.error, isEmpty);
        nodes.input.id= "the-input";
        counter.target = "the-input";
        // TODO(jakemac): Remove when the following issue is fixed
        // https://github.com/Polymer/paper-input/issues/173
        counter.jsElement.callMethod('ready', []);
        return flushLayoutAndRender().then((_) {
          expect(counter.shadowRoot.querySelector('.counter-text').hidden,
              isFalse);
        });
      });

      group('a11y', () {
        test('aria-label set on input', () {
          var nodes = cloneAndAppendTemplate('default');
          return flushLayoutAndRender().then((_) {
            expect(nodes.input.getAttribute('aria-label'),
                nodes.decorator.label);
          });
        });
      });
    });
  }));
}

class AppendResult {
  final PaperInputDecorator decorator;
  final InputElement input;

  AppendResult(this.decorator, this.input);
}

AppendResult cloneAndAppendTemplate(String templateId) {
  var tmpl = querySelector('template#$templateId');
  var frag = document.importNode(tmpl.content, true);
  var node = frag.children.first as PaperInputDecorator;
  document.body.append(frag);
  return new AppendResult(node, node.querySelector('input') as InputElement);
}
