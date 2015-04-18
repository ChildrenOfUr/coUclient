// DO NOT EDIT: auto-generated with `pub run custom_element_apigen:update`

/// Dart API for the polymer element `core_submenu`.
@HtmlImport('core_submenu_nodart.html')
library core_elements.core_submenu;

import 'dart:html';
import 'dart:js' show JsArray, JsObject;
import 'package:web_components/custom_element_proxy.dart';
import 'package:web_components/html_import_annotation.dart';
import 'package:custom_element_apigen/src/common.dart' show PolymerProxyMixin, DomProxyMixin;
import 'core_item.dart';
import 'core_menu.dart';
import 'core_collapse.dart';

/// Use to create nested menus inside of `core-menu` elements.
///
///     <core-menu selected="0">
///
///       <core-submenu icon="settings" label="Topics">
///         <core-item label="Topic 1"></core-item>
///         <core-item label="Topic 2"></core-item>
///       </core-submenu>
///
///       <core-submenu icon="settings" label="Favorites">
///         <core-item label="Favorite 1"></core-item>
///         <core-item label="Favorite 2"></core-item>
///         <core-item label="Favorite 3"></core-item>
///       </core-submenu>
///
///     </core-menu>
///
/// There is a margin set on the submenu to indent the items.
/// You can override the margin by doing:
///
///     core-submenu::shadow #submenu {
///       margin-left: 20px;
///     }
///
/// To style the item for the submenu, do something like this:
///
///     core-submenu::shadow > #submenuItem {
///       color: blue;
///     }
///
/// To style all the `core-item`s in the light DOM:
///
///     polyfill-next-selector { content: 'core-submenu > #submenu > core-item'; }
///     core-submenu > core-item {
///       color: red;
///     }
///
/// The above will style `Topic1` and `Topic2` to have font color red.
///
///     <core-submenu icon="settings" label="Topics">
///       <core-item label="Topic1"></core-item>
///       <core-item label="Topic2"></core-item>
///     </core-submenu>
@CustomElementProxy('core-submenu')
class CoreSubmenu extends HtmlElement with DomProxyMixin, PolymerProxyMixin {
  CoreSubmenu.created() : super.created();
  factory CoreSubmenu() => new Element.tag('core-submenu');

  get selected => jsElement[r'selected'];
  set selected(value) { jsElement[r'selected'] = (value is Map || value is Iterable) ? new JsObject.jsify(value) : value;}

  get selectedItem => jsElement[r'selectedItem'];
  set selectedItem(value) { jsElement[r'selectedItem'] = (value is Map || value is Iterable) ? new JsObject.jsify(value) : value;}

  get selectedAttribute => jsElement[r'selectedAttribute'];
  set selectedAttribute(value) { jsElement[r'selectedAttribute'] = (value is Map || value is Iterable) ? new JsObject.jsify(value) : value;}

  get label => jsElement[r'label'];
  set label(value) { jsElement[r'label'] = (value is Map || value is Iterable) ? new JsObject.jsify(value) : value;}

  get icon => jsElement[r'icon'];
  set icon(value) { jsElement[r'icon'] = (value is Map || value is Iterable) ? new JsObject.jsify(value) : value;}

  get src => jsElement[r'src'];
  set src(value) { jsElement[r'src'] = (value is Map || value is Iterable) ? new JsObject.jsify(value) : value;}

  get valueattr => jsElement[r'valueattr'];
  set valueattr(value) { jsElement[r'valueattr'] = (value is Map || value is Iterable) ? new JsObject.jsify(value) : value;}

  get items => jsElement[r'items'];
}
