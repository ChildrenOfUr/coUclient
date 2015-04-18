// DO NOT EDIT: auto-generated with `pub run custom_element_apigen:update`

/// Dart API for the polymer element `paper_tabs`.
@HtmlImport('paper_tabs_nodart.html')
library paper_elements.paper_tabs;

import 'dart:html';
import 'dart:js' show JsArray, JsObject;
import 'package:web_components/custom_element_proxy.dart';
import 'package:web_components/html_import_annotation.dart';
import 'package:core_elements/core_selector.dart';
import 'package:core_elements/core_resizable.dart';
import 'paper_icon_button.dart';
import 'paper_tab.dart';

/// `paper-tabs` is a `core-selector` styled to look like tabs. Tabs make it easy to
/// explore and switch between different views or functional aspects of an app, or
/// to browse categorized data sets.
///
/// Use `selected` property to get or set the selected tab.
///
/// Example:
///
///     <paper-tabs selected="0">
///       <paper-tab>TAB 1</paper-tab>
///       <paper-tab>TAB 2</paper-tab>
///       <paper-tab>TAB 3</paper-tab>
///     </paper-tabs>
///
/// See <a href="#paper-tab">paper-tab</a> for more information about
/// `paper-tab`.
///
/// A common usage for `paper-tabs` is to use it along with `core-pages` to switch
/// between different views.
///
///     <paper-tabs selected="{{selected}}">
///       <paper-tab>Tab 1</paper-tab>
///       <paper-tab>Tab 2</paper-tab>
///       <paper-tab>Tab 3</paper-tab>
///     </paper-tabs>
///
///     <core-pages selected="{{selected}}">
///       <div>Page 1</div>
///       <div>Page 2</div>
///       <div>Page 3</div>
///     </core-pages>
///
/// `paper-tabs` adapt to mobile/narrow layout when there is a `core-narrow` class set
/// on itself or any of its ancestors.
///
/// To use links in tabs, add `link` attribute to `paper-tabs` and put an `<a>`
/// element in `paper-tab`.
///
/// Example:
///
///     <paper-tabs selected="0" link>
///       <paper-tab>
///         <a href="#link1" horizontal center-center layout>TAB ONE</a>
///       </paper-tab>
///       <paper-tab>
///         <a href="#link2" horizontal center-center layout>TAB TWO</a>
///       </paper-tab>
///       <paper-tab>
///         <a href="#link3" horizontal center-center layout>TAB THREE</a>
///       </paper-tab>
///     </paper-tabs>
///
/// Styling tabs:
///
/// To change the sliding bar color:
///
///     paper-tabs.pink::shadow #selectionBar {
///       background-color: #ff4081;
///     }
///
/// To change the ink ripple color:
///
///     paper-tabs.pink paper-tab::shadow #ink {
///       color: #ff4081;
///     }
@CustomElementProxy('paper-tabs')
class PaperTabs extends CoreSelector with CoreResizable {
  PaperTabs.created() : super.created();
  factory PaperTabs() => new Element.tag('paper-tabs');

  /// If true, ink ripple effect is disabled.
  bool get noink => jsElement[r'noink'];
  set noink(bool value) { jsElement[r'noink'] = value; }

  /// If true, the bottom bar to indicate the selected tab will not be shown.
  bool get nobar => jsElement[r'nobar'];
  set nobar(bool value) { jsElement[r'nobar'] = value; }

  /// If true, the slide effect for the bottom bar is disabled.
  bool get noslide => jsElement[r'noslide'];
  set noslide(bool value) { jsElement[r'noslide'] = value; }

  /// If true, tabs are scrollable and the tab width is based on the label width.
  bool get scrollable => jsElement[r'scrollable'];
  set scrollable(bool value) { jsElement[r'scrollable'] = value; }

  /// If true, scroll buttons (left/right arrow) will be hidden for scrollable tabs.
  bool get hideScrollButton => jsElement[r'hideScrollButton'];
  set hideScrollButton(bool value) { jsElement[r'hideScrollButton'] = value; }

  /// If true, the tabs are aligned to bottom (the selection bar appears at the top).
  bool get alignBottom => jsElement[r'alignBottom'];
  set alignBottom(bool value) { jsElement[r'alignBottom'] = value; }

  /// If true, dragging on the tabs to scroll is disabled.
  bool get disableDrag => jsElement[r'disableDrag'];
  set disableDrag(bool value) { jsElement[r'disableDrag'] = value; }

  /// Invoke this to update the size and position of the bottom bar.  Usually
  /// you only need to call this if the `paper-tabs` is initially hidden and
  /// later becomes visible.
  void updateBar() =>
      jsElement.callMethod('updateBar', []);
}
