// DO NOT EDIT: auto-generated with `pub run custom_element_apigen:update`

/// Dart API for the polymer element `core_icon`.
@HtmlImport('core_icon_nodart.html')
library core_elements.core_icon;

import 'dart:html';
import 'dart:js' show JsArray, JsObject;
import 'package:web_components/custom_element_proxy.dart';
import 'package:web_components/html_import_annotation.dart';
import 'package:custom_element_apigen/src/common.dart' show PolymerProxyMixin, DomProxyMixin;
import 'core_iconset.dart';

/// The `core-icon` element displays an icon. By default an icon renders as a 24px square.
///
/// Example using src:
///
///     <core-icon src="star.png"></core-icon>
///
/// Example setting size to 32px x 32px:
///
///     <core-icon class="big" src="big_star.png"></core-icon>
///
///     <style>
///       .big {
///         height: 32px;
///         width: 32px;
///       }
///     </style>
///
/// The core elements include several sets of icons.
/// To use the default set of icons, import  `core-icons.html` and use the `icon` attribute to specify an icon:
///
///     <link rel="import" href="/components/core-icons/core-icons.html">
///
///     <core-icon icon="menu"></core-icon>
///
/// To use a different built-in set of icons, import  `core-icons/<iconset>-icons.html`, and
/// specify the icon as `<iconset>:<icon>`. For example:
///
///     <link rel="import" href="/components/core-icons/communication-icons.html">
///
///     <core-icon icon="communication:email"></core-icon>
///
/// You can also create custom icon sets of bitmap or SVG icons.
///
/// Example of using an icon named `cherry` from a custom iconset with the ID `fruit`:
///
///     <core-icon icon="fruit:cherry"></core-icon>
///
/// See [core-iconset](#core-iconset) and [core-iconset-svg](#core-iconset-svg) for more information about
/// how to create a custom iconset.
///
/// See [core-icons](http://www.polymer-project.org/components/core-icons/demo.html) for the default set of icons.
@CustomElementProxy('core-icon')
class CoreIcon extends HtmlElement with DomProxyMixin, PolymerProxyMixin {
  CoreIcon.created() : super.created();
  factory CoreIcon() => new Element.tag('core-icon');

  /// The URL of an image for the icon. If the src property is specified,
  /// the icon property should not be.
  String get src => jsElement[r'src'];
  set src(String value) { jsElement[r'src'] = value; }

  /// Specifies the icon name or index in the set of icons available in
  /// the icon's icon set. If the icon property is specified,
  /// the src property should not be.
  String get icon => jsElement[r'icon'];
  set icon(String value) { jsElement[r'icon'] = value; }

  /// Alternative text content for accessibility support.
  /// If alt is present and not empty, it will set the element's role to img and add an aria-label whose content matches alt.
  /// If alt is present and is an empty string, '', it will hide the element from the accessibility layer
  /// If alt is not present, it will set the element's role to img and the element will fallback to using the icon attribute for its aria-label.
  String get alt => jsElement[r'alt'];
  set alt(String value) { jsElement[r'alt'] = value; }
}
