//Copyright (c) 2014 The Polymer Project Authors. All rights reserved.
//This code may only be used under the BSD style license found at http://polymer.github.io/LICENSE.txt
//The complete set of authors may be found at http://polymer.github.io/AUTHORS.txt
//The complete set of contributors may be found at http://polymer.github.io/CONTRIBUTORS.txt
//Code distributed by Google as part of the polymer project is also
//subject to an additional IP rights grant found at http://polymer.github.io/PATENTS.txt

library core_animated_pages.test;

import 'dart:html' as dom;
import 'dart:async' as async;
import 'package:polymer/polymer.dart';
import 'package:unittest/unittest.dart';
import 'package:unittest/html_config.dart' show useHtmlConfiguration;

class BasicModel extends Observable {
  var _done = expectAsync(() {}, count: 4, id: 'transistion-end event');

  @observable
  int selected = 0;

  String transitions = "slide-from-right";

  final _numPages = 3;
  var _transitionCounter = 0;

  void transitionEndHandler(e) {
    _transitionCounter++;
    // stop after _numPages transitions (+1 from the test body)
    if(_transitionCounter <= _numPages) {
      selected = (selected + 1) % _numPages;
    }
    _done();
  }
}

void main() {
  useHtmlConfiguration();

  initPolymer().then((zone) => zone.run(() {
    return Polymer.onReady.then((_) {

      group('core-animated-pages', () {

        test('basic', () {
          var template = dom.document.querySelector('#basic') as AutoBindingElement;
          var model = template.model = new BasicModel();

          new async.Future(() {
            model.selected = 1;
          });
        });

      });

    });
  }));
}
