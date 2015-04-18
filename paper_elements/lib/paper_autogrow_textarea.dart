// DO NOT EDIT: auto-generated with `pub run custom_element_apigen:update`

/// Dart API for the polymer element `paper_autogrow_textarea`.
@HtmlImport('paper_autogrow_textarea_nodart.html')
library paper_elements.paper_autogrow_textarea;

import 'dart:html';
import 'dart:js' show JsArray, JsObject;
import 'package:web_components/custom_element_proxy.dart';
import 'package:web_components/html_import_annotation.dart';
import 'package:custom_element_apigen/src/common.dart' show PolymerProxyMixin, DomProxyMixin;

/// `paper-autogrow-textarea` is an element containing a textarea that grows in height as more
/// lines of input are entered. Unless an explicit height or the `maxRows` property is set, it will
/// never scroll.
///
/// Example:
///
///     <paper-autogrow-textarea id="a1">
///         <textarea id="t1"></textarea>
///     </paper-autogrow-textarea>
///
/// Because the `textarea`'s `value` property is not observable, if you set the `value` imperatively
/// you must call `update` to notify this element the value has changed.
///
/// Example:
///
///     /* using example HTML above */
///     t1.value = 'some\ntext';
///     a1.update();
@CustomElementProxy('paper-autogrow-textarea')
class PaperAutogrowTextarea extends HtmlElement with DomProxyMixin, PolymerProxyMixin {
  PaperAutogrowTextarea.created() : super.created();
  factory PaperAutogrowTextarea() => new Element.tag('paper-autogrow-textarea');

  /// The textarea that should auto grow.
  get target => jsElement[r'target'];
  set target(value) { jsElement[r'target'] = (value is Map || value is Iterable) ? new JsObject.jsify(value) : value;}

  /// The initial number of rows.
  num get rows => jsElement[r'rows'];
  set rows(num value) { jsElement[r'rows'] = value; }

  /// The maximum number of rows this element can grow to until it
  /// scrolls. 0 means no maximum.
  num get maxRows => jsElement[r'maxRows'];
  set maxRows(num value) { jsElement[r'maxRows'] = value; }

  /// Sizes this element to fit the input value. This function is automatically called
  /// when the user types in new input, but you must call this function if the value
  /// is updated imperatively.
  void update() =>
      jsElement.callMethod('update', []);
}
