// DO NOT EDIT: auto-generated with `pub run custom_element_apigen:update`

/// Dart API for the polymer element `core_layout_grid`.
@HtmlImport('core_layout_grid_nodart.html')
library core_elements.core_layout_grid;

import 'dart:html';
import 'dart:js' show JsArray, JsObject;
import 'package:web_components/custom_element_proxy.dart';
import 'package:web_components/html_import_annotation.dart';
import 'package:custom_element_apigen/src/common.dart' show PolymerProxyMixin, DomProxyMixin;

/// TODO
@CustomElementProxy('core-layout-grid')
class CoreLayoutGrid extends HtmlElement with DomProxyMixin, PolymerProxyMixin {
  CoreLayoutGrid.created() : super.created();
  factory CoreLayoutGrid() => new Element.tag('core-layout-grid');

  get nodes => jsElement[r'nodes'];
  set nodes(value) { jsElement[r'nodes'] = (value is Map || value is Iterable) ? new JsObject.jsify(value) : value;}

  get layout => jsElement[r'layout'];
  set layout(value) { jsElement[r'layout'] = (value is Map || value is Iterable) ? new JsObject.jsify(value) : value;}

  get auto => jsElement[r'auto'];
  set auto(value) { jsElement[r'auto'] = (value is Map || value is Iterable) ? new JsObject.jsify(value) : value;}
}
