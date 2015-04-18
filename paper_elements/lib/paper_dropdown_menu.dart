// DO NOT EDIT: auto-generated with `pub run custom_element_apigen:update`

/// Dart API for the polymer element `paper_dropdown_menu`.
@HtmlImport('paper_dropdown_menu_nodart.html')
library paper_elements.paper_dropdown_menu;

import 'dart:html';
import 'dart:js' show JsArray, JsObject;
import 'package:web_components/custom_element_proxy.dart';
import 'package:web_components/html_import_annotation.dart';
import 'package:core_elements/core_dropdown_base.dart';
import 'package:core_elements/core_focusable.dart';
import 'package:core_elements/core_a11y_keys.dart';
import 'package:core_elements/core_icon.dart';
import 'package:core_elements/core_icons.dart';
import 'paper_shadow.dart';

/// `paper-dropdown-menu` works together with `paper-dropdown` and `core-menu` to
/// implement a drop-down menu. The currently selected item is displayed in the
/// control. If no item is selected, the `label` is displayed instead.
///
/// The child element with the class `dropdown` will be used as the drop-down
/// menu. It should be a `paper-dropdown` or other overlay element. You should
/// also provide a `core-selector` or other selector element, such as `core-menu`,
/// in the drop-down. You should apply the class `menu` to the selector element.
///
/// Example:
///
///     <paper-dropdown-menu label="Your favorite pastry">
///         <paper-dropdown class="dropdown">
///             <core-menu class="menu">
///                 <paper-item>Croissant</paper-item>
///                 <paper-item>Donut</paper-item>
///                 <paper-item>Financier</paper-item>
///                 <paper-item>Madeleine</paper-item>
///             </core-menu>
///         </paper-dropdown>
///     </paper-dropdown-menu>
///
/// This example renders a drop-down menu with 4 options.
@CustomElementProxy('paper-dropdown-menu')
class PaperDropdownMenu extends CoreDropdownBase with CoreFocusable {
  PaperDropdownMenu.created() : super.created();
  factory PaperDropdownMenu() => new Element.tag('paper-dropdown-menu');

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
