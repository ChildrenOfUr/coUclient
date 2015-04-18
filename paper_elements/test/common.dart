library paper_elements.common;

import 'dart:async';
import 'dart:html';
import 'dart:js';
import 'package:unittest/unittest.dart';

Future flushLayoutAndRender() {
  context['Polymer'].callMethod('flush', []);
  document.body.offsetTop;
  return window.animationFrame;
}

Element activeElement() => document.activeElement;

void assertNodeHasFocus(Element node) {
  expect(activeElement().id, node.id);
}

Future ensureFocus(Element node) {
  node.focus();
  return flushLayoutAndRender().then((_) {
    assertNodeHasFocus(node);
  });
}
