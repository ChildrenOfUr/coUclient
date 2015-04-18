// DO NOT EDIT: auto-generated with `pub run custom_element_apigen:update`

/// Dart API for the polymer element `core_resizable`.
@HtmlImport('core_resizable_nodart.html')
library core_elements.core_resizable;

import 'dart:html';
import 'dart:js' show JsArray, JsObject;
import 'package:web_components/custom_element_proxy.dart';
import 'package:web_components/html_import_annotation.dart';
import 'package:custom_element_apigen/src/common.dart' show DomProxyMixin;

/// `Polymer.CoreResizable` and `Polymer.CoreResizer` are a set of mixins that can be used
/// in Polymer elements to coordinate the flow of resize events between "resizers" (elements
/// that control the size or hidden state of their children) and "resizables" (elements that
/// need to be notified when they are resized or un-hidden by their parents in order to take
/// action on their new measurements).
///
/// Elements that perform measurement should add the `Core.Resizable` mixin to their
/// Polymer prototype definition and listen for the `core-resize` event on themselves.
/// This event will be fired when they become showing after having been hidden,
/// when they are resized explicitly by a `CoreResizer`, or when the window has been resized.
/// Note, the `core-resize` event is non-bubbling.
///
/// `CoreResizable`'s must manually call the `resizableAttachedHandler` from the element's
/// `attached` callback and `resizableDetachedHandler` from the element's `detached`
/// callback.
abstract class CoreResizable implements DomProxyMixin {

  /// User must call from `attached` callback
  void resizableAttachedHandler() =>
      jsElement.callMethod('resizableAttachedHandler', []);

  /// User must call from `detached` callback
  void resizableDetachedHandler() =>
      jsElement.callMethod('resizableDetachedHandler', []);
}
