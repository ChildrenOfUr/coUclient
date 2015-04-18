// DO NOT EDIT: auto-generated with `pub run custom_element_apigen:update`

/// Dart API for the polymer element `core_transition`.
@HtmlImport('core_transition_nodart.html')
library core_elements.core_transition;

import 'dart:html';
import 'dart:js' show JsArray, JsObject;
import 'package:web_components/custom_element_proxy.dart';
import 'package:web_components/html_import_annotation.dart';
import 'core_meta.dart';

/// `<core-transition>` is an abstraction of an animation. It is used to implement pluggable
/// transitions, for example in `<core-overlay>`. You can extend this class to create a custom
/// animation, instantiate it, and import it where you need the animation.
///
/// All instances of `<core-transition>` are stored in a single database with `type=transition`.
/// For more about the database, please see the documentation for `<core-meta>`.
///
/// Each instance of `<core-transition>` objects are shared across all the clients, so you should
/// not store state information specific to the animated element in the transition. Rather, store
/// it on the element.
///
/// Example:
///
/// my-transition.html:
///
///     <polymer-element name="my-transition" extends="core-transition">
///         <script>
///             go: function(node) {
///                 node.style.transition = 'opacity 1s ease-out';
///                 node.style.opacity = 0;
///             }
///         </script>
///     </polymer-element>
///
///     <my-transition id="my-fade-out"></my-transition>
///
/// my-transition-demo.html:
///
///     <link href="components/core-meta/core-meta.html" rel="import">
///     <link href="my-transition.html" rel="import">
///
///     <div id="animate-me"></div>
///
///     <script>
///         // Get the core-transition
///         var meta = document.createElement('core-meta');
///         meta.type = 'transition';
///         var transition = meta.byId('my-fade-out');
///
///         // Run the animation
///         var animated = document.getElementById('animate-me');
///         transition.go(animated);
///     </script>
@CustomElementProxy('core-transition')
class CoreTransition extends CoreMeta {
  CoreTransition.created() : super.created();
  factory CoreTransition() => new Element.tag('core-transition');

  /// Run the animation.
  /// [node]: The node to apply the animation on
  /// [state]: State info
  void go(node, state) =>
      jsElement.callMethod('go', [node, state]);

  /// Set up the animation. This may include injecting a stylesheet,
  /// applying styles, creating a web animations object, etc.. This
  /// [node]: The animated node
  void setup(node) =>
      jsElement.callMethod('setup', [node]);

  /// Tear down the animation.
  /// [node]: The animated node
  void teardown(node) =>
      jsElement.callMethod('teardown', [node]);

  /// Called when the animation completes. This function also fires the
  /// `core-transitionend` event.
  /// [node]: The animated node
  void complete(node) =>
      jsElement.callMethod('complete', [node]);

  /// Utility function to listen to an event on a node once.
  /// [node]: The animated node
  /// [event]: Name of an event
  /// [fn]: Event handler
  /// [args]: Additional arguments to pass to `fn`
  void listenOnce(node, String event, fn, JsArray args) =>
      jsElement.callMethod('listenOnce', [node, event, fn, args]);
}
