// DO NOT EDIT: auto-generated with `pub run custom_element_apigen:update`

/// Dart API for the polymer element `paper_item`.
@HtmlImport('paper_item_nodart.html')
library paper_elements.paper_item;

import 'dart:html';
import 'dart:js' show JsArray, JsObject;
import 'package:web_components/custom_element_proxy.dart';
import 'package:web_components/html_import_annotation.dart';
import 'paper_button_base.dart';
import 'paper_ripple.dart';

/// Material Design: <a href="http://www.google.com/design/spec/components/menus.html">Menus</a>
///
/// `paper-item` is a simple item object for use in menus. When the user touches the item, a ripple
/// effect emanates from the point of contact. If used in a `core-selector`, the selected item will
/// be highlighted.
///
/// Example:
///
///     <core-menu>
///         <paper-item>Cut</paper-item>
///         <paper-item>Copy</paper-item>
///         <paper-item>Paste</paper-item>
///     </core-menu>
///
/// Links
/// -----
///
/// To use as a link, put an `<a>` element in the item. You may also use the `noink` attribute to
/// prevent the ripple from "freezing" during a page navigation.
///
/// Example:
///
///     <paper-item noink>
///         <a href="http://www.polymer-project.org" layout horizontal center>Polymer</a>
///     </paper-item>
@CustomElementProxy('paper-item')
class PaperItem extends PaperButtonBase {
  PaperItem.created() : super.created();
  factory PaperItem() => new Element.tag('paper-item');

  /// If true, the button will be styled with a shadow.
  bool get raised => jsElement[r'raised'];
  set raised(bool value) { jsElement[r'raised'] = value; }

  /// By default the ripple emanates from where the user touched the button.
  /// Set this to true to always center the ripple.
  bool get recenteringTouch => jsElement[r'recenteringTouch'];
  set recenteringTouch(bool value) { jsElement[r'recenteringTouch'] = value; }

  /// By default the ripple expands to fill the button. Set this to false to
  /// constrain the ripple to a circle within the button.
  bool get fill => jsElement[r'fill'];
  set fill(bool value) { jsElement[r'fill'] = value; }
}
