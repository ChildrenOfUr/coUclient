// DO NOT EDIT: auto-generated with `pub run custom_element_apigen:update`

/// Dart API for the polymer element `core_range`.
@HtmlImport('core_range_nodart.html')
library core_elements.core_range;

import 'dart:html';
import 'dart:js' show JsArray, JsObject;
import 'package:web_components/custom_element_proxy.dart';
import 'package:web_components/html_import_annotation.dart';
import 'package:custom_element_apigen/src/common.dart' show PolymerProxyMixin, DomProxyMixin;

/// The `core-range` element is used for managing a numeric value within a given
/// range.  It has no visual appearance and is typically used in conjunction with
/// another element.
///
/// One can build a progress bar using `core-range` like this:
///
///     <core-range min="0" max="200" value="100" ratio="{{ratio}}"></core-range>
///     <div class="progress-bar" style="width: {{ratio}}%;"></div>
@CustomElementProxy('core-range')
class CoreRange extends HtmlElement with DomProxyMixin, PolymerProxyMixin {
  CoreRange.created() : super.created();
  factory CoreRange() => new Element.tag('core-range');

  /// The number that represents the current value.
  num get value => jsElement[r'value'];
  set value(num value) { jsElement[r'value'] = value; }

  /// The number that indicates the minimum value of the range.
  num get min => jsElement[r'min'];
  set min(num value) { jsElement[r'min'] = value; }

  /// The number that indicates the maximum value of the range.
  num get max => jsElement[r'max'];
  set max(num value) { jsElement[r'max'] = value; }

  /// Specifies the value granularity of the range's value.
  num get step => jsElement[r'step'];
  set step(num value) { jsElement[r'step'] = value; }

  /// Returns the ratio of the value.
  num get ratio => jsElement[r'ratio'];
  set ratio(num value) { jsElement[r'ratio'] = value; }
}
