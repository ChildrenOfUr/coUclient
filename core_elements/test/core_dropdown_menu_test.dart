//Copyright (c) 2014 The Polymer Project Authors. All rights reserved.
//This code may only be used under the BSD style license found at http://polymer.github.io/LICENSE.txt
//The complete set of authors may be found at http://polymer.github.io/AUTHORS.txt
//The complete set of contributors may be found at http://polymer.github.io/CONTRIBUTORS.txt
//Code distributed by Google as part of the polymer project is also
//subject to an additional IP rights grant found at http://polymer.github.io/PATENTS.txt

library core_dropdown.test;

import 'dart:html';
import 'package:core_elements/core_dropdown_menu.dart';
import 'package:core_elements/core_menu.dart';
import 'package:polymer/polymer.dart';
import 'package:unittest/unittest.dart';
import 'package:unittest/html_config.dart' show useHtmlConfiguration;
import 'common.dart';

CoreDropdownMenu dropdown;
CoreMenu menu;
var label;

void main() {
  useHtmlConfiguration();

  initPolymer().then((zone) => zone.run(() {
    return Polymer.onReady.then((_) {
      dropdown = querySelector('#dropdown1') as CoreDropdownMenu;
      menu = querySelector('#menu1') as CoreMenu;
      label = dropdown.shadowRoot.querySelector('#label');

      test('shows the label when nothing selected', () {
        menu.selected = null;
        return flushLayoutAndRender().then((_) {
          expect(dropdown.shadowRoot.querySelector('#label').text,
             dropdown.label);
        });
      });

      test('shows the selected item', () {
        menu.selected = 2;
        return flushLayoutAndRender().then((_) {
          expect(label.text, menu.selectedItem.text);
        });
      });

      test('can clear the selected item', () {
        menu.selected = 2;
        return flushLayoutAndRender().then((_) {
          expect(label.text, menu.selectedItem.text);

          menu.selected = null;
          return flushLayoutAndRender().then((_) {
            expect(label.text, dropdown.label);
          });
        });
      });

      test('use the valueattr attribute', () {
        menu.valueattr = 'foo';
        menu.selected = 'l';
        return flushLayoutAndRender().then((_) {
          expect(label.text, menu.selectedItem.text);
        });
      });

    });
  }));
}
