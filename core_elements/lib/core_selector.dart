// DO NOT EDIT: auto-generated with `pub run custom_element_apigen:update`

/// Dart API for the polymer element `core_selector`.
@HtmlImport('core_selector_nodart.html')
library core_elements.core_selector;

import 'dart:html';
import 'dart:js' show JsArray, JsObject;
import 'package:web_components/custom_element_proxy.dart';
import 'package:web_components/html_import_annotation.dart';
import 'package:custom_element_apigen/src/common.dart' show PolymerProxyMixin, DomProxyMixin;
import 'core_selection.dart';

/// `<core-selector>` is used to manage a list of elements that can be selected.
///
/// The attribute `selected` indicates which item element is being selected.
/// The attribute `multi` indicates if multiple items can be selected at once.
/// Tapping on the item element would fire `core-activate` event. Use
/// `core-select` event to listen for selection changes.
///
/// Example:
///
///     <core-selector selected="0">
///       <div>Item 1</div>
///       <div>Item 2</div>
///       <div>Item 3</div>
///     </core-selector>
///
/// `<core-selector>` is not styled. Use the `core-selected` CSS class to style the selected element.
///
///     <style>
///       .item.core-selected {
///         background: #eee;
///       }
///     </style>
///     ...
///     <core-selector>
///       <div class="item">Item 1</div>
///       <div class="item">Item 2</div>
///       <div class="item">Item 3</div>
///     </core-selector>
@CustomElementProxy('core-selector')
class CoreSelector extends HtmlElement with DomProxyMixin, PolymerProxyMixin {
  CoreSelector.created() : super.created();
  factory CoreSelector() => new Element.tag('core-selector');

  /// Gets or sets the selected element.  Default to use the index
  /// of the item element.
  ///
  /// If you want a specific attribute value of the element to be
  /// used instead of index, set "valueattr" to that attribute name.
  ///
  /// Example:
  ///
  ///     <core-selector valueattr="label" selected="foo">
  ///       <div label="foo"></div>
  ///       <div label="bar"></div>
  ///       <div label="zot"></div>
  ///     </core-selector>
  ///
  /// In multi-selection this should be an array of values.
  ///
  /// Example:
  ///
  ///     <core-selector id="selector" valueattr="label" multi>
  ///       <div label="foo"></div>
  ///       <div label="bar"></div>
  ///       <div label="zot"></div>
  ///     </core-selector>
  ///
  ///     this.$.selector.selected = ['foo', 'zot'];
  get selected => jsElement[r'selected'];
  set selected(value) { jsElement[r'selected'] = (value is Map || value is Iterable) ? new JsObject.jsify(value) : value;}

  /// If true, multiple selections are allowed.
  bool get multi => jsElement[r'multi'];
  set multi(bool value) { jsElement[r'multi'] = value; }

  /// Specifies the attribute to be used for "selected" attribute.
  String get valueattr => jsElement[r'valueattr'];
  set valueattr(String value) { jsElement[r'valueattr'] = value; }

  /// Specifies the CSS class to be used to add to the selected element.
  String get selectedClass => jsElement[r'selectedClass'];
  set selectedClass(String value) { jsElement[r'selectedClass'] = value; }

  /// Specifies the property to be used to set on the selected element
  /// to indicate its active state.
  String get selectedProperty => jsElement[r'selectedProperty'];
  set selectedProperty(String value) { jsElement[r'selectedProperty'] = value; }

  /// Specifies the attribute to set on the selected element to indicate
  /// its active state.
  String get selectedAttribute => jsElement[r'selectedAttribute'];
  set selectedAttribute(String value) { jsElement[r'selectedAttribute'] = value; }

  /// Returns the currently selected element. In multi-selection this returns
  /// an array of selected elements.
  /// Note that you should not use this to set the selection. Instead use
  /// `selected`.
  get selectedItem => jsElement[r'selectedItem'];
  set selectedItem(value) { jsElement[r'selectedItem'] = (value is Map || value is Iterable) ? new JsObject.jsify(value) : value;}

  /// In single selection, this returns the model associated with the
  /// selected element.
  /// Note that you should not use this to set the selection. Instead use
  /// `selected`.
  get selectedModel => jsElement[r'selectedModel'];
  set selectedModel(value) { jsElement[r'selectedModel'] = (value is Map || value is Iterable) ? new JsObject.jsify(value) : value;}

  /// In single selection, this returns the selected index.
  /// Note that you should not use this to set the selection. Instead use
  /// `selected`.
  num get selectedIndex => jsElement[r'selectedIndex'];
  set selectedIndex(num value) { jsElement[r'selectedIndex'] = value; }

  /// Set this to true to disallow changing the selection via the
  /// `activateEvent`.
  bool get notap => jsElement[r'notap'];
  set notap(bool value) { jsElement[r'notap'] = value; }

  /// Nodes with local name that are in the list will not be included
  /// in the selection items.  In the following example, `items` returns four
  /// `core-item`'s and doesn't include `h3` and `hr`.
  ///
  ///     <core-selector excludedLocalNames="h3 hr">
  ///       <h3>Header</h3>
  ///       <core-item>Item1</core-item>
  ///       <core-item>Item2</core-item>
  ///       <hr>
  ///       <core-item>Item3</core-item>
  ///       <core-item>Item4</core-item>
  ///     </core-selector>
  String get excludedLocalNames => jsElement[r'excludedLocalNames'];
  set excludedLocalNames(String value) { jsElement[r'excludedLocalNames'] = value; }

  /// The target element that contains items.  If this is not set
  /// core-selector is the container.
  get target => jsElement[r'target'];
  set target(value) { jsElement[r'target'] = (value is Map || value is Iterable) ? new JsObject.jsify(value) : value;}

  /// This can be used to query nodes from the target node to be used for
  /// selection items.  Note this only works if `target` is set
  /// and is not `core-selector` itself.
  ///
  /// Example:
  ///
  ///     <core-selector target="{{$.myForm}}" itemsSelector="input[type=radio]"></core-selector>
  ///     <form id="myForm">
  ///       <label><input type="radio" name="color" value="red"> Red</label> <br>
  ///       <label><input type="radio" name="color" value="green"> Green</label> <br>
  ///       <label><input type="radio" name="color" value="blue"> Blue</label> <br>
  ///       <p>color = {{color}}</p>
  ///     </form>
  String get itemsSelector => jsElement[r'itemsSelector'];
  set itemsSelector(String value) { jsElement[r'itemsSelector'] = value; }

  /// The event that would be fired from the item element to indicate
  /// it is being selected.
  String get activateEvent => jsElement[r'activateEvent'];
  set activateEvent(String value) { jsElement[r'activateEvent'] = value; }

  /// Returns an array of all items.
  get items => jsElement[r'items'];

  get selection => jsElement[r'selection'];

  /// Selects the previous item. This should be used in single selection only.
  /// [wrapped]: if true and it is already at the first item,
  ///                      wrap to the end
  selectPrevious(bool wrapped) =>
      jsElement.callMethod('selectPrevious', [wrapped]);

  /// Selects the next item.  This should be used in single selection only.
  /// [wrapped]: if true and it is already at the last item,
  ///                      wrap to the front
  selectNext(bool wrapped) =>
      jsElement.callMethod('selectNext', [wrapped]);
}
