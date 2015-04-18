// DO NOT EDIT: auto-generated with `pub run custom_element_apigen:update`

/// Dart API for the polymer element `paper_tab`.
@HtmlImport('paper_tab_nodart.html')
library paper_elements.paper_tab;

import 'dart:html';
import 'dart:js' show JsArray, JsObject;
import 'package:web_components/custom_element_proxy.dart';
import 'package:web_components/html_import_annotation.dart';
import 'package:custom_element_apigen/src/common.dart' show PolymerProxyMixin, DomProxyMixin;
import 'paper_ripple.dart';

/// `paper-tab` is styled to look like a tab.  It should be used in conjunction with
/// `paper-tabs`.
///
/// Example:
///
///     <paper-tabs selected="0">
///       <paper-tab>TAB 1</paper-tab>
///       <paper-tab>TAB 2</paper-tab>
///       <paper-tab>TAB 3</paper-tab>
///     </paper-tabs>
///
/// Styling tab:
///
/// To change the ink color:
///
///     .pink paper-tab::shadow #ink {
///       color: #ff4081;
///     }
@CustomElementProxy('paper-tab')
class PaperTab extends HtmlElement with DomProxyMixin, PolymerProxyMixin {
  PaperTab.created() : super.created();
  factory PaperTab() => new Element.tag('paper-tab');

  /// If true, ink ripple effect is disabled.
  bool get noink => jsElement[r'noink'];
  set noink(bool value) { jsElement[r'noink'] = value; }
}
