//Copyright (c) 2014 The Polymer Project Authors. All rights reserved.
//This code may only be used under the BSD style license found at http://polymer.github.io/LICENSE.txt
//The complete set of authors may be found at http://polymer.github.io/AUTHORS.txt
//The complete set of contributors may be found at http://polymer.github.io/CONTRIBUTORS.txt
//Code distributed by Google as part of the polymer project is also
//subject to an additional IP rights grant found at http://polymer.github.io/PATENTS.txt

library core_dropdown_a11y.test;

import 'dart:html';
import 'package:core_elements/core_dropdown_menu.dart';
import 'package:core_elements/core_menu.dart';
import 'package:polymer/polymer.dart';
import 'package:unittest/unittest.dart';
import 'package:unittest/html_config.dart' show useHtmlConfiguration;
import 'common.dart';

CoreDropdownMenu dropdown;
CoreMenu menu;

void main() {
  useHtmlConfiguration();

  initPolymer().then((zone) => zone.run(() {
    return Polymer.onReady.then((_) {
       dropdown = querySelector('#dropdown1') as CoreDropdownMenu;
       menu = querySelector('#menu1') as CoreMenu;

       test('aria-disabled is set', () {
         expect(dropdown.attributes.containsKey('aria-disabled'), false);
         dropdown.setAttribute('disabled', '');
         return flushLayoutAndRender().then((_) {
           expect(dropdown.attributes.containsKey('aria-disabled'), true);
           dropdown.attributes.remove('disabled');
         });
       });

    });
  }));
}

