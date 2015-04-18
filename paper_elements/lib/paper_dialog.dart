// DO NOT EDIT: auto-generated with `pub run custom_element_apigen:update`

/// Dart API for the polymer element `paper_dialog`.
@HtmlImport('paper_dialog_nodart.html')
library paper_elements.paper_dialog;

import 'dart:html';
import 'dart:js' show JsArray, JsObject;
import 'package:web_components/custom_element_proxy.dart';
import 'package:web_components/html_import_annotation.dart';
import 'paper_dialog_base.dart';
import 'paper_shadow.dart';

/// Material Design: <a href="http://www.google.com/design/spec/components/dialogs.html">Dialogs</a>
///
/// `paper-dialog` is an overlay with a drop shadow.
///
/// Example:
///
///     <paper-dialog heading="Dialog Title">
///       <p>Some content</p>
///     </paper-dialog>
///
/// Styling
/// -------
///
/// Because a `paper-dialog` is `layered` by default, you need to use the `/deep/`
/// combinator to style all instances of the `paper-dialog`. Style the position,
/// colors and other inherited properties of the dialog using the
/// `html /deep/ paper-dialog` selector. Use the `html /deep/ paper-dialog::shadow #scroller` selector to size the dialog. Note that if you provided actions, the height
/// of the actions will be added to the height of the dialog.
///
///     html /deep/ paper-dialog {
///         color: green;
///     }
///
///     html /deep/ paper-dialog::shadow #scroller {
///         height: 300px;
///         width: 300px;
///     }
///
/// Transitions
/// -----------
///
/// You can use transitions provided by `core-transition` with this element.
///
///     <paper-dialog transition="core-transition-center">
///       <p>Some content</p>
///     </paper-dialog>
///
/// Accessibility
/// -------------
///
/// By default, the `aria-label` will be set to the value of the `heading` attribute.
@CustomElementProxy('paper-dialog')
class PaperDialog extends PaperDialogBase {
  PaperDialog.created() : super.created();
  factory PaperDialog() => new Element.tag('paper-dialog');
}
