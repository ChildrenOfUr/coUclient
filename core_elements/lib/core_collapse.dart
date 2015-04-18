// DO NOT EDIT: auto-generated with `pub run custom_element_apigen:update`

/// Dart API for the polymer element `core_collapse`.
@HtmlImport('core_collapse_nodart.html')
library core_elements.core_collapse;

import 'dart:html';
import 'dart:js' show JsArray, JsObject;
import 'package:web_components/custom_element_proxy.dart';
import 'package:web_components/html_import_annotation.dart';
import 'package:custom_element_apigen/src/common.dart' show PolymerProxyMixin, DomProxyMixin;

/// `core-collapse` creates a collapsible block of content.  By default, the content
/// will be collapsed.  Use `opened` or `toggle()` to show/hide the content.
///
///     <button on-click="{{toggle}}">toggle collapse</button>
///
///     <core-collapse id="collapse">
///       Content goes here...
///     </core-collapse>
///
///     ...
///
///     toggle: function() {
///       this.$.collapse.toggle();
///     }
///
/// `core-collapse` adjusts the height/width of the collapsible element to show/hide
/// the content.  So avoid putting padding/margin/border on the collapsible directly,
/// and instead put a div inside and style that.
///
///     <style>
///       .collapse-content {
///         padding: 15px;
///         border: 1px solid #dedede;
///       }
///     </style>
///
///     <core-collapse>
///       <div class="collapse-content">
///         Content goes here...
///       </div>
///     </core-collapse>
@CustomElementProxy('core-collapse')
class CoreCollapse extends HtmlElement with DomProxyMixin, PolymerProxyMixin {
  CoreCollapse.created() : super.created();
  factory CoreCollapse() => new Element.tag('core-collapse');

  /// The target element that will be opened when the `core-collapse` is
  /// opened. If unspecified, the `core-collapse` itself is the target.
  get target => jsElement[r'target'];
  set target(value) { jsElement[r'target'] = (value is Map || value is Iterable) ? new JsObject.jsify(value) : value;}

  /// If true, the orientation is horizontal; otherwise is vertical.
  bool get horizontal => jsElement[r'horizontal'];
  set horizontal(bool value) { jsElement[r'horizontal'] = value; }

  /// Set opened to true to show the collapse element and to false to hide it.
  bool get opened => jsElement[r'opened'];
  set opened(bool value) { jsElement[r'opened'] = value; }

  /// Collapsing/expanding animation duration in second.
  num get duration => jsElement[r'duration'];
  set duration(num value) { jsElement[r'duration'] = value; }

  /// If true, the size of the target element is fixed and is set
  /// on the element.  Otherwise it will try to
  /// use auto to determine the natural size to use
  /// for collapsing/expanding.
  bool get fixedSize => jsElement[r'fixedSize'];
  set fixedSize(bool value) { jsElement[r'fixedSize'] = value; }

  /// By default the collapsible element is set to overflow hidden. This helps
  /// avoid element bleeding outside the region and provides consistent overflow
  /// style across opened and closed states. Set this property to true to allow
  /// the collapsible element to overflow when it's opened.
  bool get allowOverflow => jsElement[r'allowOverflow'];
  set allowOverflow(bool value) { jsElement[r'allowOverflow'] = value; }

  /// Toggle the opened state.
  void toggle() =>
      jsElement.callMethod('toggle', []);
}
