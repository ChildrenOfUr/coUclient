// DO NOT EDIT: auto-generated with `pub run custom_element_apigen:update`

/// Dart API for the polymer element `core_menu`.
@HtmlImport('core_menu_nodart.html')
library core_elements.core_menu;

import 'dart:html';
import 'dart:js' show JsArray, JsObject;
import 'package:web_components/custom_element_proxy.dart';
import 'package:web_components/html_import_annotation.dart';
import 'core_selector.dart';
import 'core_a11y_keys.dart';

/// `core-menu` is a selector which styles to looks like a menu.
///
///     <core-menu selected="0">
///       <core-item icon="settings" label="Settings"></core-item>
///       <core-item icon="dialog" label="Dialog"></core-item>
///       <core-item icon="search" label="Search"></core-item>
///     </core-menu>
///
/// When an item is selected the `core-selected` class is added to it.  The user can
/// use the class to add more stylings to the selected item.
///
///     core-item.core-selected {
///       color: red;
///     }
///
/// The `selectedItem` property references the selected item.
///
///     <core-menu selected="0" selectedItem="{{item}}">
///       <core-item icon="settings" label="Settings"></core-item>
///       <core-item icon="dialog" label="Dialog"></core-item>
///       <core-item icon="search" label="Search"></core-item>
///     </core-menu>
///
///     <div>selected label: {{item.label}}</div>
///
/// The `core-select` event signals selection change.
///
///     <core-menu selected="0" on-core-select="{{selectAction}}">
///       <core-item icon="settings" label="Settings"></core-item>
///       <core-item icon="dialog" label="Dialog"></core-item>
///       <core-item icon="search" label="Search"></core-item>
///     </core-menu>
///
///     ...
///
///     selectAction: function(e, detail) {
///       if (detail.isSelected) {
///         var selectedItem = detail.item;
///         ...
///       }
///     }
@CustomElementProxy('core-menu')
class CoreMenu extends CoreSelector {
  CoreMenu.created() : super.created();
  factory CoreMenu() => new Element.tag('core-menu');
}
