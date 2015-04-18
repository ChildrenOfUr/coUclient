// DO NOT EDIT: auto-generated with `pub run custom_element_apigen:update`

/// Dart API for the polymer element `paper_toggle_button`.
@HtmlImport('paper_toggle_button_nodart.html')
library paper_elements.paper_toggle_button;

import 'dart:html';
import 'dart:js' show JsArray, JsObject;
import 'package:web_components/custom_element_proxy.dart';
import 'package:web_components/html_import_annotation.dart';
import 'package:custom_element_apigen/src/common.dart' show PolymerProxyMixin, DomProxyMixin;
import 'paper_radio_button.dart';
import 'package:core_elements/core_a11y_keys.dart';

/// `paper-toggle-button` provides a ON/OFF switch that user can toggle the state
/// by tapping or by dragging the swtich.
///
/// Example:
///
///     <paper-toggle-button></paper-toggle-button>
///
/// Styling toggle button:
///
/// To change the toggle color:
///
///     paper-toggle-button::shadow .toggle {
///       background-color: #9c27b0;
///     }
///
/// To change the ink color:
///
///     paper-toggle-button::shadow .toggle-ink {
///       color: #009688;
///     }
///
/// To change the checked toggle color:
///
///     paper-toggle-button::shadow [checked] .toggle {
///       background-color: #4285f4;
///     }
///
/// To change the checked ink color:
///
///     paper-toggle-button::shadow [checked] .toggle-ink {
///       color: #4285f4;
///     }
///
/// To change the toggle bar and toggle button colors separately:
///
///     paper-toggle-button::shadow .toggle-bar {
///       background-color: #5677fc;
///     }
///
///     paper-toggle-button::shadow .toggle-button {
///       background-color: #9c27b0;
///     }
@CustomElementProxy('paper-toggle-button')
class PaperToggleButton extends HtmlElement with DomProxyMixin, PolymerProxyMixin {
  PaperToggleButton.created() : super.created();
  factory PaperToggleButton() => new Element.tag('paper-toggle-button');

  /// Gets or sets the state, `true` is checked and `false` is unchecked.
  bool get checked => jsElement[r'checked'];
  set checked(bool value) { jsElement[r'checked'] = value; }

  /// If true, the toggle button is disabled.  A disabled toggle button cannot
  /// be tapped or dragged to change the checked state.
  bool get disabled => jsElement[r'disabled'];
  set disabled(bool value) { jsElement[r'disabled'] = value; }
}
