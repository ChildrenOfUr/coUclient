//Copyright (c) 2014 The Polymer Project Authors. All rights reserved.
//This code may only be used under the BSD style license found at http://polymer.github.io/LICENSE.txt
//The complete set of authors may be found at http://polymer.github.io/AUTHORS.txt
//The complete set of contributors may be found at http://polymer.github.io/CONTRIBUTORS.txt
//Code distributed by Google as part of the polymer project is also
//subject to an additional IP rights grant found at http://polymer.github.io/PATENTS.txt
library core_ajax.progress_test;

import 'dart:async';
import 'dart:html';
import 'package:core_elements/core_ajax_dart.dart';
import 'package:polymer/polymer.dart';
import 'package:unittest/unittest.dart';
import 'package:unittest/html_config.dart' show useHtmlConfiguration;

Completer done = new Completer();

void main() {
  useHtmlConfiguration();

  initPolymer().then((zone) => zone.run(() {
    return Polymer.onReady.then((_) {

      test('progress', () {
        var ajax = querySelector('core-ajax-dart') as CoreAjax;

        expect(ajax.loading, false);
        expect(ajax.progress, isNull);
        ajax.url = 'core_ajax_dart.json';

        var gotProgress = false;
        // Need to wait two microtasks, one for url attribute change to be
        // noticed and one for the `go` job to be scheduled and ran.
        new Future(() {}).then((_) => new Future(() {})).then((_) {
          expect(ajax.activeRequest, isNotNull);
          expect(ajax.loading, true);
          ajax.activeRequest.onProgress.listen((ProgressEvent e) {
            expect(ajax.progress, isNotNull);
            expect(ajax.progress.loaded, e.loaded);
            expect(ajax.progress.lengthComputable, e.lengthComputable);
            expect(ajax.progress.total, e.total);
            gotProgress = true;
          });
          ajax.onCoreComplete.listen((_) {
            expect(ajax.loading, false);
            expect(gotProgress, true);
            done.complete();
          });
        });
        return done.future;
      });
    });
  }));
}
