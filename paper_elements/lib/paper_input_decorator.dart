// DO NOT EDIT: auto-generated with `pub run custom_element_apigen:update`

/// Dart API for the polymer element `paper_input_decorator`.
@HtmlImport('paper_input_decorator_nodart.html')
library paper_elements.paper_input_decorator;

import 'dart:html';
import 'dart:js' show JsArray, JsObject;
import 'package:web_components/custom_element_proxy.dart';
import 'package:web_components/html_import_annotation.dart';
import 'package:custom_element_apigen/src/common.dart' show PolymerProxyMixin, DomProxyMixin;
import 'package:core_elements/core_icon.dart';
import 'package:core_elements/core_icons.dart';
import 'package:core_elements/core_input.dart';
import 'package:core_elements/core_style.dart';

/// Material Design: <a href="http://www.google.com/design/spec/components/text-fields.html">Text fields</a>
///
/// `paper-input-decorator` adds Material Design input field styling and animations to an element.
///
/// Example:
///
///     <paper-input-decorator label="Your Name">
///         <input is="core-input">
///     </paper-input-decorator>
///
///     <paper-input-decorator floatingLabel label="Your address">
///         <textarea></textarea>
///     </paper-input-decorator>
///
/// Theming
/// -------
///
/// `paper-input-decorator` uses `core-style` for global theming. The following options are available:
///
/// - `CoreStyle.g.paperInput.labelColor` - The inline label, floating label, error message and error icon color when the input does not have focus.
/// - `CoreStyle.g.paperInput.focusedColor` - The floating label and the underline color when the input has focus.
/// - `CoreStyle.g.paperInput.invalidColor` - The error message, the error icon, the floating label and the underline's color when the input is invalid and has focus.
///
/// To add custom styling to only some elements, use these selectors:
///
///     paper-input-decorator /deep/ .label-text,
///     paper-input-decorator /deep/ .error {
///         /* inline label,  floating label, error message and error icon color when the input is unfocused */
///         color: green;
///     }
///
///     paper-input-decorator /deep/ ::-webkit-input-placeholder {
///         /* platform specific rules for placeholder text */
///         color: green;
///     }
///     paper-input-decorator /deep/ ::-moz-placeholder {
///         color: green;
///     }
///     paper-input-decorator /deep/ :-ms-input-placeholder {
///         color: green;
///     }
///
///     paper-input-decorator /deep/ .unfocused-underline {
///         /* line color when the input is unfocused */
///         background-color: green;
///     }
///
///     paper-input-decorator[focused] /deep/ .floating-label .label-text {
///         /* floating label color when the input is focused */
///         color: orange;
///     }
///
///     paper-input-decorator /deep/ .focused-underline {
///         /* line color when the input is focused */
///         background-color: orange;
///     }
///
///     paper-input-decorator.invalid[focused] /deep/ .floated-label .label-text,
///     paper-input-decorator[focused] /deep/ .error {
///         /* floating label, error message nad error icon color when the input is invalid and focused */
///         color: salmon;
///     }
///
///     paper-input-decorator.invalid /deep/ .focused-underline {
///         /* line and color when the input is invalid and focused */
///         background-color: salmon;
///     }
///
/// Form submission
/// ---------------
///
/// You can use inputs decorated with this element in a `form` as usual.
///
/// Validation
/// ----------
///
/// Because you provide the `input` element to `paper-input-decorator`, you can use any validation library
/// or the <a href="https://developer.mozilla.org/en-US/docs/Web/Guide/HTML/HTML5/Constraint_validation">HTML5 Constraints Validation API</a>
/// to implement validation. Set the `isInvalid` attribute when the input is validated, and provide an
/// error message in the `error` attribute.
///
/// Example:
///
///     <paper-input-decorator id="paper1" error="Value must start with a number!">
///         <input id="input1" is="core-input" pattern="^[0-9].*">
///     </paper-input-decorator>
///     <button onclick="validate()"></button>
///     <script>
///         function validate() {
///             var decorator = document.getElementById('paper1');
///             var input = document.getElementById('input1');
///             decorator.isInvalid = !input.validity.valid;
///         }
///     </script>
///
/// Example to validate as the user types:
///
///     <template is="auto-binding">
///         <paper-input-decorator id="paper2" error="Value must start with a number!" isInvalid="{{!$.input2.validity.valid}}">
///             <input id="input2" is="core-input" pattern="^[0-9].*">
///         </paper-input-decorator>
///     </template>
///
/// Accessibility
/// -------------
///
/// `paper-input-decorator` will automatically set the `aria-label` attribute on the nested input
/// to the value of `label`. Do not set the `placeholder` attribute on the nested input, as it will
/// conflict with this element.
@CustomElementProxy('paper-input-decorator')
class PaperInputDecorator extends HtmlElement with DomProxyMixin, PolymerProxyMixin {
  PaperInputDecorator.created() : super.created();
  factory PaperInputDecorator() => new Element.tag('paper-input-decorator');

  /// The label for this input. It normally appears as grey text inside
  /// the text input and disappears once the user enters text.
  String get label => jsElement[r'label'];
  set label(String value) { jsElement[r'label'] = value; }

  /// If true, the label will "float" above the text input once the
  /// user enters text instead of disappearing.
  bool get floatingLabel => jsElement[r'floatingLabel'];
  set floatingLabel(bool value) { jsElement[r'floatingLabel'] = value; }

  /// Set to true to style the element as disabled.
  bool get disabled => jsElement[r'disabled'];
  set disabled(bool value) { jsElement[r'disabled'] = value; }

  /// Use this property to override the automatic label visibility.
  /// If this property is set to `true` or `false`, the label visibility
  /// will respect this value instead of be based on whether there is
  /// a non-null value in the input.
  bool get labelVisible => jsElement[r'labelVisible'];
  set labelVisible(bool value) { jsElement[r'labelVisible'] = value; }

  /// Set this property to true to show the error message.
  bool get isInvalid => jsElement[r'isInvalid'];
  set isInvalid(bool value) { jsElement[r'isInvalid'] = value; }

  /// Set this property to true to validate the input as the user types.
  /// This will not validate when changing the input programmatically; call
  /// `validate()` instead.
  bool get autoValidate => jsElement[r'autoValidate'];
  set autoValidate(bool value) { jsElement[r'autoValidate'] = value; }

  /// The message to display if the input value fails validation. If this
  /// is unset or the empty string, a default message is displayed depending
  /// on the type of validation error.
  String get error => jsElement[r'error'];
  set error(String value) { jsElement[r'error'] = value; }

  /// Validate the input using HTML5 Constraints.
  ///
  /// Returns if the input is valid.
  validate() =>
      jsElement.callMethod('validate', []);

  /// Updates the label visibility based on a value. This is handled automatically
  /// if the user is typing, but if you imperatively set the input value you need
  /// to call this function.
  void updateLabelVisibility(String value) =>
      jsElement.callMethod('updateLabelVisibility', [value]);
}
