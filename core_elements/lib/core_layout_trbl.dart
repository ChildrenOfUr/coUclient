// DO NOT EDIT: auto-generated with `pub run custom_element_apigen:update`

/// Dart API for the polymer element `core_layout_trbl`.
@HtmlImport('core_layout_trbl_nodart.html')
library core_elements.core_layout_trbl;

import 'dart:html';
import 'dart:js' show JsArray, JsObject;
import 'package:web_components/custom_element_proxy.dart';
import 'package:web_components/html_import_annotation.dart';
import 'package:custom_element_apigen/src/common.dart' show PolymerProxyMixin, DomProxyMixin;

/// `<core-layout-trbl>` arranges nodes horizontally via absolute positioning.
/// Set the `vertical` attribute (boolean) to arrange vertically instead.
///
/// `<core-layout-trbl>` arranges it's <b>sibling elements</b>, not
/// it's children.
///
/// One arranged node may be marked as elastic by giving it a `flex`
/// attribute (boolean).
///
/// You may remove a node from layout by giving it a `nolayout`
/// attribute (boolean).
///
/// CSS Notes:
///
/// `padding` is ignored on the parent node.
/// `margin` is ignored on arranged nodes.
/// `min-width` is ignored on arranged nodes, use `min-width` on the parent node
/// instead.
///
/// Example:
///
/// Arrange three `div` into columns. `flex` attribute on Column Two makes that
/// column elastic.
///
///      <core-layout-trbl></core-layout-trbl>
///      <div>Column One</div>
///      <div flex>Column Two</div>
///      <div>Column Three</div>
///
/// Remember that `<core-layout-trbl>` arranges it's sibling elements, not it's children.
///
/// If body has width 52 device pixels (in this case, ascii characters), call that 52px.
/// Column One has it's natural width of 12px (including border), Column Three has it's
/// natural width of 14px, body border uses 2px, and Column Two automatically uses the
/// remaining space: 24px.
///
///      |-                    52px                        -|
///      ----------------------------------------------------
///      ||Column One||      Column Two      ||Column Three||
///      ----------------------------------------------------
///       |-  12px  -||-     (24px)         -||    14px   -|
///
/// As the parent node resizes, the elastic column reacts via CSS to adjust it's size.
/// No javascript is used during parent resizing, for best performance.
///
/// Changes in content or sibling size are not handled automatically.
///
///      ----------------------------------------------------------------
///      ||Column One|             Column Two             |Column Three||
///      ----------------------------------------------------------------
///
///      --------------------------------------
///      ||Column One|Column Two|Column Three||
///      --------------------------------------
///
/// Arrange in rows by adding the `vertical` attribute.
///
/// Example:
///
///      <core-layout-trbl vertical></core-layout-trbl>
///      <div>Row One</div>
///      <div flex>Row Two</div>
///      <div>Row Three</div>
///
/// This setup will cause Row Two to stretch to fill the container.
///
///      -----------             -----------
///      |---------|             |---------|
///      |         |             |         |
///      |Row One  |             |Row One  |
///      |         |             |         |
///      |---------|             |---------|
///      |         |             |         |
///      |Row Two  |             |Row Two  |
///      |         |             |         |
///      |---------|             |         |
///      |         |             |         |
///      |Row Three|             |         |
///      |         |             |---------|
///      |---------|             |         |
///      -----------             |Row Three|
///                              |         |
///                              |---------|
///                              |---------|
///
/// Layouts can be nested arbitrarily.
///
///      <core-layout-trbl></core-layout-trbl>
///      <div>Menu</div>
///      <div flex>
///         <core-layout-trbl vertical></core-layout-trbl>
///         <div>Title</div>
///         <div>Toolbar</div>
///         <div flex>Main</div>
///         <div>Footer</div>
///      </div>
///
/// Renders something like this
///
///      --------------------------------
///      ||Menu     ||Title            ||
///      ||         ||-----------------||
///      ||         ||Toolbar          ||
///      ||         ||-----------------||
///      ||         ||Main             ||
///      ||         ||                 ||
///      ||         ||-----------------||
///      ||         ||Footer           ||
///      --------------------------------
@CustomElementProxy('core-layout-trbl')
class CoreLayoutTrbl extends HtmlElement with DomProxyMixin, PolymerProxyMixin {
  CoreLayoutTrbl.created() : super.created();
  factory CoreLayoutTrbl() => new Element.tag('core-layout-trbl');

  get vertical => jsElement[r'vertical'];
  set vertical(value) { jsElement[r'vertical'] = (value is Map || value is Iterable) ? new JsObject.jsify(value) : value;}

  /// Arrange sibling nodes end-to-end in one dimension.
  ///
  /// Arrangement is horizontal unless the `vertical`
  /// attribute is applied on this node.
  void layout() =>
      jsElement.callMethod('layout', []);
}
