// DO NOT EDIT: auto-generated with `pub run custom_element_apigen:update`

/// Dart API for the polymer element `core_splitter`.
@HtmlImport('core_splitter_nodart.html')
library core_elements.core_splitter;

import 'dart:html';
import 'dart:js' show JsArray, JsObject;
import 'package:web_components/custom_element_proxy.dart';
import 'package:web_components/html_import_annotation.dart';
import 'package:custom_element_apigen/src/common.dart' show PolymerProxyMixin, DomProxyMixin;
import 'core_resizer.dart';
import 'core_resizable.dart';

/// `core-splitter` provides a split bar and dragging on the split bar
/// will resize the sibling element.  Use its `direction` property to indicate
/// which sibling element to be resized and the orientation.  Usually you would want
/// to use `core-splitter` along with flex layout so that the other sibling
/// element can be _flexible_.
///
/// Example:
///
///     <div horizontal layout>
///       <div>left</div>
///       <core-splitter direction="left"></core-splitter>
///       <div flex>right</div>
///     </div>
///
/// In the above example, dragging the splitter will resize the _left_ element.  And
/// since the parent container is a flexbox and the _right_ element has
/// `flex`, the _right_ element will be auto-resized.
///
/// For horizontal splitter set `direction` to `up` or `down`.
///
/// Example:
///
///     <div vertical layout>
///       <div>top</div>
///       <core-splitter direction="up"></core-splitter>
///       <div flex>bottom</div>
///     </div>
@CustomElementProxy('core-splitter')
class CoreSplitter extends HtmlElement with DomProxyMixin, PolymerProxyMixin, CoreResizable, CoreResizer {
  CoreSplitter.created() : super.created();
  factory CoreSplitter() => new Element.tag('core-splitter');

  /// Possible values are `left`, `right`, `up` and `down`.
  String get direction => jsElement[r'direction'];
  set direction(String value) { jsElement[r'direction'] = value; }

  /// Locks the split bar so it can't be dragged.
  bool get locked => jsElement[r'locked'];
  set locked(bool value) { jsElement[r'locked'] = value; }

  /// Minimum width to which the splitter target can be sized, e.g.
  /// `minSize="100px"`
  String get minSize => jsElement[r'minSize'];
  set minSize(String value) { jsElement[r'minSize'] = value; }

  /// By default the parent and siblings of the splitter are set to overflow hidden. This helps
  /// avoid elements bleeding outside the splitter regions. Set this property to true to allow
  /// these elements to overflow.
  bool get allowOverflow => jsElement[r'allowOverflow'];
  set allowOverflow(bool value) { jsElement[r'allowOverflow'] = value; }
}
