//Copyright (c) 2014 The Polymer Project Authors. All rights reserved.
//This code may only be used under the BSD style license found at http://polymer.github.io/LICENSE.txt
//The complete set of authors may be found at http://polymer.github.io/AUTHORS.txt
//The complete set of contributors may be found at http://polymer.github.io/CONTRIBUTORS.txt
//Code distributed by Google as part of the polymer project is also
//subject to an additional IP rights grant found at http://polymer.github.io/PATENTS.txt

library core_menu_button.test;

import "dart:html";

import "package:polymer/polymer.dart";
import "package:unittest/unittest.dart";
import "package:unittest/html_config.dart" show useHtmlConfiguration;
import "package:core_elements/core_menu_button.dart" show CoreMenuButton;
import 'common.dart';

class MyModel extends Object with Observable {
  @observable
  bool showButton;
}

void main() {
  useHtmlConfiguration();

  initPolymer().then((zone) => zone.run(() {
    return Polymer.onReady.then((_) {

      test('overlay should be removed when button is removed while open', () {
        var template =
            querySelector('#removeOpenedOverlay') as AutoBindingElement;
        var model = template.model = new MyModel()
            ..showButton = true;
        return flushLayoutAndRender().then((_) {
          var menuButton = querySelector('#menuButton') as CoreMenuButton;
          menuButton.opened = true;
          // overlay should be in the DOM
          return flushLayoutAndRender().then((_) {
            var menuButton = querySelector('#menuButton') as CoreMenuButton;
            var dropdown = querySelector('#dropdown');
            expect(dropdown, isNotNull);
            var menuItems = dropdown.querySelectorAll('core-item');
            expect(menuItems.toList().length, equals(4));
            model.showButton = false;
            // button and overlay should not be in the DOM anymore
            return flushLayoutAndRender().then((_) {
              menuButton = querySelector('#menuButton');
              expect(menuButton, isNull);
              dropdown = querySelector('#dropdown');
              expect(dropdown, isNull,
                  reason: 'dropdown should have been removed');
            });
          });
        });

      });

    });
  }));
}
