// DO NOT EDIT: auto-generated with `pub run custom_element_apigen:update`

/// Dart API for the polymer element `core_transition_pages`.
@HtmlImport('core_transition_pages_nodart.html')
library core_elements.core_transition_pages;

import 'dart:html';
import 'dart:js' show JsArray, JsObject;
import 'package:web_components/custom_element_proxy.dart';
import 'package:web_components/html_import_annotation.dart';
import '../../core_transition.dart';
import '../../core_style.dart';

/// `core-transition-pages` represents a page transition, which may include CSS and/or
/// script. It will look for a `core-style` element with the same `id` to install in the
/// scope of the `core-animated-pages` that's using the transition.
///
/// Example:
///
///     <core-style id="fooTransition">
///         // some CSS here
///     </core-style>
///     <core-transition-pages id="fooTransition"></core-transition-pages>
///
/// There are three stages to a page transition:
///
/// 1. `prepare`: Called to set up the incoming and outgoing pages to the "before" state,
///   e.g. setting the incoming page to `opacity: 0` for `cross-fade` or find and
///   measure hero elements for `hero-transition`.
///
/// 2. `go`: Called to run the transition. For CSS-based transitions, this generally
///   applies a CSS `transition` property.
///
/// 3. `complete`: Called when the elements are finished transitioning.
///
/// See the individual transition documentation for specific details.
@CustomElementProxy('core-transition-pages')
class CoreTransitionPages extends CoreTransition {
  CoreTransitionPages.created() : super.created();
  factory CoreTransitionPages() => new Element.tag('core-transition-pages');

  /// This class will be applied to the scope element in the `prepare` function.
  /// It is removed in the `complete` function. Used to activate a set of CSS
  /// rules that need to apply before the transition runs, e.g. a default opacity
  /// or transform for the non-active pages.
  String get scopeClass => jsElement[r'scopeClass'];
  set scopeClass(String value) { jsElement[r'scopeClass'] = value; }

  /// This class will be applied to the scope element in the `go` function. It is
  /// remoived in the `complete' function. Generally used to apply a CSS transition
  /// rule only during the transition.
  String get activeClass => jsElement[r'activeClass'];
  set activeClass(String value) { jsElement[r'activeClass'] = value; }

  /// Specifies which CSS property to look for when it receives a `transitionEnd` event
  /// to determine whether the transition is complete. If not specified, the first
  /// transitionEnd event received will complete the transition.
  String get transitionProperty => jsElement[r'transitionProperty'];
  set transitionProperty(String value) { jsElement[r'transitionProperty'] = value; }

  /// True if this transition is complete.
  bool get completed => jsElement[r'completed'];
  set completed(bool value) { jsElement[r'completed'] = value; }
}
