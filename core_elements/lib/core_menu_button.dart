// DO NOT EDIT: auto-generated with `pub run custom_element_apigen:update`

/// Dart API for the polymer element `core_menu_button`.
@HtmlImport('core_menu_button_nodart.html')
library core_elements.core_menu_button;

import 'dart:html';
import 'dart:js' show JsArray, JsObject;
import 'package:web_components/custom_element_proxy.dart';
import 'package:web_components/html_import_annotation.dart';
import 'core_dropdown_base.dart';
import 'core_a11y_keys.dart';

/// `core-menu-button` works together with a button and `core-dropdown` to implement
/// an button that displays a drop-down when tapped on.
///
/// The child element with the class `dropdown` will be used as the drop-down
/// menu. It should be a `core-dropdown` or other overlay element.
///
/// Example:
///
///     <core-menu-button>
///         <core-icon-button icon="menu"></core-icon-button>
///         <core-dropdown class="dropdown" layered>
///             <core-menu>
///                 <core-item>Share</core-item>
///                 <core-item>Settings</core-item>
///                 <core-item>Help</core-item>
///             </core-menu>
///         </core-dropdown>
///     </core-menu-button>
@CustomElementProxy('core-menu-button')
class CoreMenuButton extends CoreDropdownBase {
  CoreMenuButton.created() : super.created();
  factory CoreMenuButton() => new Element.tag('core-menu-button');
}
