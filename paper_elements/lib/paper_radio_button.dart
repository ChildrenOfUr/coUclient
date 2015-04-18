// DO NOT EDIT: auto-generated with `pub run custom_element_apigen:update`

/// Dart API for the polymer element `paper_radio_button`.
@HtmlImport('paper_radio_button_nodart.html')
library paper_elements.paper_radio_button;

import 'dart:html';
import 'dart:js' show JsArray, JsObject;
import 'package:web_components/custom_element_proxy.dart';
import 'package:web_components/html_import_annotation.dart';
import 'package:custom_element_apigen/src/common.dart' show PolymerProxyMixin, DomProxyMixin;
import 'paper_ripple.dart';
import 'package:core_elements/core_a11y_keys.dart';

/// `paper-radio-button` is a button that can be either checked or unchecked.
/// User can tap the radio button to check it.  But it cannot be unchecked by
/// tapping once checked.
///
/// Use `paper-radio-group` to group a set of radio buttons.  When radio buttons
/// are inside a radio group, only one radio button in the group can be checked.
///
/// Example:
///
///     <paper-radio-button></paper-radio-button>
///
/// Styling radio button:
///
/// To change the ink color for checked state:
///
///     paper-radio-button::shadow #ink[checked] {
///       color: #4285f4;
///     }
///
/// To change the radio checked color:
///
///     paper-radio-button::shadow #onRadio {
///       background-color: #4285f4;
///     }
///
///     paper-radio-button[checked]::shadow #offRadio {
///       border-color: #4285f4;
///     }
///
/// To change the ink color for unchecked state:
///
///     paper-radio-button::shadow #ink {
///       color: #b5b5b5;
///     }
///
/// To change the radio unchecked color:
///
///     paper-radio-button::shadow #offRadio {
///       border-color: #b5b5b5;
///     }
@CustomElementProxy('paper-radio-button')
class PaperRadioButton extends HtmlElement with DomProxyMixin, PolymerProxyMixin {
  PaperRadioButton.created() : super.created();
  factory PaperRadioButton() => new Element.tag('paper-radio-button');

  /// Gets or sets the state, `true` is checked and `false` is unchecked.
  bool get checked => jsElement[r'checked'];
  set checked(bool value) { jsElement[r'checked'] = value; }

  /// The label for the radio button.
  String get label => jsElement[r'label'];
  set label(String value) { jsElement[r'label'] = value; }

  /// Normally the user cannot uncheck the radio button by tapping once
  /// checked.  Setting this property to `true` makes the radio button
  /// toggleable from checked to unchecked.
  bool get toggles => jsElement[r'toggles'];
  set toggles(bool value) { jsElement[r'toggles'] = value; }

  /// If true, the user cannot interact with this element.
  bool get disabled => jsElement[r'disabled'];
  set disabled(bool value) { jsElement[r'disabled'] = value; }
}
