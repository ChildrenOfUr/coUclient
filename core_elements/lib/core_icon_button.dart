// DO NOT EDIT: auto-generated with `pub run custom_element_apigen:update`

/// Dart API for the polymer element `core_icon_button`.
@HtmlImport('core_icon_button_nodart.html')
library core_elements.core_icon_button;

import 'dart:html';
import 'dart:js' show JsArray, JsObject;
import 'package:web_components/custom_element_proxy.dart';
import 'package:web_components/html_import_annotation.dart';
import 'package:custom_element_apigen/src/common.dart' show PolymerProxyMixin, DomProxyMixin;
import 'core_icon.dart';
import 'core_icons.dart';

/// `core-icon-button` is an icon with button behaviors.
///
///     <core-icon-button src="star.png"></core-icon-button>
///
/// `core-icon-button` includes a default icon set.  Use `icon` to specify
/// which icon from the icon set to use.
///
///     <core-icon-button icon="menu"></core-icon-button>
///
/// See [`core-iconset`](#core-iconset) for more information about
/// how to use a custom icon set.
@CustomElementProxy('core-icon-button')
class CoreIconButton extends HtmlElement with DomProxyMixin, PolymerProxyMixin {
  CoreIconButton.created() : super.created();
  factory CoreIconButton() => new Element.tag('core-icon-button');

  /// The URL of an image for the icon.  Should not use `icon` property
  /// if you are using this property.
  String get src => jsElement[r'src'];
  set src(String value) { jsElement[r'src'] = value; }

  /// Specifies the icon name or index in the set of icons available in
  /// the icon set.  Should not use `src` property if you are using this
  /// property.
  String get icon => jsElement[r'icon'];
  set icon(String value) { jsElement[r'icon'] = value; }

  /// If true, border is placed around the button to indicate it's
  /// active state.
  bool get active => jsElement[r'active'];
  set active(bool value) { jsElement[r'active'] = value; }
}
