// DO NOT EDIT: auto-generated with `pub run custom_element_apigen:update`

/// Dart API for the polymer element `paper_icon_button`.
@HtmlImport('paper_icon_button_nodart.html')
library paper_elements.paper_icon_button;

import 'dart:html';
import 'dart:js' show JsArray, JsObject;
import 'package:web_components/custom_element_proxy.dart';
import 'package:web_components/html_import_annotation.dart';
import 'paper_button_base.dart';
import 'package:core_elements/core_icon.dart';
import 'package:core_elements/core_icons.dart';
import 'paper_ripple.dart';

/// Material Design: <a href="http://www.google.com/design/spec/components/buttons.html">Buttons</a>
///
/// `paper-icon-button` is a button with an image placed at the center. When the user touches
/// the button, a ripple effect emanates from the center of the button.
///
/// `paper-icon-button` includes a default icon set.  Use `icon` to specify which icon
/// from the icon set to use.
///
///     <paper-icon-button icon="menu"></paper-icon-button>
///
/// See [`core-iconset`](#core-iconset) for more information about
/// how to use a custom icon set.
///
/// Example:
///
///     <link href="path/to/core-icons/core-icons.html" rel="import">
///
///     <paper-icon-button icon="favorite"></paper-icon-button>
///     <paper-icon-button src="star.png"></paper-icon-button>
///
/// Styling
/// -------
///
/// Style the button with CSS as you would a normal DOM element. If you are using the icons
/// provided by `core-icons`, they will inherit the foreground color of the button.
///
///     /* make a red "favorite" button */
///     <paper-icon-button icon="favorite" style="color: red;"></paper-icon-button>
///
/// By default, the ripple is the same color as the foreground at 25% opacity. You may
/// customize the color using this selector:
///
///     /* make #my-button use a blue ripple instead of foreground color */
///     #my-button::shadow #ripple {
///       color: blue;
///     }
///
/// The opacity of the ripple is not customizable via CSS.
///
/// Accessibility
/// -------------
///
/// The button is accessible by default if you use the `icon` property. By default, the
/// `aria-label` attribute will be set to the `icon` property. If you use a custom icon,
/// you should ensure that the `aria-label` attribute is set.
///
///     <paper-icon-button src="star.png" aria-label="star"></paper-icon-button>
@CustomElementProxy('paper-icon-button')
class PaperIconButton extends PaperButtonBase {
  PaperIconButton.created() : super.created();
  factory PaperIconButton() => new Element.tag('paper-icon-button');

  /// The URL of an image for the icon. If the src property is specified,
  /// the icon property should not be.
  String get src => jsElement[r'src'];
  set src(String value) { jsElement[r'src'] = value; }

  /// Specifies the icon name or index in the set of icons available in
  /// the icon's icon set. If the icon property is specified,
  /// the src property should not be.
  String get icon => jsElement[r'icon'];
  set icon(String value) { jsElement[r'icon'] = value; }
}
