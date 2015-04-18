// DO NOT EDIT: auto-generated with `pub run custom_element_apigen:update`

/// Dart API for the polymer element `core_transition_css`.
@HtmlImport('core_transition_css_nodart.html')
library core_elements.core_transition_css;

import 'dart:html';
import 'dart:js' show JsArray, JsObject;
import 'package:web_components/custom_element_proxy.dart';
import 'package:web_components/html_import_annotation.dart';
import 'core_transition.dart';

/// `<core-transition-css>` implements CSS transitions as `<core-transition>` objects so they can be
/// reused in a pluggable transition system such as in `<core-overlay>`. Currently this class has
/// some specific support to animate an element from and to the viewport such as a dialog, but you
/// can override it for different effects.
///
/// Example:
///
/// my-css-transition.html:
///
///     <polymer-element name="my-css-transition" extends="core-transition-css">
///     <template>
///         <style>
///             :host(.my-transition) {
///                 opacity: 0;
///                 transition: transform 1s ease-out, opacity 1s ease-out;
///             }
///             :host(.my-transition.my-opened) {
///                 opacity: 1;
///                 transform: none;
///             }
///             :host(.my-transition-top) {
///                 transform: translateY(-100vh);
///             }
///             :host(.my-transition-bottom) {
///                 transform: translateY(100vh);
///             }
///         </style>
///     </template>
///     <script>
///       Polymer({
///         baseClass: 'my-transition',
///         openedClass: 'my-opened'
///       });
///     </script>
///     </polymer-element>
///
///     <my-css-transition id="my-transition-top" transitionType="top"></my-css-transition>
///     <my-css-transition id="my-transition-bottom" transitionType="bottom"></my-css-transition>
///
/// my-css-transition-demo.html
///
///     <link href="components/core-meta/core-meta.html" rel="import">
///     <link href="my-css-transition.html">
///
///     <div id="animate-me"></div>
///
///     <script>
///         // Get the core-transition
///         var meta = document.createElement('core-meta');
///         meta.type = 'transition';
///         var transition1 = meta.byId('my-transition-top');
///
///         // Set up the animation
///         var animated = document.getElementById('animate-me');
///         transition1.setup(animated);
///         transition1.go(animated, {opened: true});
///     </script>
///
/// The first element in the template of a `<core-transition-css>` object should be a stylesheet. It
/// will be injected to the scope of the animated node in the `setup` function. The node is initially
/// invisible with `opacity: 0`, and you can transition it to an "opened" state by passing
/// `{opened: true}` to the `go` function.
///
/// All nodes being animated will get the class `my-transition` added in the `setup` function.
/// Additionally, the class `my-transition-<transitionType>` will be applied. You can use the
/// `transitionType` attribute to implement several different behaviors with the same
/// `<core-transition-css>` object. In the above example, `<my-css-transition>` implements both
/// sliding the node from the top of the viewport and from the bottom of the viewport.
///
/// Available transitions
/// ---------------------
///
/// `<core-transition-css>` includes several commonly used transitions.
///
/// `core-transition-fade`: Animates from `opacity: 0` to `opacity: 1` when it opens.
///
/// `core-transition-center`: Zooms the node into the final size.
///
/// `core-transition-top`: Slides the node into the final position from the top.
///
/// `core-transition-bottom`: Slides the node into the final position from the bottom.
///
/// `core-transition-left`: Slides the node into the final position from the left.
///
/// `core-transition-right`: Slides the node into the final position from the right.
@CustomElementProxy('core-transition-css')
class CoreTransitionCss extends CoreTransition {
  CoreTransitionCss.created() : super.created();
  factory CoreTransitionCss() => new Element.tag('core-transition-css');

  /// A secondary configuration attribute for the animation. The class
  /// `<baseClass>-<transitionType` is applied to the animated node during
  /// `setup`.
  String get transitionType => jsElement[r'transitionType'];
  set transitionType(String value) { jsElement[r'transitionType'] = value; }

  /// The class that will be applied to all animated nodes.
  String get baseClass => jsElement[r'baseClass'];
  set baseClass(String value) { jsElement[r'baseClass'] = value; }

  /// The class that will be applied to nodes in the opened state.
  String get openedClass => jsElement[r'openedClass'];
  set openedClass(String value) { jsElement[r'openedClass'] = value; }

  /// The class that will be applied to nodes in the closed state.
  String get closedClass => jsElement[r'closedClass'];
  set closedClass(String value) { jsElement[r'closedClass'] = value; }

  /// Event to listen to for animation completion.
  String get completeEventName => jsElement[r'completeEventName'];
  set completeEventName(String value) { jsElement[r'completeEventName'] = value; }
}
