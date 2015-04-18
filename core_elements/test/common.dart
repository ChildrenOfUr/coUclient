library core_elements.common;

import 'dart:async';
import 'dart:html';
import 'dart:js';

Future flushLayoutAndRender() {
  context['Polymer'].callMethod('flush', []);
  document.body.offsetTop;
  return new Future(() {});
}
