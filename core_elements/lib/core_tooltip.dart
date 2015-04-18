// DO NOT EDIT: auto-generated with `pub run custom_element_apigen:update`

/// Dart API for the polymer element `core_tooltip`.
@HtmlImport('core_tooltip_nodart.html')
library core_elements.core_tooltip;

import 'dart:html';
import 'dart:js' show JsArray, JsObject;
import 'package:web_components/custom_element_proxy.dart';
import 'package:web_components/html_import_annotation.dart';
import 'package:custom_element_apigen/src/common.dart' show PolymerProxyMixin, DomProxyMixin;
import 'core_focusable.dart';
import 'core_resizable.dart';

/// The `core-tooltip` element creates a hover tooltip centered for the content
/// it contains. It can be positioned on the top|bottom|left|right of content using
/// the `position` attribute.
///
/// To include HTML in the tooltip, include the `tip` attribute on the relevant
/// content.
///
/// <b>Example</b>:
///
///     <core-tooltip label="I'm a tooltip">
///       <span>Hover over me.</span>
///     </core-tooltip>
///
/// <b>Example</b> - positioning the tooltip to the right:
///
///     <core-tooltip label="I'm a tooltip to the right" position="right">
///       <core-icon-button icon="drawer"></core-icon-button>
///     </core-tooltip>
///
/// <b>Example</b> - no arrow and showing by default:
///
///     <core-tooltip label="Tooltip with no arrow and always on" noarrow show>
///       <img src="image.jpg">
///     </core-tooltip>
///
/// <b>Example</b> - disable the tooltip.
///
///     <core-tooltip label="Disabled label never shows" disabled>
///       ...
///     </core-tooltip>
///
/// <b>Example</b> - rich tooltip using the `tip` attribute:
///
///     <core-tooltip>
///       <div>Example of a rich information tooltip</div>
///       <div tip>
///         <img src="profile.jpg">Foo <b>Bar</b> - <a href="#">@baz</a>
///       </div>
///     </core-tooltip>
///
/// By default, the `tip` attribute specifies the HTML content for a rich tooltip.
/// You can customize this attribute with the `tipAttribute` attribute:
///
///     <core-tooltip tipAttribute="htmltooltip">
///       <div>Example of a rich information tooltip</div>
///       <div htmltooltip>
///         ...
///       </div>
///     </core-tooltip>
@CustomElementProxy('core-tooltip')
class CoreTooltip extends HtmlElement with DomProxyMixin, PolymerProxyMixin, CoreFocusable, CoreResizable {
  CoreTooltip.created() : super.created();
  factory CoreTooltip() => new Element.tag('core-tooltip');

  /// If true, the tooltip an arrow pointing towards the content.
  bool get noarrow => jsElement[r'noarrow'];
  set noarrow(bool value) { jsElement[r'noarrow'] = value; }

  /// Positions the tooltip to the top, right, bottom, left of its content.
  String get position => jsElement[r'position'];
  set position(String value) { jsElement[r'position'] = value; }

  /// A simple string label for the tooltip to display. To display a rich
  /// HTML tooltip instead, omit `label` and include the `tip` attribute
  /// on a child node of `core-tooltip`.
  String get label => jsElement[r'label'];
  set label(String value) { jsElement[r'label'] = value; }

  /// Forces the tooltip to display. If `disabled` is set, this property is ignored.
  bool get show => jsElement[r'show'];
  set show(bool value) { jsElement[r'show'] = value; }

  /// Customizes the attribute used to specify which content
  /// is the rich HTML tooltip.
  String get tipAttribute => jsElement[r'tipAttribute'];
  set tipAttribute(String value) { jsElement[r'tipAttribute'] = value; }
}
