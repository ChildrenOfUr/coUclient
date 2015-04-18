// DO NOT EDIT: auto-generated with `pub run custom_element_apigen:update`

/// Dart API for the polymer element `core_animation`.
@HtmlImport('core_animation_nodart.html')
library core_elements.core_animation;

import 'dart:html';
import 'dart:js' show JsArray, JsObject;
import 'package:web_components/custom_element_proxy.dart';
import 'package:web_components/html_import_annotation.dart';
import 'package:custom_element_apigen/src/common.dart' show PolymerProxyMixin, DomProxyMixin;
import 'web_animations.dart';

/// `core-animation` is a convenience element to use web animations with Polymer elements. It
/// allows you to create a web animation declaratively. You can extend this class to create
/// new types of animations and combine them with `core-animation-group`.
///
/// Example to create animation to fade out an element over 500ms:
///
///     <core-animation id="fadeout" duration="500">
///       <core-animation-keyframe>
///         <core-animation-prop name="opacity" value="1"></core-animation-prop>
///       </core-animation-keyframe>
///       <core-animation-keyframe>
///         <core-animation-prop name="opacity" value="0"></core-animation-prop>
///       </core-animation-keyframe>
///     </core-animation>
///
///     <div id="el">Fade me out</div>
///
///     <script>
///       var animation = document.getElementById('fadeout');
///       animation.target = document.getElementById('el');
///       animation.play();
///     </script>
///
/// Or do the same imperatively:
///
///     var animation = new CoreAnimation();
///     animation.duration = 500;
///     animation.keyframes = [
///       {opacity: 1},
///       {opacity: 0}
///     ];
///     animation.target = document.getElementById('el');
///     animation.play();
///
/// You can also provide a javascript function instead of keyframes to the animation. This
/// behaves essentially the same as `requestAnimationFrame`:
///
///     var animation = new CoreAnimation();
///     animation.customEffect = function(timeFraction, target, animation) {
///       // do something custom
///     };
///     animation.play();
///
/// Elements that are targets to a `core-animation` are given the `core-animation-target` class.
@CustomElementProxy('core-animation')
class CoreAnimation extends HtmlElement with DomProxyMixin, PolymerProxyMixin {
  CoreAnimation.created() : super.created();
  factory CoreAnimation() => new Element.tag('core-animation');

  /// One or more nodes to animate.
  get target => jsElement[r'target'];
  set target(value) { jsElement[r'target'] = (value is Map || value is Iterable) ? new JsObject.jsify(value) : value;}

  /// Animation keyframes specified as an array of dictionaries of
  /// &lt;css properties&gt;:&lt;array of values&gt; pairs. For example,
  get keyframes => jsElement[r'keyframes'];
  set keyframes(value) { jsElement[r'keyframes'] = (value is Map || value is Iterable) ? new JsObject.jsify(value) : value;}

  /// A custom animation function. Either provide this or `keyframes`. The signature
  /// of the callback is `EffectsCallback(timeFraction, target, animation)`
  get customEffect => jsElement[r'customEffect'];
  set customEffect(value) { jsElement[r'customEffect'] = (value is Map || value is Iterable) ? new JsObject.jsify(value) : value;}

  /// Controls the composition behavior. If set to "replace", the effect overrides
  /// the underlying value for the target. If set the "add", the effect is added to
  /// the underlying value for the target. If set to "accumulate", the effect is
  /// accumulated to the underlying value for the target.
  ///
  /// In cases such as numbers or lengths, "add" and "accumulate" produce the same
  /// value. In list values, "add" is appending to the list, while "accumulate" is
  /// adding the individual components of the list.
  ///
  /// For example, adding `translateX(10px)` and `translateX(25px)` produces
  /// `translateX(10px) translateX(25px)` and accumulating produces `translateX(35px)`.
  get composite => jsElement[r'composite'];
  set composite(value) { jsElement[r'composite'] = (value is Map || value is Iterable) ? new JsObject.jsify(value) : value;}

  /// Animation duration in milliseconds, "Infinity", or "auto". "auto" is
  /// equivalent to 0.
  get duration => jsElement[r'duration'];
  set duration(value) { jsElement[r'duration'] = (value is Map || value is Iterable) ? new JsObject.jsify(value) : value;}

  /// Controls the effect the animation has on the target when it's not playing.
  /// The possible values are "none", "forwards", "backwards", "both" or "auto".
  ///
  /// "none" means the animation has no effect when it's not playing.
  ///
  /// "forwards" applies the value at the end of the animation after it's finished.
  ///
  /// "backwards" applies the value at the start of the animation to the target
  /// before it starts playing and has no effect when the animation finishes.
  ///
  /// "both" means "forwards" and "backwards". "auto" is equivalent to "none".
  get fill => jsElement[r'fill'];
  set fill(value) { jsElement[r'fill'] = (value is Map || value is Iterable) ? new JsObject.jsify(value) : value;}

  /// A transition timing function. The values are equivalent to the CSS
  /// counterparts.
  String get easing => jsElement[r'easing'];
  set easing(String value) { jsElement[r'easing'] = value; }

  /// Number of iterations into the animation in which to begin the effect.
  /// For example, setting this property to 0.5 and `iterations` to 2 will
  /// cause the animation to begin halfway through the first iteration but still
  /// run twice.
  num get iterationStart => jsElement[r'iterationStart'];
  set iterationStart(num value) { jsElement[r'iterationStart'] = value; }

  get iterationCount => jsElement[r'iterationCount'];
  set iterationCount(value) { jsElement[r'iterationCount'] = (value is Map || value is Iterable) ? new JsObject.jsify(value) : value;}

  /// The number of milliseconds to delay before beginning the animation.
  num get delay => jsElement[r'delay'];
  set delay(num value) { jsElement[r'delay'] = value; }

  /// The playback direction of the animation. "normal" plays the animation in the
  /// normal direction. "reverse" plays it in the reverse direction. "alternate"
  /// alternates the playback direction every iteration such that even iterations are
  /// played normally and odd iterations are reversed. "alternate-reverse" plays
  /// even iterations in the reverse direction and odd iterations in the normal
  /// direction.
  get direction => jsElement[r'direction'];
  set direction(value) { jsElement[r'direction'] = (value is Map || value is Iterable) ? new JsObject.jsify(value) : value;}

  /// If set to true, play the animation when it is created or a property is updated.
  bool get autoplay => jsElement[r'autoplay'];
  set autoplay(bool value) { jsElement[r'autoplay'] = value; }

  get targetSelector => jsElement[r'targetSelector'];
  set targetSelector(value) { jsElement[r'targetSelector'] = (value is Map || value is Iterable) ? new JsObject.jsify(value) : value;}

  /// The number of milliseconds to wait after the animation finishes. This is
  /// useful, for example, in an animation group to wait for some time before
  /// beginning the next item in the animation group.
  num get endDelay => jsElement[r'endDelay'];
  set endDelay(num value) { jsElement[r'endDelay'] = value; }

  /// The number of iterations this animation should run for.
  get iterations => jsElement[r'iterations'];
  set iterations(value) { jsElement[r'iterations'] = (value is Map || value is Iterable) ? new JsObject.jsify(value) : value;}

  /// (not working in web animations polyfill---do not use)
  ///
  /// Controls the iteration composition behavior. If set to "replace", the effect for
  /// every iteration is independent of each other. If set to "accumulate", the effect
  /// for iterations of the animation will build upon the value in the previous iteration.
  ///
  /// Example:
  ///
  ///    // Moves the target 50px on the x-axis over 5 iterations.
  ///    <core-animation iterations="5" iterationComposite="accumulate">
  ///      <core-animation-keyframe>
  ///        <core-animation-prop name="transform" value="translateX(10px)"></core-animation-prop>
  ///      </core-animation-keyframe>
  ///    </core-animation>
  get iterationComposite => jsElement[r'iterationComposite'];
  set iterationComposite(value) { jsElement[r'iterationComposite'] = (value is Map || value is Iterable) ? new JsObject.jsify(value) : value;}

  /// A multiplier to the playback rate to the animation.
  num get playbackRate => jsElement[r'playbackRate'];
  set playbackRate(num value) { jsElement[r'playbackRate'] = value; }

  get timingProps => jsElement[r'timingProps'];

  get animationEffect => jsElement[r'animationEffect'];

  /// Plays the animation. If the animation is currently paused, seeks the animation
  /// to the beginning before starting playback.
  play() =>
      jsElement.callMethod('play', []);

  /// Stops the animation and clears all effects on the target.
  void cancel() =>
      jsElement.callMethod('cancel', []);

  /// Seeks the animation to the end.
  void finish() =>
      jsElement.callMethod('finish', []);

  /// Pauses the animation.
  void pause() =>
      jsElement.callMethod('pause', []);

  hasTarget() =>
      jsElement.callMethod('hasTarget', []);

  /// Creates a web animations object based on this object's properties, and
  /// plays it if autoplay is true.
  apply() =>
      jsElement.callMethod('apply', []);
}



/// `core-animation-keyframe` represents a keyframe in a `core-animation`. Use them as children of
/// `core-animation` elements to create web animations declaratively. If the `offset` property is
/// unset, the keyframes will be distributed evenly within the animation duration. Use
/// `core-animation-prop` elements as children of this element to specify the CSS properties for
/// the animation.
@CustomElementProxy('core-animation-keyframe')
class CoreAnimationKeyframe extends HtmlElement with DomProxyMixin, PolymerProxyMixin {
  CoreAnimationKeyframe.created() : super.created();
  factory CoreAnimationKeyframe() => new Element.tag('core-animation-keyframe');

  /// An offset from 0 to 1.
  num get animationOffset => jsElement[r'offset'];
  set animationOffset(num value) { jsElement[r'offset'] = value; }

  get properties => jsElement[r'properties'];
}



/// `core-animation-prop` represents a CSS property and value pair to use with
/// `core-animation-keyframe`.
@CustomElementProxy('core-animation-prop')
class CoreAnimationProp extends HtmlElement with DomProxyMixin, PolymerProxyMixin {
  CoreAnimationProp.created() : super.created();
  factory CoreAnimationProp() => new Element.tag('core-animation-prop');

  /// A CSS property name.
  String get name => jsElement[r'name'];
  set name(String value) { jsElement[r'name'] = value; }

  /// The value for the CSS property.
  get value => jsElement[r'value'];
  set value(value) { jsElement[r'value'] = (value is Map || value is Iterable) ? new JsObject.jsify(value) : value;}
}
