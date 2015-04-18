// DO NOT EDIT: auto-generated with `pub run custom_element_apigen:update`

/// Dart API for the polymer element `core_focusable`.
@HtmlImport('core_focusable_nodart.html')
library core_elements.core_focusable;

import 'dart:html';
import 'dart:js' show JsArray, JsObject;
import 'package:web_components/custom_element_proxy.dart';
import 'package:web_components/html_import_annotation.dart';
import 'package:custom_element_apigen/src/common.dart' show DomProxyMixin;

/// `Polymer.CoreFocusable` is a mixin for elements that the user can interact with.
/// Elements using this mixin will receive attributes reflecting the focus, pressed
/// and disabled states.
abstract class CoreFocusable implements DomProxyMixin {

  /// If true, the element is currently active either because the
  /// user is touching it, or the button is a toggle
  /// and is currently in the active state.
  bool get active => jsElement[r'active'];
  set active(bool value) { jsElement[r'active'] = value; }

  /// If true, the element currently has focus due to keyboard
  /// navigation.
  bool get focused => jsElement[r'focused'];
  set focused(bool value) { jsElement[r'focused'] = value; }

  /// If true, the user is currently holding down the button.
  bool get pressed => jsElement[r'pressed'];
  set pressed(bool value) { jsElement[r'pressed'] = value; }

  /// If true, the user cannot interact with this element.
  bool get disabled => jsElement[r'disabled'];
  set disabled(bool value) { jsElement[r'disabled'] = value; }

  /// If true, the button toggles the active state with each tap.
  /// Otherwise, the button becomes active when the user is holding
  /// it down.
  bool get toggle => jsElement[r'toggle'];
  set toggle(bool value) { jsElement[r'toggle'] = value; }
}
