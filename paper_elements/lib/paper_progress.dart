// DO NOT EDIT: auto-generated with `pub run custom_element_apigen:update`

/// Dart API for the polymer element `paper_progress`.
@HtmlImport('paper_progress_nodart.html')
library paper_elements.paper_progress;

import 'dart:html';
import 'dart:js' show JsArray, JsObject;
import 'package:web_components/custom_element_proxy.dart';
import 'package:web_components/html_import_annotation.dart';
import 'package:core_elements/core_range.dart';

/// The progress bars are for situations where the percentage completed can be
/// determined. They give users a quick sense of how much longer an operation
/// will take.
///
/// Example:
///
///     <paper-progress value="10"></paper-progress>
///
/// There is also a secondary progress which is useful for displaying intermediate
/// progress, such as the buffer level during a streaming playback progress bar.
///
/// Example:
///
///     <paper-progress value="10" secondaryProgress="30"></paper-progress>
///
/// Styling progress bar:
///
/// To change the active progress bar color:
///
///     paper-progress::shadow #activeProgress {
///       background-color: #e91e63;
///     }
///
/// To change the secondary progress bar color:
///
///     paper-progress::shadow #secondaryProgress {
///       background-color: #f8bbd0;
///     }
///
/// To change the progress bar background color:
///
///     paper-progress::shadow #progressContainer {
///       background-color: #64ffda;
///     }
@CustomElementProxy('paper-progress')
class PaperProgress extends CoreRange {
  PaperProgress.created() : super.created();
  factory PaperProgress() => new Element.tag('paper-progress');

  /// The number that represents the current secondary progress.
  num get secondaryProgress => jsElement[r'secondaryProgress'];
  set secondaryProgress(num value) { jsElement[r'secondaryProgress'] = value; }

  /// Use an indeterminate progress indicator.
  bool get indeterminate => jsElement[r'indeterminate'];
  set indeterminate(bool value) { jsElement[r'indeterminate'] = value; }
}
