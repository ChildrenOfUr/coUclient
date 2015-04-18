// DO NOT EDIT: auto-generated with `pub run custom_element_apigen:update`

/// Dart API for the polymer element `paper_radio_group`.
@HtmlImport('paper_radio_group_nodart.html')
library paper_elements.paper_radio_group;

import 'dart:html';
import 'dart:js' show JsArray, JsObject;
import 'package:web_components/custom_element_proxy.dart';
import 'package:web_components/html_import_annotation.dart';
import 'package:core_elements/core_selector.dart';
import 'package:core_elements/core_a11y_keys.dart';
import 'paper_radio_button.dart';

/// `paper-radio-group` allows user to select only one radio button from a set.
/// Checking one radio button that belongs to a radio group unchecks any
/// previously checked radio button within the same group. Use
/// `selected` to get or set the selected radio button.
///
/// Example:
///
///     <paper-radio-group selected="small">
///       <paper-radio-button name="small" label="Small"></paper-radio-button>
///       <paper-radio-button name="medium" label="Medium"></paper-radio-button>
///       <paper-radio-button name="large" label="Large"></paper-radio-button>
///     </paper-radio-group>
///
/// See <a href="../paper-radio-button/">paper-radio-button</a> for more
/// information about `paper-radio-button`.
@CustomElementProxy('paper-radio-group')
class PaperRadioGroup extends CoreSelector {
  PaperRadioGroup.created() : super.created();
  factory PaperRadioGroup() => new Element.tag('paper-radio-group');
}
