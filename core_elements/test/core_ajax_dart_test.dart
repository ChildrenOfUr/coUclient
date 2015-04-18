//Copyright (c) 2014 The Polymer Project Authors. All rights reserved.
//This code may only be used under the BSD style license found at http://polymer.github.io/LICENSE.txt
//The complete set of authors may be found at http://polymer.github.io/AUTHORS.txt
//The complete set of contributors may be found at http://polymer.github.io/CONTRIBUTORS.txt
//Code distributed by Google as part of the polymer project is also
//subject to an additional IP rights grant found at http://polymer.github.io/PATENTS.txt
library core_ajax.test;

import "dart:async";
import "dart:html";
import "package:core_elements/core_ajax_dart.dart";
import "package:polymer/polymer.dart";
import "package:unittest/unittest.dart";
import "package:unittest/html_config.dart" show useHtmlConfiguration;

CoreAjax ajax;
Completer done;

void main() {
  useHtmlConfiguration();

  initPolymer().then((zone) => zone.run(() {
    return Polymer.onReady.then((_) {
      ajax = querySelector('core-ajax-dart') as CoreAjax;

      group("handleAs", () {

        setUp(() {
          reset();
        });

        test('txt', () {
          ajax..url = 'core_ajax_dart.txt'
              ..auto = true;
          ajax.onCoreResponse.take(1).listen((_) {
            expect(ajax.response, 'test text\n');
            done.complete();
          });
          return done.future;
        });

        test('xml', () {
          ajax..handleAs = 'xml'
              ..url = 'core_ajax_dart.xml'
              ..auto = true;
          ajax.onCoreResponse.take(1).listen((_) {
            var response = ajax.response;
            expect(response, isNotNull);
            expect(response is Document, true);
            expect(response.querySelector('note body q').text, 'Feed me!');
            expect(response.querySelector('to').text, 'AJ');
            done.complete();
          });
          return done.future;
        });

        test('json', () {
          ajax..handleAs = 'json'
              ..url = 'core_ajax_dart.json'
              ..auto = true;
          ajax.onCoreResponse.take(1).listen((_) {
            var response = ajax.response;
            expect(response, isNotNull);
            expect(response is Map, true);
            expect(response['object']['list'][1], 3);
            expect(response['object']['list'][2]['key'], 'value');
            done.complete();
          });
          return done.future;
        });

        // TODO(jakemac): arraybuffer test

      });

      group('auto', () {

        setUp(() {
          reset();
          ajax..url = 'core_ajax_dart.txt'
              ..auto = true;
          var firstDone = new Completer();
          ajax.onCoreResponse.take(1).listen((_) {
            firstDone.complete();
          });
          return firstDone.future;
        });

        test('url change should trigger request', () {
          ajax.url = 'core_ajax_dart.json';
          ajax.onCoreResponse.take(1).listen((_) {
            done.complete();
          });
          return done.future;
        });

        test('params change should trigger request', () {
          ajax.params = {'param': 'value'};
          ajax.onCoreResponse.take(1).listen((_) {
            done.complete();
          });
          return done.future;
        });

        test('body change should trigger request', () {
          ajax..method = 'POST'
              ..body = 'bodystuff';
          // We use complete instead of response here, depending on how you are
          // running the tests POST may not be valid.
          ajax.onCoreComplete.take(1).listen((_) {
            done.complete();
          });
          return done.future;
        });

      });

      group('events', () {
        var responseCalled;
        var errorCalled;
        var subscriptions;

        setUp(() {
          reset();
          responseCalled = false;
          errorCalled = false;
          ajax..handleAs = 'text'
              ..url = 'core_ajax_dart.txt';

          // Subscribe to error/response/complete events and track what gets
          // called.
          subscriptions = [
            ajax.onCoreError.take(1).listen((_) {
              errorCalled = true;
            }),
            ajax.onCoreResponse.take(1).listen((_) {
              responseCalled = true;
            }),
            ajax.onCoreComplete.take(1).listen((_) {
              // Give other events a chance to fire fired and throw.
              new Future(() {}).then((_) {
                subscriptions.forEach((s) => s.cancel());
                subscriptions = null;
                done.complete();
              });
            })
          ];
        });

        test('successful request', () {
          ajax.go();
          return done.future.then((_) {
            expect(responseCalled, true,
                reason: 'core-response should fire on success');
            expect(errorCalled, false,
                reason: 'core-error should not fire on success');
          });
        });

        test('failed request', () {
          ajax..url = 'bad_url'
              ..go();
          return done.future.then((_) {
            expect(responseCalled, false,
                reason: 'core-response should not fire on failure');
            expect(errorCalled, true,
                reason: 'core-error should fire on failure');
          });
        });

      });

    });
  }));
}

void reset() {
  ajax..auto = false
      ..url = ''
      ..params = ''
      ..handleAs = 'text'
      ..body = ''
      ..method = '';
  done = new Completer();
}
