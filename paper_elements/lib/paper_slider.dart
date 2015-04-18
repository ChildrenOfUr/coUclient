// DO NOT EDIT: auto-generated with `pub run custom_element_apigen:update`

/// Dart API for the polymer element `paper_slider`.
@HtmlImport('paper_slider_nodart.html')
library paper_elements.paper_slider;

import 'dart:html';
import 'dart:js' show JsArray, JsObject;
import 'package:web_components/custom_element_proxy.dart';
import 'package:web_components/html_import_annotation.dart';
import 'package:core_elements/core_range.dart';
import 'package:core_elements/core_a11y_keys.dart';
import 'paper_progress.dart';
import 'paper_input.dart';

/// `paper-slider` allows user to select a value from a range of values by
/// moving the slider thumb.  The interactive nature of the slider makes it a
/// great choice for settings that reflect intensity levels, such as volume,
/// brightness, or color saturation.
///
/// Example:
///
///     <paper-slider></paper-slider>
///
/// Use `min` and `max` to specify the slider range.  Default is 0 to 100.
///
/// Example:
///
///     <paper-slider min="10" max="200" value="110"></paper-slider>
///
/// Styling slider:
///
/// To change the slider progress bar color:
///
///     paper-slider::shadow #sliderBar::shadow #activeProgress {
///       background-color: #0f9d58;
///     }
///
/// To change the slider knob color:
///
///     paper-slider::shadow #sliderKnobInner {
///       background-color: #0f9d58;
///     }
///
/// To change the slider pin color:
///
///     paper-slider::shadow #sliderKnobInner::before {
///       background-color: #0f9d58;
///     }
///
/// To change the slider pin's font color:
///
///     paper-slider::shadow #sliderKnob > #sliderKnobInner::after {
///       color: #0f9d58
///     }
///
/// To change the slider secondary progress bar color:
///
///     paper-slider::shadow #sliderBar::shadow #secondaryProgress {
///       background-color: #0f9d58;
///     }
@CustomElementProxy('paper-slider')
class PaperSlider extends CoreRange {
  PaperSlider.created() : super.created();
  factory PaperSlider() => new Element.tag('paper-slider');

  /// If true, the slider thumb snaps to tick marks evenly spaced based
  /// on the `step` property value.
  bool get snaps => jsElement[r'snaps'];
  set snaps(bool value) { jsElement[r'snaps'] = value; }

  /// If true, a pin with numeric value label is shown when the slider thumb
  /// is pressed.  Use for settings for which users need to know the exact
  /// value of the setting.
  bool get pin => jsElement[r'pin'];
  set pin(bool value) { jsElement[r'pin'] = value; }

  /// If true, this slider is disabled.  A disabled slider cannot be tapped
  /// or dragged to change the slider value.
  bool get disabled => jsElement[r'disabled'];
  set disabled(bool value) { jsElement[r'disabled'] = value; }

  /// The number that represents the current secondary progress.
  num get secondaryProgress => jsElement[r'secondaryProgress'];
  set secondaryProgress(num value) { jsElement[r'secondaryProgress'] = value; }

  /// If true, an input is shown and user can use it to set the slider value.
  bool get editable => jsElement[r'editable'];
  set editable(bool value) { jsElement[r'editable'] = value; }

  /// The immediate value of the slider.  This value is updated while the user
  /// is dragging the slider.
  num get immediateValue => jsElement[r'immediateValue'];
  set immediateValue(num value) { jsElement[r'immediateValue'] = value; }

  /// True when the user is dragging the slider.
  bool get dragging => jsElement[r'dragging'];
  set dragging(bool value) { jsElement[r'dragging'] = value; }

  /// Increases value by `step` but not above `max`.
  void increment() =>
      jsElement.callMethod('increment', []);

  /// Decreases value by `step` but not below `min`.
  void decrement() =>
      jsElement.callMethod('decrement', []);
}
