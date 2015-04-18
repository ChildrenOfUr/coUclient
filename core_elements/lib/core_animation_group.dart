// DO NOT EDIT: auto-generated with `pub run custom_element_apigen:update`

/// Dart API for the polymer element `core_animation_group`.
@HtmlImport('core_animation_group_nodart.html')
library core_elements.core_animation_group;

import 'dart:html';
import 'dart:js' show JsArray, JsObject;
import 'package:web_components/custom_element_proxy.dart';
import 'package:web_components/html_import_annotation.dart';
import 'core_animation.dart';

/// `core-animation-group` combines `core-animation` or `core-animation-group` elements to
/// create a grouped web animation. The group may be parallel (type is `par`) or sequential
/// (type is `seq`). Parallel groups play all the children elements simultaneously, and
/// sequential groups play the children one after another.
///
/// Example of an animation group to rotate and then fade an element:
///
///     <core-animation-group type="seq">
///       <core-animation id="fadeout" duration="500">
///         <core-animation-keyframe>
///           <core-animation-prop name="transform" value="rotate(0deg)"></core-animation-prop>
///           <core-animation-prop name="transform" value="rotate(45deg)"></core-animation-prop>
///         </core-animation-keyframe>
///       </core-animation>
///       <core-animation id="fadeout" duration="500">
///         <core-animation-keyframe>
///           <core-animation-prop name="opacity" value="1"></core-animation-prop>
///         </core-animation-keyframe>
///         <core-animation-keyframe>
///           <core-animation-prop name="opacity" value="0"></core-animation-prop>
///         </core-animation-keyframe>
///       </core-animation>
///     </core-animation-group>
@CustomElementProxy('core-animation-group')
class CoreAnimationGroup extends CoreAnimation {
  CoreAnimationGroup.created() : super.created();
  factory CoreAnimationGroup() => new Element.tag('core-animation-group');

  /// The type of the animation group. 'par' creates a parallel group and 'seq' creates
  /// a sequential group.
  String get type => jsElement[r'type'];
  set type(String value) { jsElement[r'type'] = value; }

  /// If target is set, any children without a target will be assigned the group's
  /// target when this property is set.
  get target => jsElement[r'target'];
  set target(value) { jsElement[r'target'] = (value is Map || value is Iterable) ? new JsObject.jsify(value) : value;}

  /// For a `core-animation-group`, a duration of "auto" means the duration should
  /// be the specified duration of its children. If set to anything other than
  /// "auto", any children without a set duration will be assigned the group's duration.
  num get duration => jsElement[r'duration'];
  set duration(num value) { jsElement[r'duration'] = value; }

  get childAnimationElements => jsElement[r'childAnimationElements'];

  get childAnimations => jsElement[r'childAnimations'];
}
