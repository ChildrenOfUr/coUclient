//Copyright (c) 2014 The Polymer Project Authors. All rights reserved.
//This code may only be used under the BSD style license found at http://polymer.github.io/LICENSE.txt
//The complete set of authors may be found at http://polymer.github.io/AUTHORS.txt
//The complete set of contributors may be found at http://polymer.github.io/CONTRIBUTORS.txt
//Code distributed by Google as part of the polymer project is also
//subject to an additional IP rights grant found at http://polymer.github.io/PATENTS.txt

library paper_icon_button.basic_test;

import 'dart:html';
import 'package:paper_elements/paper_icon_button.dart';
import 'package:polymer/polymer.dart';
import 'package:unittest/unittest.dart';
import 'package:unittest/html_config.dart' show useHtmlConfiguration;

void main() {
  useHtmlConfiguration();

  initPolymer().then((zone) => zone.run(() {
    Polymer.onReady.then((_) {
      var b1 = document.getElementById('button1') as PaperIconButton;

      test('renders correctly independent of font size', () {
        expect(centerOf(b1.$['icon']), centerOf(b1));
      });

    });
  }));
}

centerOf(Element element) {
  var rect = element.getBoundingClientRect();
  return {
      'left': (rect.left + rect.width / 2).floor(),
      'top': (rect.top + rect.height / 2).floor()
  };
}
