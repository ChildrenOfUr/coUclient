// DO NOT EDIT: auto-generated with `pub run custom_element_apigen:update`

/// Dart API for the polymer element `paper_menu_button`.
@HtmlImport('paper_menu_button_nodart.html')
library paper_elements.paper_menu_button;

import 'dart:html';
import 'dart:js' show JsArray, JsObject;
import 'package:web_components/custom_element_proxy.dart';
import 'package:web_components/html_import_annotation.dart';
import 'package:core_elements/core_dropdown_base.dart';
import 'package:core_elements/core_a11y_keys.dart';

/// `paper-menu-button` works together with a button and a `paper-dropdown` to
/// implement a button that displays a drop-down when tapped on.
///
/// The child element with the class `dropdown` will be used as the drop-down
/// menu. It should be a `paper-dropdown` or other overlay element.
///
/// Example:
///
///     <paper-menu-button>
///         <paper-icon-button icon="menu" noink></paper-icon-button>
///         <paper-dropdown class="dropdown">
///             <core-menu class="menu">
///                 <paper-item>Share</paper-item>
///                 <paper-item>Settings</paper-item>
///                 <paper-item>Help</paper-item>
///             </core-menu>
///         </paper-dropdown>
///     </paper-menu-button>
@CustomElementProxy('paper-menu-button')
class PaperMenuButton extends CoreDropdownBase {
  PaperMenuButton.created() : super.created();
  factory PaperMenuButton() => new Element.tag('paper-menu-button');
}
