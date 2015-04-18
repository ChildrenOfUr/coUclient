// DO NOT EDIT: auto-generated with `pub run custom_element_apigen:update`

/// Dart API for the polymer element `core_scroll_threshold`.
@HtmlImport('core_scroll_threshold_nodart.html')
library core_elements.core_scroll_threshold;

import 'dart:html';
import 'dart:js' show JsArray, JsObject;
import 'package:web_components/custom_element_proxy.dart';
import 'package:web_components/html_import_annotation.dart';
import 'package:custom_element_apigen/src/common.dart' show PolymerProxyMixin, DomProxyMixin;

/// `core-scroll-threshold` is a utility element that listens for `scroll` events from a
/// scrollable region and fires events to indicate when the scroller has reached a pre-defined
/// limit, specified in pixels from the upper and lower bounds of the scrollable region.
///
/// This element may wrap a scrollable region and will listen for `scroll` events bubbling
/// through it from its children.  In this case, care should be taken that only one scrollable
/// region with the same orientation as this element is contained within.  Alternatively,
/// the `scrollTarget` property can be set/bound to a non-child scrollable region, from which
/// it will listen for events.
///
/// Once a threshold has been reached, a `lower-trigger` or `upper-trigger` event will
/// be fired, at which point the user may perform actions such as lazily-loading more data
/// to be displayed.  After any work is done, the user must then clear the threshold by
/// calling the `clearUpper` or `clearLower` methods on this element, after which it will
/// begin listening again for the scroll position to reach the threshold again assuming
/// the content in the scrollable region has grown.  If the user no longer wishes to receive
/// events (e.g. all data has been exhausted), the threshold property in question (e.g.
/// `lowerThreshold`) may be set to a falsy value to disable events and clear the associated
/// triggered property.
///
/// Example:
///
///     <core-scroll-threshold id="threshold" lowerThreshold="500"
///       on-lower-trigger="{{loadMore}}" lowerTriggered="{{spinnerShouldShow}}">
///     </core-scroll-threshold>
///
///     ...
///
///     loadMore: function() {
///       this.asyncLoadStuffThen(function() {
///         this.$.threshold.clearLower();
///       }.bind(this));
///     }
@CustomElementProxy('core-scroll-threshold')
class CoreScrollThreshold extends HtmlElement with DomProxyMixin, PolymerProxyMixin {
  CoreScrollThreshold.created() : super.created();
  factory CoreScrollThreshold() => new Element.tag('core-scroll-threshold');

  /// When set, the given element is observed for scroll position.  When undefined,
  /// children can be placed inside and element itself can be used as the scrollable
  /// element.
  Element get scrollTarget => jsElement[r'scrollTarget'];
  set scrollTarget(Element value) { jsElement[r'scrollTarget'] = value; }

  /// Orientation of the scroller to be observed (`v` for vertical, `h` for horizontal)
  bool get orient => jsElement[r'orient'];
  set orient(bool value) { jsElement[r'orient'] = value; }

  /// Distance from the top (or left, for horizontal) bound of the scroller
  /// where the "upper trigger" will fire.
  get upperThreshold => jsElement[r'upperThreshold'];
  set upperThreshold(value) { jsElement[r'upperThreshold'] = (value is Map || value is Iterable) ? new JsObject.jsify(value) : value;}

  /// Distance from the bottom (or right, for horizontal) bound of the scroller
  /// where the "lower trigger" will fire.
  get lowerThreshold => jsElement[r'lowerThreshold'];
  set lowerThreshold(value) { jsElement[r'lowerThreshold'] = (value is Map || value is Iterable) ? new JsObject.jsify(value) : value;}

  /// Read-only value that tracks the triggered state of the upper threshold
  bool get upperTriggered => jsElement[r'upperTriggered'];
  set upperTriggered(bool value) { jsElement[r'upperTriggered'] = value; }

  /// Read-only value that tracks the triggered state of the lower threshold
  bool get lowerTriggered => jsElement[r'lowerTriggered'];
  set lowerTriggered(bool value) { jsElement[r'lowerTriggered'] = value; }

  /// Clear the upper threshold, following an `upper-trigger` event.
  void clearUpper(bool waitForMutation) =>
      jsElement.callMethod('clearUpper', [waitForMutation]);

  /// Clear the lower threshold, following a `lower-trigger` event.
  void clearLower(bool waitForMutation) =>
      jsElement.callMethod('clearLower', [waitForMutation]);
}
