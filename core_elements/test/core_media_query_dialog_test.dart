//Copyright (c) 2014 The Polymer Project Authors. All rights reserved.
//This code may only be used under the BSD style license found at http://polymer.github.io/LICENSE.txt
//The complete set of authors may be found at http://polymer.github.io/AUTHORS.txt
//The complete set of contributors may be found at http://polymer.github.io/CONTRIBUTORS.txt
//Code distributed by Google as part of the polymer project is also
//subject to an additional IP rights grant found at http://polymer.github.io/PATENTS.txt

library core_media_query.test.dialog;

import 'dart:async' as async;
import 'dart:html' as dom;
import 'package:polymer/polymer.dart';

class MyModel extends Object with Observable {
  int _counter = 0;
  @observable
  String phoneQuery;

  @observable
  String tabletQuery;

  bool matchesPhone;

  bool matchesTablet;

  void coreMediaChangeHandler(_) {
    dom.window.opener.postMessage({
      'message_id': _counter,
      'phone': matchesPhone,
      'tablet': matchesTablet,
      'width' : dom.window.innerWidth
    }, '*');
    _counter++;
  }
}

void main() {
  initPolymer().then((zone) => zone.run(() {
    return Polymer.onReady.then((_) {

      var template =
          dom.document.querySelector('#simpleMatch') as AutoBindingElement;
      var model = template.model = new MyModel();
      // assign the model and change the values later to verify data binding
      new async.Future(() {
        model
          ..tabletQuery = '(min-width: 600px)'
          ..phoneQuery = '(max-width: 599px)';
      });
    });
  }));
}
