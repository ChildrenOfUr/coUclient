// DO NOT EDIT: auto-generated with `pub run custom_element_apigen:update`

/// Dart API for the polymer element `paper_button`.
@HtmlImport('paper_button_nodart.html')
library paper_elements.paper_button;

import 'dart:html';
import 'dart:js' show JsArray, JsObject;
import 'package:web_components/custom_element_proxy.dart';
import 'package:web_components/html_import_annotation.dart';
import 'paper_button_base.dart';
import 'paper_shadow.dart';
import 'package:core_elements/core_a11y_keys.dart';

/// Material Design: <a href="http://www.google.com/design/spec/components/buttons.html">Buttons</a>
///
/// `paper-button` is a button. When the user touches the button, a ripple effect emanates
/// from the point of contact. It may be flat or raised. A raised button is styled with a
/// shadow.
///
/// Example:
///
///     <paper-button>flat button</paper-button>
///     <paper-button raised>raised button</paper-button>
///     <paper-button noink>No ripple effect</paper-button>
///
/// You may use custom DOM in the button body to create a variety of buttons. For example, to
/// create a button with an icon and some text:
///
///     <paper-button>
///       <core-icon icon="favorite"></core-icon>
///       custom button content
///     </paper-button>
///
/// ## Styling
///
/// Style the button with CSS as you would a normal DOM element.
///
///     /* make #my-button green with yellow text */
///     #my-button {
///         background: green;
///         color: yellow;
///     }
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
@CustomElementProxy('paper-button')
class PaperButton extends PaperButtonBase {
  PaperButton.created() : super.created();
  factory PaperButton() => new Element.tag('paper-button');

  /// If true, the button will be styled with a shadow.
  bool get raised => jsElement[r'raised'];
  set raised(bool value) { jsElement[r'raised'] = value; }

  /// By default the ripple emanates from where the user touched the button.
  /// Set this to true to always center the ripple.
  bool get recenteringTouch => jsElement[r'recenteringTouch'];
  set recenteringTouch(bool value) { jsElement[r'recenteringTouch'] = value; }

  /// By default the ripple expands to fill the button. Set this to true to
  /// constrain the ripple to a circle within the button.
  bool get fill => jsElement[r'fill'];
  set fill(bool value) { jsElement[r'fill'] = value; }
}
