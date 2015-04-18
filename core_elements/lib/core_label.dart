// DO NOT EDIT: auto-generated with `pub run custom_element_apigen:update`

/// Dart API for the polymer element `core_label`.
@HtmlImport('core_label_nodart.html')
library core_elements.core_label;

import 'dart:html';
import 'dart:js' show JsArray, JsObject;
import 'package:web_components/custom_element_proxy.dart';
import 'package:web_components/html_import_annotation.dart';
import 'package:custom_element_apigen/src/common.dart' show PolymerProxyMixin, DomProxyMixin;

/// `<core-label>` provides a version of the `<label>` element that works with Custom Elements as well as native elements.
///
/// All text in the `core-label` will be applied to the target element as a screen-reader accessible description.
///
/// There are two ways to use `core-label` to target an element:
///
/// 1. place an element inside core-label with the `for` attribute:
///
///         <core-label>
///           Context for the Button
///           <paper-button for>button</paper-button>
///         </core-label>
///
/// 2. Set the `for` attribute on the `core-label` element to point to a target element in the same scope with a query
/// string:
///
///         <core-label for=".foo">
///           Context for the button witht the "foo" class"
///         </core-label>
///         <paper-button class="foo">Far away button</paper-button>
///
/// All taps on the `core-label` will be forwarded to the "target" element.
@CustomElementProxy('core-label')
class CoreLabel extends HtmlElement with DomProxyMixin, PolymerProxyMixin {
  CoreLabel.created() : super.created();
  factory CoreLabel() => new Element.tag('core-label');

  /// A query selector string for a "target" element not nested in the `<core-label>`
  String get htmlFor => jsElement[r'for'];
  set htmlFor(String value) { jsElement[r'for'] = value; }
}
