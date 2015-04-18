// DO NOT EDIT: auto-generated with `pub run custom_element_apigen:update`

/// Dart API for the polymer element `core_toolbar`.
@HtmlImport('core_toolbar_nodart.html')
library core_elements.core_toolbar;

import 'dart:html';
import 'dart:js' show JsArray, JsObject;
import 'package:web_components/custom_element_proxy.dart';
import 'package:web_components/html_import_annotation.dart';
import 'package:custom_element_apigen/src/common.dart' show PolymerProxyMixin, DomProxyMixin;

/// `core-toolbar` is a horizontal bar containing items that can be used for
/// label, navigation, search and actions.  The items place inside the
/// `core-toolbar` are projected into a `horizontal center layout` container inside of
/// `core-toolbar`'s Shadow DOM.  You can use flex attributes to control the items'
/// sizing.
///
/// Example:
///
///     <core-toolbar>
///       <core-icon-button icon="menu" on-tap="{{menuAction}}"></core-icon-button>
///       <div flex>Title</div>
///       <core-icon-button icon="more" on-tap="{{moreAction}}"></core-icon-button>
///     </core-toolbar>
///
/// `core-toolbar` has a standard height, but can made be taller by setting `tall`
/// class on the `core-toolbar`.  This will make the toolbar 3x the normal height.
///
///     <core-toolbar class="tall">
///       <core-icon-button icon="menu"></core-icon-button>
///     </core-toolbar>
///
/// Apply `medium-tall` class to make the toolbar medium tall.  This will make the
/// toolbar 2x the normal height.
///
///     <core-toolbar class="medium-tall">
///       <core-icon-button icon="menu"></core-icon-button>
///     </core-toolbar>
///
/// When `tall`, items can pin to either the top (default), middle or bottom.  Use
/// `middle` class for middle content and `bottom` class for bottom content.
///
///     <core-toolbar class="tall">
///       <core-icon-button icon="menu"></core-icon-button>
///       <div class="middle indent">Middle Title</div>
///       <div class="bottom indent">Bottom Title</div>
///     </core-toolbar>
///
/// For `medium-tall` toolbar, the middle and bottom contents overlap and are
/// pinned to the bottom.  But `middleJustify` and `bottomJustify` attributes are
/// still honored separately.
///
/// To make an element completely fit at the bottom of the toolbar, use `fit` along
/// with `bottom`.
///
///     <core-toolbar class="tall">
///       <div id="progressBar" class="bottom fit"></div>
///     </core-toolbar>
///
/// `core-toolbar` adapts to mobile/narrow layout when there is a `core-narrow` class set
/// on itself or any of its ancestors.
@CustomElementProxy('core-toolbar')
class CoreToolbar extends HtmlElement with DomProxyMixin, PolymerProxyMixin {
  CoreToolbar.created() : super.created();
  factory CoreToolbar() => new Element.tag('core-toolbar');

  /// Controls how the items are aligned horizontally.
  /// Options are `start`, `center`, `end`, `between` and `around`.
  String get justify => jsElement[r'justify'];
  set justify(String value) { jsElement[r'justify'] = value; }

  /// Controls how the items are aligned horizontally when they are placed
  /// in the middle.
  /// Options are `start`, `center`, `end`, `between` and `around`.
  String get middleJustify => jsElement[r'middleJustify'];
  set middleJustify(String value) { jsElement[r'middleJustify'] = value; }

  /// Controls how the items are aligned horizontally when they are placed
  /// at the bottom.
  /// Options are `start`, `center`, `end`, `between` and `around`.
  String get bottomJustify => jsElement[r'bottomJustify'];
  set bottomJustify(String value) { jsElement[r'bottomJustify'] = value; }
}
