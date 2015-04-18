// DO NOT EDIT: auto-generated with `pub run custom_element_apigen:update`

/// Dart API for the polymer element `core_scaffold`.
@HtmlImport('core_scaffold_nodart.html')
library core_elements.core_scaffold;

import 'dart:html';
import 'dart:js' show JsArray, JsObject;
import 'package:web_components/custom_element_proxy.dart';
import 'package:web_components/html_import_annotation.dart';
import 'package:custom_element_apigen/src/common.dart' show PolymerProxyMixin, DomProxyMixin;
import 'core_toolbar.dart';
import 'core_drawer_panel.dart';
import 'core_header_panel.dart';
import 'core_icon_button.dart';

/// `core-scaffold` provides general application layout, introducing a
/// responsive scaffold containing a header, toolbar, menu, title and
/// areas for application content.
///
/// Example:
///
///     <core-scaffold>
///       <core-header-panel navigation flex mode="seamed">
///         <core-toolbar>Application</core-toolbar>
///         <core-menu theme="core-light-theme">
///           <core-item icon="settings" label="item1"></core-item>
///           <core-item icon="settings" label="item2"></core-item>
///         </core-menu>
///       </core-header-panel>
///       <div tool>Title</div>
///       <div>Main content goes here...</div>
///     </core-scaffold>
///
/// Use `mode` to control the header and scrolling behavior of `core-header-panel`
/// and `responsiveWidth` to change the layout of the scaffold.  Use 'disableSwipe'
/// to disable swipe-to-open on toolbar.
///
/// Use `rightDrawer` to move position of folding toolbar to the right instead of
/// left (default).  This will also position content to the left of the menu button
/// instead of the right.  You can use `flex` within your `tool` content to push the menu
/// button to the far right:
///
///     <core-scaffold rightDrawer>
///       <div tool flex >Title</div>
///     </core-scaffold>
///
/// You may also add `middle` or `bottom` classes to your `tool` content when using tall
/// modes to adjust vertical content positioning in the core-toolbar (e.g. when using
/// mode="waterfall-tall"):
///
///     <core-scaffold rightDrawer mode="waterfall-tall">
///       <div tool flex >Title</div>
///       <div tool horizontal layout flex center-justified class="middle">Title-middle</div>
///       <div tool horizontal layout flex end-justified class="bottom">Title-bottom</div>
///     </core-scaffold>
///
/// To have the content fit to the main area, use `fit` attribute.
///
///     <core-scaffold>
///       <core-header-panel navigation flex mode="seamed">
///         ....
///       </core-header-panel>
///       <div tool>Title</div>
///       <div fit>Content fits to the main area</div>
///     </core-scaffold>
@CustomElementProxy('core-scaffold')
class CoreScaffold extends HtmlElement with DomProxyMixin, PolymerProxyMixin {
  CoreScaffold.created() : super.created();
  factory CoreScaffold() => new Element.tag('core-scaffold');

  /// Width of the drawer panel.
  String get drawerWidth => jsElement[r'drawerWidth'];
  set drawerWidth(String value) { jsElement[r'drawerWidth'] = value; }

  /// When the browser window size is smaller than the `responsiveWidth`,
  /// `core-drawer-panel` changes to a narrow layout. In narrow layout,
  /// the drawer will be stacked on top of the main panel.
  String get responsiveWidth => jsElement[r'responsiveWidth'];
  set responsiveWidth(String value) { jsElement[r'responsiveWidth'] = value; }

  /// If true, position the drawer to the right. Also place menu icon to
  /// the right of the content instead of left.
  bool get rightDrawer => jsElement[r'rightDrawer'];
  set rightDrawer(bool value) { jsElement[r'rightDrawer'] = value; }

  /// If true, swipe to open/close the drawer is disabled.
  bool get disableSwipe => jsElement[r'disableSwipe'];
  set disableSwipe(bool value) { jsElement[r'disableSwipe'] = value; }

  /// Used to control the header and scrolling behaviour of `core-header-panel`
  String get mode => jsElement[r'mode'];
  set mode(String value) { jsElement[r'mode'] = value; }

  /// Returns the scrollable element on the main area.
  get scroller => jsElement[r'scroller'];

  /// Toggle the drawer panel
  void togglePanel() =>
      jsElement.callMethod('togglePanel', []);

  /// Open the drawer panel
  void openDrawer() =>
      jsElement.callMethod('openDrawer', []);

  /// Close the drawer panel
  void closeDrawer() =>
      jsElement.callMethod('closeDrawer', []);
}
