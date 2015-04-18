//Copyright (c) 2014 The Polymer Project Authors. All rights reserved.
//This code may only be used under the BSD style license found at http://polymer.github.io/LICENSE.txt
//The complete set of authors may be found at http://polymer.github.io/AUTHORS.txt
//The complete set of contributors may be found at http://polymer.github.io/CONTRIBUTORS.txt
//Code distributed by Google as part of the polymer project is also
//subject to an additional IP rights grant found at http://polymer.github.io/PATENTS.txt

library paper_fab.basic_test;

import 'dart:html';
import 'package:paper_elements/paper_fab.dart';
import 'package:polymer/polymer.dart';
import 'package:unittest/unittest.dart';
import 'package:unittest/html_config.dart' show useHtmlConfiguration;

void main() {
  useHtmlConfiguration();

  initPolymer().then((zone) => zone.run(() {
    Polymer.onReady.then((_) {
      var f1 = document.getElementById('fab1') as PaperFab;

      test('renders correctly independent of line height', () {
        expect(centerOf(f1.jsElement['\$']['icon']), centerOf(f1));
      });

    });
  }));
}

centerOf(Element element) {
  var rect = element.getBoundingClientRect();
  return
    {'left': rect.left + rect.width / 2, 'top': rect.top + rect.height / 2};
}
