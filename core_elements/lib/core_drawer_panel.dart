// DO NOT EDIT: auto-generated with `pub run custom_element_apigen:update`

/// Dart API for the polymer element `core_drawer_panel`.
@HtmlImport('core_drawer_panel_nodart.html')
library core_elements.core_drawer_panel;

import 'dart:html';
import 'dart:js' show JsArray, JsObject;
import 'package:web_components/custom_element_proxy.dart';
import 'package:web_components/html_import_annotation.dart';
import 'package:custom_element_apigen/src/common.dart' show PolymerProxyMixin, DomProxyMixin;
import 'core_media_query.dart';
import 'core_selector.dart';

/// `core-drawer-panel` contains a drawer panel and a main panel.  The drawer
/// and the main panel are side-by-side with drawer on the left.  When the browser
/// window size is smaller than the `responsiveWidth`, `core-drawer-panel`
/// changes to narrow layout.  In narrow layout, the drawer will be stacked on top
/// of the main panel.  The drawer will slide in/out to hide/reveal the main
/// panel.
///
/// Use the attribute `drawer` to indicate that the element is the drawer panel and
/// `main` to indicate that the element is the main panel.
///
/// Example:
///
///     <core-drawer-panel>
///       <div drawer> Drawer panel... </div>
///       <div main> Main panel... </div>
///     </core-drawer-panel>
///
/// The drawer and the main panels are not scrollable.  You can set CSS overflow
/// property on the elements to make them scrollable or use `core-header-panel`.
///
/// Example:
///
///     <core-drawer-panel>
///       <core-header-panel drawer>
///         <core-toolbar></core-toolbar>
///         <div> Drawer content... </div>
///       </core-header-panel>
///       <core-header-panel main>
///         <core-toolbar></core-toolbar>
///         <div> Main content... </div>
///       </core-header-panel>
///     </core-drawer-panel>
///
/// An element that should toggle the drawer will automatically do so if it's
/// given the `core-drawer-toggle` attribute.  Also this element will automatically
/// be hidden in wide layout.
///
/// Example:
///
///     <core-drawer-panel>
///       <core-header-panel drawer>
///         <core-toolbar>
///           <div>Application</div>
///         </core-toolbar>
///         <div> Drawer content... </div>
///       </core-header-panel>
///       <core-header-panel main>
///         <core-toolbar>
///           <core-icon-button icon="menu" core-drawer-toggle></core-icon-button>
///           <div>Title</div>
///         </core-toolbar>
///         <div> Main content... </div>
///       </core-header-panel>
///     </core-drawer-panel>
///
/// To position the drawer to the right, add `rightDrawer` attribute.
///
///     <core-drawer-panel rightDrawer>
///       <div drawer> Drawer panel... </div>
///       <div main> Main panel... </div>
///     </core-drawer-panel>
@CustomElementProxy('core-drawer-panel')
class CoreDrawerPanel extends HtmlElement with DomProxyMixin, PolymerProxyMixin {
  CoreDrawerPanel.created() : super.created();
  factory CoreDrawerPanel() => new Element.tag('core-drawer-panel');

  /// Width of the drawer panel.
  String get drawerWidth => jsElement[r'drawerWidth'];
  set drawerWidth(String value) { jsElement[r'drawerWidth'] = value; }

  /// Max-width when the panel changes to narrow layout.
  String get responsiveWidth => jsElement[r'responsiveWidth'];
  set responsiveWidth(String value) { jsElement[r'responsiveWidth'] = value; }

  /// The panel that is being selected. `drawer` for the drawer panel and
  /// `main` for the main panel.
  String get selected => jsElement[r'selected'];
  set selected(String value) { jsElement[r'selected'] = value; }

  /// The panel to be selected when `core-drawer-panel` changes to narrow
  /// layout.
  String get defaultSelected => jsElement[r'defaultSelected'];
  set defaultSelected(String value) { jsElement[r'defaultSelected'] = value; }

  /// Returns true if the panel is in narrow layout.  This is useful if you
  /// need to show/hide elements based on the layout.
  bool get narrow => jsElement[r'narrow'];
  set narrow(bool value) { jsElement[r'narrow'] = value; }

  /// If true, position the drawer to the right.
  bool get rightDrawer => jsElement[r'rightDrawer'];
  set rightDrawer(bool value) { jsElement[r'rightDrawer'] = value; }

  /// If true, swipe to open/close the drawer is disabled.
  bool get disableSwipe => jsElement[r'disableSwipe'];
  set disableSwipe(bool value) { jsElement[r'disableSwipe'] = value; }

  /// If true, ignore `responsiveWidth` setting and force the narrow layout.
  bool get forceNarrow => jsElement[r'forceNarrow'];
  set forceNarrow(bool value) { jsElement[r'forceNarrow'] = value; }

  /// If true, swipe from the edge is disable.
  bool get disableEdgeSwipe => jsElement[r'disableEdgeSwipe'];
  set disableEdgeSwipe(bool value) { jsElement[r'disableEdgeSwipe'] = value; }

  /// Toggles the panel open and closed.
  void togglePanel() =>
      jsElement.callMethod('togglePanel', []);

  /// Opens the drawer.
  void openDrawer() =>
      jsElement.callMethod('openDrawer', []);

  /// Closes the drawer.
  void closeDrawer() =>
      jsElement.callMethod('closeDrawer', []);
}
