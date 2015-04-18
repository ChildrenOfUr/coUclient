// DO NOT EDIT: auto-generated with `pub run custom_element_apigen:update`

/// Dart API for the polymer element `paper_dropdown_transition`.
@HtmlImport('paper_dropdown_transition_nodart.html')
library paper_elements.paper_dropdown_transition;

import 'dart:html';
import 'dart:js' show JsArray, JsObject;
import 'package:web_components/custom_element_proxy.dart';
import 'package:web_components/html_import_annotation.dart';
import 'package:core_elements/core_transition_css.dart';
import 'package:core_elements/web_animations.dart';

/// `paper-dropdown-transition` is a transition for `paper-dropdown`.
///
/// Add the class `menu` to a `core-selector` child of the `paper-dropdown` to
/// enable the optional list cascade transition.
@CustomElementProxy('paper-dropdown-transition')
class PaperDropdownTransition extends CoreTransitionCss {
  PaperDropdownTransition.created() : super.created();
  factory PaperDropdownTransition() => new Element.tag('paper-dropdown-transition');

  /// The duration of the transition in ms. You can also set the duration by
  /// setting a `duration` attribute on the target:
  ///
  ///    <paper-dropdown duration="1000"></paper-dropdown>
  num get duration => jsElement[r'duration'];
  set duration(num value) { jsElement[r'duration'] = value; }
}
