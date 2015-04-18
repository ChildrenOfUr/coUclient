// DO NOT EDIT: auto-generated with `pub run custom_element_apigen:update`

/// Dart API for the polymer element `core_dropdown`.
@HtmlImport('core_dropdown_nodart.html')
library core_elements.core_dropdown;

import 'dart:html';
import 'dart:js' show JsArray, JsObject;
import 'package:web_components/custom_element_proxy.dart';
import 'package:web_components/html_import_annotation.dart';
import 'core_overlay.dart';

/// `core-dropdown` is an element that is initially hidden and is positioned relatively to another
/// element, usually the element that triggers the dropdown. The dropdown and the triggering element
/// should be children of the same offsetParent, e.g. the same `<div>` with `position: relative`.
/// It can be used to implement dropdown menus, menu buttons, etc..
///
/// Example:
///
///     <template is="auto-binding">
///       <div relative>
///         <core-icon-button id="trigger" icon="menu"></core-icon-button>
///         <core-dropdown relatedTarget="{{$.trigger}}">
///           <core-menu>
///             <core-item>Cut</core-item>
///             <core-item>Copy</core-item>
///             <core-item>Paste</core-item>
///           </core-menu>
///         </core-dropdown>
///       </div>
///     </template>
///
/// Positioning
/// -----------
///
/// By default, the dropdown is absolutely positioned on top of the `relatedTarget` with the top and
/// left edges aligned. The `halign` and `valign` properties controls the various alignments. The size
/// of the dropdown is automatically restrained such that it is entirely visible on the screen. Use the
/// `margin`
///
/// If you need more control over the dropdown's position, use CSS. The `halign` and `valign` properties are
/// ignored if the dropdown is positioned with CSS.
///
/// Example:
///
///     <style>
///       /* manually position the dropdown below the trigger */
///       core-dropdown {
///         position: absolute;
///         top: 38px;
///         left: 0;
///       }
///     </style>
///
///     <template is="auto-binding">
///       <div relative>
///         <core-icon-button id="trigger" icon="menu"></core-icon-button>
///         <core-dropdown relatedTarget="{{$.trigger}}">
///           <core-menu>
///             <core-item>Cut</core-item>
///             <core-item>Copy</core-item>
///             <core-item>Paste</core-item>
///           </core-menu>
///         </core-dropdown>
///       </div>
///     </template>
///
/// The `layered` property
/// ----------------------
///
/// Sometimes you may need to render the dropdown in a separate layer. For example,
/// it may be nested inside an element that needs to be `overflow: hidden`, or
/// its parent may be overlapped by elements above it in stacking order.
///
/// The `layered` property will place the dropdown in a separate layer to ensure
/// it appears on top of everything else. Note that this implies the dropdown will
/// not scroll with its container.
@CustomElementProxy('core-dropdown')
class CoreDropdown extends CoreOverlay {
  CoreDropdown.created() : super.created();
  factory CoreDropdown() => new Element.tag('core-dropdown');

  /// The element associated with this dropdown, usually the element that triggers
  /// the menu. If unset, this property will default to the target's parent node
  /// or shadow host.
  get relatedTarget => jsElement[r'relatedTarget'];
  set relatedTarget(value) { jsElement[r'relatedTarget'] = (value is Map || value is Iterable) ? new JsObject.jsify(value) : value;}

  /// The horizontal alignment of the popup relative to `relatedTarget`. `left`
  /// means the left edges are aligned together. `right` means the right edges
  /// are aligned together.
  ///
  /// Accepted values: 'left', 'right'
  String get halign => jsElement[r'halign'];
  set halign(String value) { jsElement[r'halign'] = value; }

  /// The vertical alignment of the popup relative to `relatedTarget`. `top` means
  /// the top edges are aligned together. `bottom` means the bottom edges are
  /// aligned together.
  ///
  /// Accepted values: 'top', 'bottom'
  String get valign => jsElement[r'valign'];
  set valign(String value) { jsElement[r'valign'] = value; }
}
