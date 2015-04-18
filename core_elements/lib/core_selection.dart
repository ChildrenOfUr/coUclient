// DO NOT EDIT: auto-generated with `pub run custom_element_apigen:update`

/// Dart API for the polymer element `core_selection`.
@HtmlImport('core_selection_nodart.html')
library core_elements.core_selection;

import 'dart:html';
import 'dart:js' show JsArray, JsObject;
import 'package:web_components/custom_element_proxy.dart';
import 'package:web_components/html_import_annotation.dart';
import 'package:custom_element_apigen/src/common.dart' show PolymerProxyMixin, DomProxyMixin;

/// The `<core-selection>` element is used to manage selection state. It has no
/// visual appearance and is typically used in conjunction with another element.
/// For example, [core-selector](#core-selector)
/// uses a `<core-selection>` to manage selection.
///
/// To mark an item as selected, call the `select(item)` method on
/// `<core-selection>`. The item itself is an argument to this method.
///
/// The `<core-selection>`element manages selection state for any given set of
/// items. When an item is selected, the `core-select` event is fired.
///
/// The attribute `multi` indicates if multiple items can be selected at once.
///
/// Example:
///
///     <polymer-element name="selection-example">
///        <template>
///          <style>
///            polyfill-next-selector { content: ':host > .selected'; }
///            ::content > .selected {
///              font-weight: bold;
///              font-style: italic;
///            }
///          </style>
///          <ul on-tap="{{itemTapAction}}">
///            <content></content>
///          </ul>
///          <core-selection id="selection" multi
///                          on-core-select="{{selectAction}}"></core-selection>
///        </template>
///        <script>
///          Polymer('selection-example', {
///            itemTapAction: function(e, detail, sender) {
///              this.$.selection.select(e.target);
///            },
///            selectAction: function(e, detail, sender) {
///              detail.item.classList.toggle('selected', detail.isSelected);
///            }
///          });
///        </script>
///     </polymer-element>
///
///     <selection-example>
///       <li>Red</li>
///       <li>Green</li>
///       <li>Blue</li>
///     </selection-example>
@CustomElementProxy('core-selection')
class CoreSelection extends HtmlElement with DomProxyMixin, PolymerProxyMixin {
  CoreSelection.created() : super.created();
  factory CoreSelection() => new Element.tag('core-selection');

  /// If true, multiple selections are allowed.
  bool get multi => jsElement[r'multi'];
  set multi(bool value) { jsElement[r'multi'] = value; }

  /// Retrieves the selected item(s).
  getSelection() =>
      jsElement.callMethod('getSelection', []);

  /// Indicates if a given item is selected.
  /// [item]: The item whose selection state should be checked.
  isSelected(item) =>
      jsElement.callMethod('isSelected', [item]);

  /// Set the selection state for a given `item`. If the multi property
  /// is true, then the selected state of `item` will be toggled; otherwise
  /// the `item` will be selected.
  /// [item]: The item to select.
  void select(item) =>
      jsElement.callMethod('select', [item]);

  /// Toggles the selection state for `item`.
  /// [item]: The item to toggle.
  void toggle(item) =>
      jsElement.callMethod('toggle', [item]);
}
