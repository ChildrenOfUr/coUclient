//Copyright (c) 2014 The Polymer Project Authors. All rights reserved.
//This code may only be used under the BSD style license found at http://polymer.github.io/LICENSE.txt
//The complete set of authors may be found at http://polymer.github.io/AUTHORS.txt
//The complete set of contributors may be found at http://polymer.github.io/CONTRIBUTORS.txt
//Code distributed by Google as part of the polymer project is also
//subject to an additional IP rights grant found at http://polymer.github.io/PATENTS.txt
library paper_elements.test.paper_input_test;

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
    return Polymer.onReady.then((_) {
      test('change event bubbles', () {
        var node = document.getElementById('default');
        var listener;
        listener = node.on['change'].listen((_) => listener.cancel());

        var input = node.shadowRoot.querySelector('input');
        input.dispatchEvent(new Event('change', canBubble: true));
      });

      test('cannot tap on disabled input', () {
        var node = document.getElementById('disabled');
        node.dispatchEvent(new MouseEvent('Down'));
        node.dispatchEvent(new MouseEvent('Up'));
        return flushLayoutAndRender().then((_) {
          expect(activeElement(), isNot(node.shadowRoot.querySelector('input')));
        });
      });
    });
  }));
}
