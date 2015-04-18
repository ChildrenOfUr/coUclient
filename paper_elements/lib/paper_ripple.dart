// DO NOT EDIT: auto-generated with `pub run custom_element_apigen:update`

/// Dart API for the polymer element `paper_ripple`.
@HtmlImport('paper_ripple_nodart.html')
library paper_elements.paper_ripple;

import 'dart:html';
import 'dart:js' show JsArray, JsObject;
import 'package:web_components/custom_element_proxy.dart';
import 'package:web_components/html_import_annotation.dart';
import 'package:custom_element_apigen/src/common.dart' show PolymerProxyMixin, DomProxyMixin;

/// `paper-ripple` provides a visual effect that other paper elements can
/// use to simulate a rippling effect emanating from the point of contact.  The
/// effect can be visualized as a concentric circle with motion.
///
/// Example:
///
///     <paper-ripple></paper-ripple>
///
/// `paper-ripple` listens to "down" and "up" events so it would display ripple
/// effect when touches on it.  You can also defeat the default behavior and
/// manually route the down and up actions to the ripple element.  Note that it is
/// important if you call downAction() you will have to make sure to call upAction()
/// so that `paper-ripple` would end the animation loop.
///
/// Example:
///
///     <paper-ripple id="ripple" style="pointer-events: none;"></paper-ripple>
///     ...
///     downAction: function(e) {
///       this.$.ripple.downAction({x: e.x, y: e.y});
///     },
///     upAction: function(e) {
///       this.$.ripple.upAction();
///     }
///
/// Styling ripple effect:
///
///   Use CSS color property to style the ripple:
///
///     paper-ripple {
///       color: #4285f4;
///     }
///
///   Note that CSS color property is inherited so it is not required to set it on
///   the `paper-ripple` element directly.
///
/// By default, the ripple is centered on the point of contact.  Apply `recenteringTouch`
/// class to have the ripple grow toward the center of its container.
///
///     <paper-ripple class="recenteringTouch"></paper-ripple>
///
/// Apply `circle` class to make the rippling effect within a circle.
///
///     <paper-ripple class="circle"></paper-ripple>
@CustomElementProxy('paper-ripple')
class PaperRipple extends HtmlElement with DomProxyMixin, PolymerProxyMixin {
  PaperRipple.created() : super.created();
  factory PaperRipple() => new Element.tag('paper-ripple');

  /// The initial opacity set on the wave.
  num get initialOpacity => jsElement[r'initialOpacity'];
  set initialOpacity(num value) { jsElement[r'initialOpacity'] = value; }

  /// How fast (opacity per second) the wave fades out.
  num get opacityDecayVelocity => jsElement[r'opacityDecayVelocity'];
  set opacityDecayVelocity(num value) { jsElement[r'opacityDecayVelocity'] = value; }
}
