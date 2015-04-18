// DO NOT EDIT: auto-generated with `pub run custom_element_apigen:update`

/// Dart API for the polymer element `paper_checkbox`.
@HtmlImport('paper_checkbox_nodart.html')
library paper_elements.paper_checkbox;

import 'dart:html';
import 'dart:js' show JsArray, JsObject;
import 'package:web_components/custom_element_proxy.dart';
import 'package:web_components/html_import_annotation.dart';
import 'paper_radio_button.dart';

/// `paper-checkbox` is a button that can be either checked or unchecked.  User
/// can tap the checkbox to check or uncheck it.  Usually you use checkboxes
/// to allow user to select multiple options from a set.  If you have a single
/// ON/OFF option, avoid using a single checkbox and use `paper-toggle-button`
/// instead.
///
/// Example:
///
///     <paper-checkbox></paper-checkbox>
///
///     <paper-checkbox checked></paper-checkbox>
///
/// Styling checkbox:
///
/// To change the ink color for checked state:
///
///     paper-checkbox::shadow #ink[checked] {
///       color: #4285f4;
///     }
///
/// To change the checkbox checked color:
///
///     paper-checkbox::shadow #checkbox.checked {
///       background-color: #4285f4;
///       border-color: #4285f4;
///     }
///
/// To change the ink color for unchecked state:
///
///     paper-checkbox::shadow #ink {
///       color: #b5b5b5;
///     }
///
/// To change the checkbox unchecked color:
///
///     paper-checkbox::shadow #checkbox {
///       border-color: #b5b5b5;
///     }
@CustomElementProxy('paper-checkbox')
class PaperCheckbox extends PaperRadioButton {
  PaperCheckbox.created() : super.created();
  factory PaperCheckbox() => new Element.tag('paper-checkbox');
}
