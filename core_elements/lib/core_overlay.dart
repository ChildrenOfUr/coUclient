// DO NOT EDIT: auto-generated with `pub run custom_element_apigen:update`

/// Dart API for the polymer element `core_overlay`.
@HtmlImport('core_overlay_nodart.html')
library core_elements.core_overlay;

import 'dart:html';
import 'dart:js' show JsArray, JsObject;
import 'package:web_components/custom_element_proxy.dart';
import 'package:web_components/html_import_annotation.dart';
import 'package:custom_element_apigen/src/common.dart' show PolymerProxyMixin, DomProxyMixin;
import 'core_resizer.dart';
import 'core_resizable.dart';
import 'core_transition.dart';
import 'core_key_helper.dart';
import 'core_overlay_layer.dart';

/// The `core-overlay` element displays overlayed on top of other content. It starts
/// out hidden and is displayed by setting its `opened` property to true.
/// A `core-overlay's` opened state can be toggled by calling the `toggle`
/// method.
///
/// The `core-overlay` will, by default, show/hide itself when it's opened. The
/// `target` property may be set to another element to cause that element to
/// be shown when the overlay is opened.
///
/// It's common to want a `core-overlay` to animate to its opened
/// position. The `core-overlay` element uses a `core-transition` to handle
/// animation. The default transition is `core-transition-fade` which
/// causes the overlay to fade in when displayed. See
/// <a href="../core-transition/">`core-transition`</a> for more
/// information about customizing a `core-overlay's` opening animation. The
/// `backdrop` property can be set to true to show a backdrop behind the overlay
/// that will darken the rest of the window.
///
/// An element that should close the `core-overlay` will automatically
/// do so if it's given the `core-overlay-toggle` attribute. This attribute
/// can be customized with the `closeAttribute` property. You can also use
/// `closeSelector` if more general matching is needed.
///
/// By default  `core-overlay` will close whenever the user taps outside it or
/// presses the escape key. This behavior can be turned off via the
/// `autoCloseDisabled` property.
///
///     <core-overlay>
///       <h2>Dialog</h2>
///       <input placeholder="say something..." autofocus>
///       <div>I agree with this wholeheartedly.</div>
///       <button core-overlay-toggle>OK</button>
///     </core-overlay>
///
/// `core-overlay` will automatically size and position itself according to the
/// following rules. The overlay's size is constrained such that it does not
/// overflow the screen. This is done by setting maxHeight/maxWidth on the
/// `sizingTarget`. If the `sizingTarget` already has a setting for one of these
/// properties, it will not be overridden. The overlay should
/// be positioned via css or imperatively using the `core-overlay-position` event.
/// If the overlay is not positioned vertically via setting `top` or `bottom`, it
/// will be centered vertically. The same is true horizontally via a setting to
/// `left` or `right`. In addition, css `margin` can be used to provide some space
/// around the overlay. This can be used to ensure
/// that, for example, a drop shadow is always visible around the overlay.
@CustomElementProxy('core-overlay')
class CoreOverlay extends HtmlElement with DomProxyMixin, PolymerProxyMixin, CoreResizable, CoreResizer {
  CoreOverlay.created() : super.created();
  factory CoreOverlay() => new Element.tag('core-overlay');

  /// The target element that will be shown when the overlay is
  /// opened. If unspecified, the core-overlay itself is the target.
  get target => jsElement[r'target'];
  set target(value) { jsElement[r'target'] = (value is Map || value is Iterable) ? new JsObject.jsify(value) : value;}

  /// A `core-overlay`'s size is guaranteed to be
  /// constrained to the window size. To achieve this, the sizingElement
  /// is sized with a max-height/width. By default this element is the
  /// target element, but it can be specifically set to a specific element
  /// inside the target if that is more appropriate. This is useful, for
  /// example, when a region inside the overlay should scroll if needed.
  get sizingTarget => jsElement[r'sizingTarget'];
  set sizingTarget(value) { jsElement[r'sizingTarget'] = (value is Map || value is Iterable) ? new JsObject.jsify(value) : value;}

  /// Set opened to true to show an overlay and to false to hide it.
  /// A `core-overlay` may be made initially opened by setting its
  /// `opened` attribute.
  bool get opened => jsElement[r'opened'];
  set opened(bool value) { jsElement[r'opened'] = value; }

  /// If true, the overlay has a backdrop darkening the rest of the screen.
  /// The backdrop element is attached to the document body and may be styled
  /// with the class `core-overlay-backdrop`. When opened the `core-opened`
  /// class is applied.
  bool get backdrop => jsElement[r'backdrop'];
  set backdrop(bool value) { jsElement[r'backdrop'] = value; }

  /// If true, the overlay is guaranteed to display above page content.
  bool get layered => jsElement[r'layered'];
  set layered(bool value) { jsElement[r'layered'] = value; }

  /// By default an overlay will close automatically if the user
  /// taps outside it or presses the escape key. Disable this
  /// behavior by setting the `autoCloseDisabled` property to true.
  bool get autoCloseDisabled => jsElement[r'autoCloseDisabled'];
  set autoCloseDisabled(bool value) { jsElement[r'autoCloseDisabled'] = value; }

  /// By default an overlay will focus its target or an element inside
  /// it with the `autoFocus` attribute. Disable this
  /// behavior by setting the `autoFocusDisabled` property to true.
  bool get autoFocusDisabled => jsElement[r'autoFocusDisabled'];
  set autoFocusDisabled(bool value) { jsElement[r'autoFocusDisabled'] = value; }

  /// This property specifies an attribute on elements that should
  /// close the overlay on tap. Should not set `closeSelector` if this
  /// is set.
  String get closeAttribute => jsElement[r'closeAttribute'];
  set closeAttribute(String value) { jsElement[r'closeAttribute'] = value; }

  /// This property specifies a selector matching elements that should
  /// close the overlay on tap. Should not set `closeAttribute` if this
  /// is set.
  String get closeSelector => jsElement[r'closeSelector'];
  set closeSelector(String value) { jsElement[r'closeSelector'] = value; }

  /// The transition property specifies a string which identifies a
  /// <a href="../core-transition/">`core-transition`</a> element that
  /// will be used to help the overlay open and close. The default
  /// `core-transition-fade` will cause the overlay to fade in and out.
  String get transition => jsElement[r'transition'];
  set transition(String value) { jsElement[r'transition'] = value; }

  /// Toggle the opened state of the overlay.
  void toggle() =>
      jsElement.callMethod('toggle', []);

  /// Open the overlay. This is equivalent to setting the `opened`
  /// property to true.
  void open() =>
      jsElement.callMethod('open', []);

  /// Close the overlay. This is equivalent to setting the `opened`
  /// property to false.
  void close() =>
      jsElement.callMethod('close', []);

  /// Extensions of core-overlay should implement the `resizeHandler`
  /// method to adjust the size and position of the overlay when the
  /// browser window resizes.
  void resizeHandler() =>
      jsElement.callMethod('resizeHandler', []);
}
