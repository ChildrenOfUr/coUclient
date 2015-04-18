// DO NOT EDIT: auto-generated with `pub run custom_element_apigen:update`

/// Dart API for the polymer element `paper_toast`.
@HtmlImport('paper_toast_nodart.html')
library paper_elements.paper_toast;

import 'dart:html';
import 'dart:js' show JsArray, JsObject;
import 'package:web_components/custom_element_proxy.dart';
import 'package:web_components/html_import_annotation.dart';
import 'package:custom_element_apigen/src/common.dart' show PolymerProxyMixin, DomProxyMixin;
import 'package:core_elements/core_overlay.dart';
import 'package:core_elements/core_transition_css.dart';
import 'package:core_elements/core_media_query.dart';

/// `paper-toast` provides lightweight feedback about an operation in a small popup
/// at the base of the screen on mobile and at the lower left on desktop. Toasts are
/// above all other elements on screen, including the FAB.
///
/// Toasts automatically disappear after a timeout or after user interaction
/// elsewhere on the screen, whichever comes first. Toasts can be swiped off
/// screen.  There can be only one on the screen at a time.
///
/// Example:
///
///     <paper-toast text="Your draft has been discarded." onclick="discardDraft(el)"></paper-toast>
///
///     <script>
///       function discardDraft(el) {
///         el.show();
///       }
///     </script>
///
/// An action button can be presented in the toast.
///
/// Example (using Polymer's data-binding features):
///
///     <paper-toast id="toast2" text="Connection timed out. Showing limited messages.">
///       <div style="color: blue;" on-tap="{{retry}}">Retry</div>
///     </paper-toast>
///
/// Positioning toast:
///
/// A standard toast appears near the lower left of the screen.  You can change the
/// position by overriding bottom and left positions.
///
///     paper-toast {
///       bottom: 40px;
///       left: 10px;
///     }
///
/// To position the toast to the right:
///
///     paper-toast {
///       right: 10px;
///       left: auto;
///     }
///
/// To make it fit at the bottom of the screen:
///
///     paper-toast {
///       bottom: 0;
///       left: 0;
///       width: 100%;
///     }
///
/// When the screen size is smaller than the `responsiveWidth` (default to 480px),
/// the toast will automatically fits at the bottom of the screen.
@CustomElementProxy('paper-toast')
class PaperToast extends HtmlElement with DomProxyMixin, PolymerProxyMixin {
  PaperToast.created() : super.created();
  factory PaperToast() => new Element.tag('paper-toast');

  /// The text shows in a toast.
  String get text => jsElement[r'text'];
  set text(String value) { jsElement[r'text'] = value; }

  /// The duration in milliseconds to show the toast.
  num get duration => jsElement[r'duration'];
  set duration(num value) { jsElement[r'duration'] = value; }

  /// Set opened to true to show the toast and to false to hide it.
  bool get opened => jsElement[r'opened'];
  set opened(bool value) { jsElement[r'opened'] = value; }

  /// Min-width when the toast changes to narrow layout.  In narrow layout,
  /// the toast fits at the bottom of the screen when opened.
  String get responsiveWidth => jsElement[r'responsiveWidth'];
  set responsiveWidth(String value) { jsElement[r'responsiveWidth'] = value; }

  /// If true, the toast can't be swiped.
  bool get swipeDisabled => jsElement[r'swipeDisabled'];
  set swipeDisabled(bool value) { jsElement[r'swipeDisabled'] = value; }

  /// By default, the toast will close automatically if the user taps
  /// outside it or presses the escape key. Disable this behavior by setting
  /// the `autoCloseDisabled` property to true.
  bool get autoCloseDisabled => jsElement[r'autoCloseDisabled'];
  set autoCloseDisabled(bool value) { jsElement[r'autoCloseDisabled'] = value; }

  /// Toggle the opened state of the toast.
  void toggle() =>
      jsElement.callMethod('toggle', []);

  /// Show the toast for the specified duration
  void show() =>
      jsElement.callMethod('show', []);

  /// Dismiss the toast and hide it.
  void dismiss() =>
      jsElement.callMethod('dismiss', []);
}
