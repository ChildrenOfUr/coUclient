// DO NOT EDIT: auto-generated with `pub run custom_element_apigen:update`

/// Dart API for the polymer element `core_dropdown_menu`.
@HtmlImport('core_dropdown_menu_nodart.html')
library core_elements.core_dropdown_menu;

import 'dart:html';
import 'dart:js' show JsArray, JsObject;
import 'package:web_components/custom_element_proxy.dart';
import 'package:web_components/html_import_annotation.dart';
import 'core_dropdown_base.dart';
import 'core_a11y_keys.dart';
import 'core_focusable.dart';
import 'core_icon.dart';
import 'core_icons.dart';

/// `core-dropdown-menu` works together with `core-dropdown` and `core-selector` to
/// implement a drop-down menu. The currently selected item is displayed in the
/// control. If no item is selected, the `label` is displayed instead.
///
/// The child element with the class `dropdown` will be used as the drop-down
/// menu. It should be a `core-dropdown` or other overlay element. You should
/// also provide a `core-selector` or other selector element, such as `core-menu`,
/// in the drop-down.
///
/// Example:
///
///     <core-dropdown-menu label="Choose a pastry">
///         <core-dropdown class="dropdown">
///             <core-selector>
///               <core-item label="Croissant"></core-item>
///               <core-item label="Donut"></core-item>
///               <core-item label="Financier"></core-item>
///               <core-item label="Madeleine"></core-item>
///             </core-selector>
///         </core-dropdown>
///     </core-dropdown-menu>
@CustomElementProxy('core-dropdown-menu')
class CoreDropdownMenu extends CoreDropdownBase {
  CoreDropdownMenu.created() : super.created();
  factory CoreDropdownMenu() => new Element.tag('core-dropdown-menu');

  /// A label for the control. The label is displayed if no item is selected.
  String get label => jsElement[r'label'];
  set label(String value) { jsElement[r'label'] = value; }

  /// The icon to display when the drop-down is opened.
  String get openedIcon => jsElement[r'openedIcon'];
  set openedIcon(String value) { jsElement[r'openedIcon'] = value; }

  /// The icon to display when the drop-down is closed.
  String get closedIcon => jsElement[r'closedIcon'];
  set closedIcon(String value) { jsElement[r'closedIcon'] = value; }
}
