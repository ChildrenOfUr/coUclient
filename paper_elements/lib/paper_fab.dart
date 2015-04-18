// DO NOT EDIT: auto-generated with `pub run custom_element_apigen:update`

/// Dart API for the polymer element `paper_fab`.
@HtmlImport('paper_fab_nodart.html')
library paper_elements.paper_fab;

import 'dart:html';
import 'dart:js' show JsArray, JsObject;
import 'package:web_components/custom_element_proxy.dart';
import 'package:web_components/html_import_annotation.dart';
import 'paper_button_base.dart';
import 'package:core_elements/core_icon.dart';
import 'paper_ripple.dart';
import 'paper_shadow.dart';

/// Material Design: <a href="http://www.google.com/design/spec/components/buttons.html">Button</a>
///
/// `paper-fab` is a floating action button. It contains an image placed in the center and
/// comes in two sizes: regular size and a smaller size by applying the attribute `mini`. When
/// the user touches the button, a ripple effect emanates from the center of the button.
///
/// You may import `core-icons` to use with this element, or provide an URL to a custom icon.
/// See `core-iconset` for more information about how to use a custom icon set.
///
/// Example:
///
///     <link href="path/to/core-icons/core-icons.html" rel="import">
///
///     <paper-fab icon="add"></paper-fab>
///     <paper-fab mini icon="favorite"></paper-fab>
///     <paper-fab src="star.png"></paper-fab>
///
/// Styling
/// -------
///
/// Style the button with CSS as you would a normal DOM element. If you are using the icons
/// provided by `core-icons`, the icon will inherit the foreground color of the button.
///
///     /* make a blue "cloud" button */
///     <paper-fab icon="cloud" style="color: blue;"></paper-fab>
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
///     <paper-fab src="star.png" aria-label="star"></paper-fab>
@CustomElementProxy('paper-fab')
class PaperFab extends PaperButtonBase {
  PaperFab.created() : super.created();
  factory PaperFab() => new Element.tag('paper-fab');

  /// The URL of an image for the icon. If the src property is specified,
  /// the icon property should not be.
  String get src => jsElement[r'src'];
  set src(String value) { jsElement[r'src'] = value; }

  /// Specifies the icon name or index in the set of icons available in
  /// the icon's icon set. If the icon property is specified,
  /// the src property should not be.
  String get icon => jsElement[r'icon'];
  set icon(String value) { jsElement[r'icon'] = value; }

  /// Set this to true to style this is a "mini" FAB.
  bool get mini => jsElement[r'mini'];
  set mini(bool value) { jsElement[r'mini'] = value; }
}
