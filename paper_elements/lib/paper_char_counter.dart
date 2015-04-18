// DO NOT EDIT: auto-generated with `pub run custom_element_apigen:update`

/// Dart API for the polymer element `paper_char_counter`.
@HtmlImport('paper_char_counter_nodart.html')
library paper_elements.paper_char_counter;

import 'dart:html';
import 'dart:js' show JsArray, JsObject;
import 'package:web_components/custom_element_proxy.dart';
import 'package:web_components/html_import_annotation.dart';
import 'package:custom_element_apigen/src/common.dart' show PolymerProxyMixin, DomProxyMixin;
import 'package:core_elements/core_style.dart';

/// Material Design: <a href="http://www.google.com/design/spec/components/text-fields.html#text-fields-character-counter">Character counter</a>
///
/// `paper-char-counter` adds a character counter for paper input fields with a character restriction in place.
///
/// Example:
///
///     <paper-input-decorator>
///       <input id="input1" is="core-input" maxlength="5">
///       <paper-char-counter class="footer" target="input1"></paper-char-counter>
///     </paper-input-decorator>
///
/// Theming
/// -------
///
/// `paper-char-counter` uses `paper-input-decorator`'s error `core-style` for global theming.
@CustomElementProxy('paper-char-counter')
class PaperCharCounter extends HtmlElement with DomProxyMixin, PolymerProxyMixin {
  PaperCharCounter.created() : super.created();
  factory PaperCharCounter() => new Element.tag('paper-char-counter');

  /// The id of the textinput or textarea that should be monitored.
  String get target => jsElement[r'target'];
  set target(String value) { jsElement[r'target'] = value; }

  /// If false, don't show the character counter. Used in conjunction with
  /// `paper-input-decorator's` `error` field.
  bool get showCounter => jsElement[r'showCounter'];
  set showCounter(bool value) { jsElement[r'showCounter'] = value; }
}
