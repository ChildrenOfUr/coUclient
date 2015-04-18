// DO NOT EDIT: auto-generated with `pub run custom_element_apigen:update`

/// Dart API for the polymer element `core_resizer`.
@HtmlImport('core_resizer_nodart.html')
library core_elements.core_resizer;

import 'dart:html';
import 'dart:js' show JsArray, JsObject;
import 'package:web_components/custom_element_proxy.dart';
import 'package:web_components/html_import_annotation.dart';
import 'package:custom_element_apigen/src/common.dart' show DomProxyMixin;
import 'core_resizable.dart';

/// `Polymer.CoreResizable` and `Polymer.CoreResizer` are a set of mixins that can be used
/// in Polymer elements to coordinate the flow of resize events between "resizers" (elements
/// that control the size or hidden state of their children) and "resizables" (elements that
/// need to be notified when they are resized or un-hidden by their parents in order to take
/// action on their new measurements).
///
/// Elements that cause their children to be resized (e.g. a splitter control) or hide/show
/// their children (e.g. overlay) should add the `Core.CoreResizer` mixin to their
/// Polymer prototype definition and then call `this.notifyResize()` any time the element
/// resizes or un-hides its children.
///
/// `CoreResizer`'s must manually call the `resizerAttachedHandler` from the element's
/// `attached` callback and `resizerDetachedHandler` from the element's `detached`
/// callback.
///
/// Note: `CoreResizer` extends `CoreResizable`, and can listen for the `core-resize` event
/// on itself if it needs to perform resize work on itself before notifying children.
/// In this case, returning `false` from the `core-resize` event handler (or calling
/// `preventDefault` on the event) will prevent notification of children if required.
abstract class CoreResizer implements DomProxyMixin, CoreResizable {

  /// Set to `true` if the resizer is actually a peer to the elements it
  /// resizes (e.g. splitter); in this case it will listen for resize requests
  /// events from its peers on its parent.
  bool get resizerIsPeer => jsElement[r'resizerIsPeer'];
  set resizerIsPeer(bool value) { jsElement[r'resizerIsPeer'] = value; }

  /// User must call from `attached` callback
  void resizerAttachedHandler() =>
      jsElement.callMethod('resizerAttachedHandler', []);

  /// User must call from `detached` callback
  void resizerDetachedHandler() =>
      jsElement.callMethod('resizerDetachedHandler', []);

  /// User should call when resizing or un-hiding children
  void notifyResize() =>
      jsElement.callMethod('notifyResize', []);

  /// User should implement to introduce filtering when notifying children.
  /// Generally, children that are hidden by the CoreResizer (e.g. non-active
  /// pages) need not be notified during resize, since they will be notified
  /// again when becoming un-hidden.
  ///
  /// Return `true` if CoreResizable passed as argument should be notified of
  /// resize.
  void resizeerShouldNotify(Element el) =>
      jsElement.callMethod('resizeerShouldNotify', [el]);
}
