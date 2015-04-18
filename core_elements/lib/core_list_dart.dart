/*
 * Copyright (c) 2014 The Polymer Project Authors. All rights reserved.
 * This code may only be used under the BSD style license found at http://polymer.github.io/LICENSE.txt
 * The complete set of authors may be found at http://polymer.github.io/AUTHORS.txt
 * The complete set of contributors may be found at http://polymer.github.io/CONTRIBUTORS.txt
 * Code distributed by Google as part of the polymer project is also
 * subject to an additional IP rights grant found at http://polymer.github.io/PATENTS.txt
 */
@HtmlImport('core_list_dart_nodart.html')
library core_elements.core_list_dart;

import 'dart:async';
import 'dart:js' show JsObject;
import 'dart:js' as js;
import 'dart:html';
import 'dart:math' as math;
import 'package:core_elements/core_selection.dart';
import 'package:polymer/polymer.dart';
import 'package:template_binding/template_binding.dart';

final RegExp IOS_REGEX = new RegExp('/iP(?:hone|ad;(?: U;)? CPU) OS (\d+)/');
final Match IOS = IOS_REGEX.firstMatch(window.navigator.userAgent);
final bool IOS_TOUCH_SCROLLING = IOS != null && int.parse(IOS[1]) >= 8;

@CustomTag('core-list-dart')
class CoreList extends PolymerElement {
  /**
   * Fired when an item element is tapped.
   *
   * @event core-activate
   * @param {Object} detail
   * @param {Object} detail.item the item element
   */

  /**
   * An array of source data for the list to display.  Elements
   * from this array will be set to the `model` peroperty on each
   * template instance scope for binding.
   *
   * When `groups` is used, this array may either be flat, with
   * the group lengths specified in the `groups` array; otherwise
   * `data` may be specified as an array of arrays, such that the
   * each array in `data` specifies a group.  See examples above.
   *
   * @attribute data
   * @type array
   * @default null
   */
  @published ObservableList data;

  /**
   * An array of data conveying information about groupings of items
   * in the `data` array.  Elements from this array will be set to the
   * `groupModel` property of each template instance scope for binding.
   *
   * When `groups` is used, template children with the `divider` attribute
   * will be shown above each group.  Typically data from the `groupModel`
   * would be bound to dividers.
   *
   * If `data` is specified as a flat array, the `groups` array must
   * contain instances of CoreListGroup class, where
   * `length` determines the number of items from the `data` array
   * that should be grouped, and `data` specifies the user data that will
   * be assigned to the `groupModel` property on the template instance
   * scope.
   *
   * If `data` is specified as a nested array of arrays, group lengths
   * are derived from these arrays, so each object in `groups` need only
   * contain the user data to be assigned to `groupModel`.
   *
   * @attribute groups
   * @type array
   * @default null
   */
  @published ObservableList<CoreListGroup> groups;

  /**
   *
   * An optional element on which to listen for scroll events.
   *
   * @attribute scrollTarget
   * @type Element
   * @default core-list-dart
   */
  @published Element scrollTarget;

  /**
   * 
   * When true, tapping a row will select the item, placing its data model
   * in the set of selected items retrievable via the `selection` property.
   *
   * Note that tapping focusable elements within the list item will not
   * result in selection, since they are presumed to have their own action.
   *
   * @attribute selectionEnabled
   * @type {boolean}
   * @default true
   */
  @published bool selectionEnabled = true;

  /**
   *
   * Set to true to support multiple selection. Note, existing selection state
   * is maintained only when changing `multi` from `false` to `true`; it is
   * cleared when changing from `true` to `false`.
   *
   * @attribute multi
   * @type boolean
   * @default false
   */
  @published bool multi = false;

  /**
   * 
   * Data record (or array of records, if `multi: true`) corresponding to
   * the currently selected set of items.
   *
   * @attribute selection
   * @type {any}
   * @default null
   */
  @published var selection;

  /**
   *
   * When true, the list is rendered as a grid.  Grid items must be fixed
   * height and width, with the width of each item specified in the `width`
   * property.
   *
   * @attribute grid
   * @type boolean
   * @default false
   */
   @published bool grid = false;

  /**
   *
   * When `grid` is used, `width` determines the width of each grid item.
   * This property has no meaning when not in `grid` mode.
   *
   * @attribute width
   * @type number
   * @default null
   */
   @published int width;

  /**
   * The approximate height of a list item, in pixels. This is used only for determining
   * the number of physical elements to render based on the viewport size
   * of the list.  Items themselves may vary in height between each other
   * depending on their data model.  There is typically no need to adjust
   * this value unless the average size is much larger or smaller than the default.
   *
   * @attribute height
   * @type number
   * @default 200
   */
  @published int height = 200;

  /**
   * The amount of scrolling runway the list keeps rendered, as a factor of
   * the list viewport size.  There is typically no need to adjust this value
   * other than for performance tuning.  Larger value correspond to more
   * physical elements being rendered.
   *
   * @attribute runwayFactor
   * @type number
   * @default 4
   */
  @published int runwayFactor = 4;

  static const String CONTENT_ERROR = '\n\n'
'The content of a <core-list-dart> element should be a single template tag '
'which contains a single element (which can itself contain whatever content or '
'elements you wish). For example: '
'''\n\n
<core-list-dart data="{{data}}">
  <template>
    <div>
      // All your custom content/elements here.
    </div>
  </template>
</core-list-dart>
''';

  int _virtualStart = 0;
  int _virtualCount = 0;
  int _physicalStart = 0;
  int _physicalOffset = 0;
  int _physicalSize = 0;
  List<int> _physicalSizes = [];
  int _physicalAverage = 0;
  int _physicalAverageCount = 0;
  List<int> _itemSizes = [];
  List<int> _dividerSizes = [];
  List<int> _repositionedItems = [];
  int _aboveSize = 0;
  bool _nestedGroups = false;
  int _groupStart = 0;
  int _groupStartIndex = 0;
  StreamSubscription _resizeSubscription;
  _VoidFn syncScroller;
  bool adjustPositionAllowed;
  int _targetSize = 0;
  bool _grouped;
  int _rowFactor;
  double _rowMargin;
  List<StreamSubscription> _groupObservers;
  int _dir;
  bool _needItemInit = false;
  Future _raf;
  int _viewportSize;
  int _upperBound;
  int _lowerBound;

  Element _target;
  var _targetScrollSubscription;
  int _physicalCount;
  int _scrollTop = 0;
  bool _oldMulti = false;
  bool _oldSelectionEnabled = false;

  ObservableList<_ListModel> _physicalData;
  List<Element> _physicalItems;
  List<Element> _physicalDividers;

  Expando _selectedData;
  Expando<_PhysicalItemData> _physicalItemData = new Expando();

  Element template;

  CoreSelection get _selection => $['selection'];

  CoreList.created() : super.created();

  @override
  ready() {
    _oldMulti = multi;
    _oldSelectionEnabled = selectionEnabled;
  }

  @override
  attached() {
    template = this.querySelector('template');
    // Make sure they supplied a template in the content.
    if (template == null) {
      throw '\n\nIt looks like you are missing the <template> '
          'tag in your <core-list-dart> content. $CONTENT_ERROR';
    }
    if (templateBind(template).bindingDelegate == null) {
      templateBind(template).bindingDelegate = element.syntax;
    }

    _resizeSubscription = window.onResize.listen((_) => updateSize());
  }

  @override detached() {
    if (_resizeSubscription != null) {
      _resizeSubscription.cancel();
      _resizeSubscription = null;
    }
    if (_targetScrollSubscription != null) {
      _targetScrollSubscription.cancel();
      _targetScrollSubscription = null;
    }
  }

  /**
   * To be called by the user when the list is resized or shown
   * after being hidden.  Note, `core-list` calls this automatically
   * when the window is resized.
   *
   * @method updateSize
   */
  void updateSize() {
    if (_physicalCount == null) return;
    _resetIndex(_getFirstVisibleIndex());
    initializeData();
  }

  @ObserveProperty('multi selectionEnabled')
  resetSelection() {
    if ((_oldMulti != multi && !multi) ||
        (_oldSelectionEnabled != selectionEnabled && !selectionEnabled)) {
      _clearSelection();
      refresh();
    } else {
      selection = _getSelection();
    }
    _oldMulti = multi;
    _oldSelectionEnabled = selectionEnabled;
  }

  // Adjust virtual start index based on changes to backing data
  void _adjustVirtualIndex(List<ListChangeRecord> splices, [group]) {
    if (_targetSize == 0) return;
    var totalDelta = 0;
    for (var i = 0; i < splices.length; i++) {
      var s = splices[i];
      var idx = s.index;
      var gidx, gitem;
      if (group != null) {
        gidx = data.indexOf(group);
        idx += virtualIndexForGroup(gidx);
      }
      // We only need to care about changes happening above the current position
      if (idx >= _virtualStart) break;
      var delta = math.max(s.addedCount - s.removed.length,
          idx - _virtualStart);
      totalDelta += delta;
      _physicalStart += delta;
      _virtualStart += delta;
      if (_grouped) {
        if (group != null) {
          gitem = s.index;
        } else {
          var g = groupForVirtualIndex(s.index);
          gidx = g['group'];
          gitem = g['groupIndex'];
        }
        if (gidx == _groupStart && gitem < _groupStartIndex) {
          _groupStartIndex += delta;
        }
      }
    }
    // Adjust offset/scroll position based on total number of items changed
    if (_virtualStart < _physicalCount) {
      _resetIndex(_getFirstVisibleIndex());
    } else {
      totalDelta = math.max(
          (totalDelta / _rowFactor) * _physicalAverage,
          -_physicalOffset).round();
      _physicalOffset += totalDelta;
      _scrollTop =_target.scrollTop = _scrollTop + totalDelta;
    }
  }

  void _updateSelection(List<ListChangeRecord> splices) {
    for (var i = 0; i < splices.length; i++) {
      var s = splices[i];
      for (var j = 0; j < s.removed.length; j++) {
        var d = s.removed[j];
        _setItemSelected(_selection, _wrap(d), false);
      }
    }
  }

  void groupsChanged() {
    if ((groups != null) != _grouped) {
      initialize();
      var firstIdx = _getFirstVisibleIndex();
      _resetIndex((firstIdx != null) ? firstIdx : _virtualStart);
    }
  }

  // TODO(debug): not sure why we need to add this bogus handler. Without it
  // data modifications are not being handled in initialize if run in Dartium
  // & dirty-checking
  @ObserveProperty('data') updateData() {}

  // TODO(sorvell): it'd be nice to dispense with 'data' and just use
  // template repeat's model. However, we need tighter integration
  // with TemplateBinding for this.
  // Dart note: added data.length so we detect modifications in the list.
  @ObserveProperty('data grid width template scrollTarget')
  initialize([changes]) {
    if (template == null) return;

    // `changes is List<ListChangeRecord>` does not work in Dart. We assume here
    // that if the first item is a ListChangeRecord then the rest is too.
    var isListChangeRecords = false;
    if (changes is List && !changes.isEmpty && changes[0] is ListChangeRecord
        && !changes[0].object.isEmpty) {
      isListChangeRecords = true;
      if (!_nestedGroups) {
        _adjustVirtualIndex(changes);
      }
      _updateSelection(changes);
    } else {
      _clearSelection();
    }

    // Initialize scroll target
    var target = scrollTarget != null ? scrollTarget : this;
    if (_target != target) {
      initializeScrollTarget(target);
    }

    // Initialize data
    if (isListChangeRecords) {
      initializeData(changes);
    } else {
      initializeData();
    }
  }

  void initializeScrollTarget(target) {
    // Listen for scroll events
    if (_targetScrollSubscription != null) {
      _targetScrollSubscription.cancel();
      _targetScrollSubscription = null;
    }
    _target = target;
    _targetScrollSubscription = _target.on['scroll'].listen(scrollHandler);

    // Support for non-native scrollers (must implement abstract API):
    // int get scrollTop; set scrollTop(int); sync() {}
    if (target is CoreListScroller) {
      syncScroller = target.sync;
      // Adjusting scroll position on non-native scrollers is risky
      adjustPositionAllowed = false;
    } else if (target is HtmlElement) {
      syncScroller = () {};
      adjustPositionAllowed = true;
    } else {
      throw 'unsupported target, must be an HtmlElement or implement '
          'CoreListScroller';
    }

    // Only use -webkit-overflow-touch from iOS8+, where scroll events are fired
    if (IOS_TOUCH_SCROLLING) {
      _target.style.setProperty('-webkit-overflow-scrolling', 'touch');
      // Adjusting scrollTop during iOS momentum scrolling is "no bueno"
      adjustPositionAllowed = false;
    }
    // Force overflow as necessary
    _target.style.willChange = 'transform';
    if (_target.getComputedStyle().position == 'static') {
      _target.style.position = 'relative';
    }
    _target.style.boxSizing = 'border-box';
    style.overflowY = (target == this) ? 'auto' : null;
  }

  void updateGroupObservers(List<ListChangeRecord> splices) {
    // If we're going from grouped to non-grouped, remove all observers
    if (!_nestedGroups) {
      if (_groupObservers != null && _groupObservers.length > 0) {
        splices = [new ListChangeRecord(
            _groupObservers, 0, removed: _groupObservers, addedCount: 0)];
      } else {
        splices = null;
      }
    } else {
      // Otherwise, create observers for all groups, unless this is a group
      // splice
      splices = (splices != null) ? splices : [new ListChangeRecord(
          _groupObservers, 0, removed: [], addedCount: data.length)];
    }
    if (splices != null) {
      List<StreamSubscription> observers =
          (_groupObservers != null) ? _groupObservers : [];
      // Apply the splices to the observer array
      for (var i = 0; i < splices.length; i++) {
        var j;
        var s = splices[i];
        if (s.removed.length > 0) {
          for (j = s.index; j < s.removed.length && j < observers.length; j++) {
            observers[j].cancel();
          }
        }
        if (observers.length > s.index) {
          observers.removeRange(
              s.index, math.min(s.removed.length + s.index, observers.length));
        }
        var newSubscriptions = [];
        if (s.addedCount > 0) {
          for (j = s.index; j < s.addedCount; j++) {
            if (data[j] is ObservableList) {
              var o = (data[j] as ObservableList).listChanges.listen(
                  getGroupDataHandler(data[j]));
              newSubscriptions.add(o);
            }
          }
        }
        if (observers.length <= s.index) {
          observers.length = s.index;
        }
        observers.insertAll(s.index, newSubscriptions);
      }
      _groupObservers = observers;
    }
  }

  Function getGroupDataHandler(ObservableList group) =>
      (List<ListChangeRecord> splices) => groupDataChange(splices, group);

  void groupDataChange(List<ListChangeRecord> splices, ObservableList group) {
    _adjustVirtualIndex(splices, group);
    _updateSelection(splices);
    initializeData(null, true);
  }

  /// Gets the integer value of a css pixes string, ie: '10px' returns 10.
  int _cssPxToInt(String cssString) {
    try {
      return math.max(
          int.parse(cssString.substring(0, cssString.length - 2)), 0);
    } catch (e) {
      return 0;
    }
  }

  void initializeData(
      [List<ListChangeRecord> splices, bool groupUpdate = false]) {
    var i;

    // Calculate row-factor for grid layout
    if (grid) {
      if (width == null || width <= 0) {
        throw 'Grid requires the `width` property to be set and > 0';
      }
      var cs = _target.getComputedStyle();
      var padding =
          _cssPxToInt(cs.paddingLeft) + _cssPxToInt(cs.paddingRight);
      _rowFactor = math.max(
          ((_target.offsetWidth - padding) / width).floor(), 1);
      _rowMargin = (_target.offsetWidth - (_rowFactor * width) - padding) / 2;
    } else {
      _rowFactor = 1;
      _rowMargin = 0.0;
    }

    // Count virtual data size, depending on whether grouping is enabled
    if (data == null || data.isEmpty) {
      _virtualCount = 0;
      _grouped = false;
      _nestedGroups = false;
    } else if (groups != null) {
      _grouped = true;
      _nestedGroups = data[0] is List;
      if (_nestedGroups) {
        if (data[0] is! ObservableList) {
          throw 'When using nested lists for `data` groups, the nested lists '
              'must be of type ObservableList';
        }
        if (groups.length != data.length) {
          throw 'When using nested grouped data, data.length and groups.length '
              'must agree!';
        }
        _virtualCount = 0;
        for (i = 0; i < groups.length; i++) {
          if (data[i] == null) continue;
          _virtualCount += data[i].length;
        }
      } else {
        _virtualCount = data.length;
        var len = 0;
        for (i = 0; i < groups.length; i++) {
          len += groups[i].length;
        }
        if (len != data.length) {
          throw 'When using groups data, the sum of group[n].length\'s and '
              'data.length must agree!';
        }
      }
      var g = groupForVirtualIndex(_virtualStart);
      _groupStart = g['group'];
      _groupStartIndex = g['groupIndex'];
    } else {
      _grouped = false;
      _nestedGroups = false;
      _virtualCount = data.length;
    }

    // Update grouped array observers used when group data is nested
    if (!groupUpdate) {
      updateGroupObservers(splices);
    }

    // Add physical items up to a max based on data length, viewport size, and
    // extra item overhang
    var currentCount = _physicalCount == null ? 0 : _physicalCount;
    _physicalCount = math.min((_target.offsetHeight /
        ((_physicalAverage > 0) ? _physicalAverage : height)).ceil() *
        runwayFactor * _rowFactor, _virtualCount);
    _physicalCount = math.max(currentCount, _physicalCount);

    if (_physicalData == null) _physicalData = new ObservableList<_ListModel>();
    if (_physicalData.length < _physicalCount) {
      _physicalData.length = _physicalCount;
    }
    // TODO(jakemac): re-evaluate if this is needed or can just be = false like
    // it is on the js side.
    var needItemInit =
        _physicalItems == null || _physicalCount != _physicalItems.length;
    while (currentCount < _physicalCount) {
      // TODO(jakemac): how to make a new instance of templateInstance.model's class in dart?
      //  var model = templateInstance != null ? Object.create(templateInstance.model) : {};
      var model = new _ListModel();
      _physicalData[currentCount++] = model;
      needItemInit = true;
    }
    templateBind(template).model = _physicalData;
    template.attributes['repeat'] = '';
    _dir = 0;

    // If we've added new items, wait until the template renders then
    // initialize the new items before refreshing
    //
    // Note: `_needItemInit` is a property on the class, `needItemInit` is a
    // local variable. If `_needItemInit` is true then we have already scheduled
    // initialization.
    if (!_needItemInit) {
      if (needItemInit) {
        _needItemInit = true;
        resetMetrics();
        onMutation(this).then((_) => initializeItems());
      } else {
        refresh();
      }
    }
  }

  initializeItems() {
    var currentCount = _physicalItems != null ? _physicalItems.length : 0;
    if (_physicalItems == null) {
      _physicalItems = []..length = _physicalCount;
    }
    if (_physicalItems.length < _physicalCount) {
      _physicalItems.length = _physicalCount;
    }
    if (_physicalDividers == null) {
      _physicalDividers = []..length = _physicalCount;
    }
    if (_physicalDividers.length < _physicalCount) {
      _physicalDividers.length = _physicalCount;
    }

    var item = template.nextElementSibling;
    // TODO(jakemac): once https://github.com/Polymer/polymer/issues/910 is
    // fixed then we should do this check by examining the templates content
    // inside attached().
    //
    // Null item means they didn't have any elements in their <template>, only
    // text nodes (or a single binding most likely).
    if (item == null) {
      throw '\n\nIt looks like you are missing an element inside your '
          'template.$CONTENT_ERROR';
    }

    for (var i = 0; i < _physicalCount;) {
      if (item.getAttribute('divider') != null) {
        _physicalDividers[i] = item;
      } else {
        _physicalItems[i] = item;
        ++i;
      }
      item = item.nextElementSibling;
    }

    // TODO(jakemac): once https://github.com/Polymer/polymer/issues/910 is
    // fixed then we should do this check by examining the templates content
    // inside attached().
    //
    // Check for multiple top level elements in a <template>
    if (item != null) {
      throw '\n\n It looks like you have multiple top level elements inside '
          'your template. $CONTENT_ERROR';
    }

    refresh();
    _needItemInit = false;
  }

  bool _updateItemData(bool force, int physicalIndex, int virtualIndex,
      int groupIndex, int groupItemIndex) {
    var physicalItem = _physicalItems[physicalIndex];
    var physicalDatum = _physicalData[physicalIndex];
    var virtualDatum = dataForIndex(virtualIndex, groupIndex, groupItemIndex);
    var needsReposition;
    if (force || !identical(physicalDatum.model, virtualDatum)) {
      // Dart Note: expando for hanging off extra data onto physicalItem
      var physicalItemData = _physicalItemData[physicalItem];
      if (physicalItemData == null) {
        physicalItemData = new _PhysicalItemData();
        _physicalItemData[physicalItem] = physicalItemData;
      }
      // Set model, index, and selected fields
      physicalDatum.model = virtualDatum;
      physicalDatum.index = virtualIndex;
      physicalDatum.physicalIndex = physicalIndex;
      physicalDatum.selected = selectionEnabled && virtualDatum != null ?
          (_selectedData[virtualDatum] == true) : null;
      // Set group-related fields
      if (_grouped) {
        var groupModel = groups[groupIndex];
        if (groupModel != null) {
          physicalDatum.groupModel = groupModel;
        }
        physicalDatum.groupIndex = groupIndex;
        physicalDatum.groupItemIndex = groupItemIndex;
        physicalItemData.isDivider = data.isNotEmpty && (groupItemIndex == 0);
        physicalItemData.isRowStart = (groupItemIndex % _rowFactor) == 0;
      } else {
        physicalDatum.groupModel = null;
        physicalDatum.groupIndex = null;
        physicalDatum.groupItemIndex = null;
        physicalItemData.isDivider = false;
        physicalItemData.isRowStart = ((virtualIndex % _rowFactor) == 0);
      }
      // Hide physical items when not in use (no model assigned)
      physicalItem.hidden = virtualDatum == null;
      var divider = _physicalDividers[physicalIndex];
      if (divider != null && (divider.hidden == physicalItemData.isDivider)) {
        divider.hidden = !physicalItemData.isDivider;
      }
      needsReposition = !force;
    } else {
      needsReposition = false;
    }
    return needsReposition || force;
  }

  void scrollHandler([_]) {
    if (IOS_TOUCH_SCROLLING) {
      // iOS sends multiple scroll events per rAF
      // Align work to rAF to reduce overhead & artifacts
      if (_raf == null) {
        _raf = window.animationFrame.then((_) {
          _raf = null;
          refresh();
        });
      }
    } else {
      refresh();
    }
  }

  void resetMetrics() {
    _physicalAverage = 0;
    _physicalAverageCount = 0;
  }

  void updateMetrics([bool force = false]) {
    // Measure physical items & dividers
    var totalSize = 0;
    var count = 0;
   _physicalSizes.length = _itemSizes.length = _dividerSizes.length =
      _physicalCount;

    for (var i = 0; i < _physicalCount; i++) {
      var item = _physicalItems[i];
      var itemData = _physicalItemData[item];
      if (!item.hidden) {
        var size = _itemSizes[i] = item.offsetHeight;
        if (itemData.isDivider) {
          var divider = _physicalDividers[i];
          if (divider != null) {
            size += (_dividerSizes[i] = divider.offsetHeight);
          }
        }
        _physicalSizes[i] = size;
        if (itemData.isRowStart) {
          totalSize += size;
          count++;
        }
      }
    }
    _physicalSize = totalSize;

    // Measure other DOM
    _viewportSize = $['viewport'].offsetHeight;
    _targetSize = _target.offsetHeight;

    // Measure content in scroller before virtualized items
    if (!identical(_target, this)) {
      var el1 = previousElementSibling;
      _aboveSize = el1 != null ? el1.offsetTop + el1.offsetHeight : 0;
    } else {
      _aboveSize = 0;
    }

    // Calculate average height
    if (count > 0) {
      totalSize = (_physicalAverage * _physicalAverageCount) + totalSize;
      _physicalAverageCount += count;
      _physicalAverage = (totalSize / _physicalAverageCount).round();
    }
  }

  int getGroupLen([int group]) {
    if (group == null) group = _groupStart;
    if (_nestedGroups) {
      return data[group].length;
    } else {
      return groups[group].length;
    }
  }

  void changeStartIndex(int inc) {
    _virtualStart += inc;
    if (_grouped) {
      while (inc > 0) {
        var groupMax = getGroupLen() - _groupStartIndex - 1;
        if (inc > groupMax) {
          inc -= (groupMax + 1);
          _groupStart++;
          _groupStartIndex = 0;
        } else {
          _groupStartIndex += inc;
          inc = 0;
        }
      }
      while (inc < 0) {
        if (-inc > _groupStartIndex) {
          inc += _groupStartIndex;
          _groupStart--;
          _groupStartIndex = getGroupLen();
        } else {
          _groupStartIndex += inc;
          inc = getGroupLen();
        }
      }
    }
    // In grid mode, virtualIndex must always start on a row start!
    if (grid) {
      if (_grouped) {
        inc = _groupStartIndex % _rowFactor;
      } else {
        inc = _virtualStart % _rowFactor;
      }
      if (inc > 0) {
        changeStartIndex(-inc);
      }
    }
  }

  int getRowCount(int dir) {
    if (!grid) {
      return dir;
    } else if (!_grouped) {
      return dir * _rowFactor;
    } else {
      if (dir < 0) {
        if (_groupStartIndex > 0) {
          return -math.min(_rowFactor, _groupStartIndex);
        } else {
          var prevLen = getGroupLen(_groupStart - 1);
          var mod = prevLen % _rowFactor;
          return -math.min(_rowFactor, (mod == 0) ? _rowFactor : mod);
        }
      } else {
        return math.min(_rowFactor, getGroupLen() - _groupStartIndex);
      }
    }
  }

  int _virtualToPhysical(int virtualIndex) {
    var physicalIndex = (virtualIndex - _physicalStart) % _physicalCount;
    return physicalIndex < 0 ? _physicalCount + physicalIndex : physicalIndex;
  }

  Map groupForVirtualIndex(int virtual) {
    if (!_grouped) {
      return {};
    } else {
      var group;
      for (group = 0; group < groups.length; group++) {
        var groupLen = getGroupLen(group);
        if (groupLen > virtual) {
          break;
        } else {
          virtual -= groupLen;
        }
      }
      return {'group': group, 'groupIndex': virtual };
    }
  }

  int virtualIndexForGroup(int group, [int groupIndex]) {
    groupIndex =
        (groupIndex != null) ? math.min(groupIndex, getGroupLen(group)) : 0;
    group--;
    while (group >= 0) {
      groupIndex += getGroupLen(group--);
    }
    return groupIndex;
  }

  dataForIndex(int virtual, int group, int groupIndex) {
    if (data != null && virtual >= 0) {
      if (_nestedGroups && data.length > group) {
        if (virtual < _virtualCount) {
          return data[group][groupIndex];
        }
      } else if (data.length > virtual) {
        return data[virtual];
      }
    }
  }

  // Refresh the list at the current scroll position.
  refresh() {
    var i, deltaCount;

    // Determine scroll position & any scrollDelta that may have occurred
    var lastScrollTop = _scrollTop;
    _scrollTop = _target.scrollTop;
    var scrollDelta = _scrollTop - lastScrollTop;
    _dir = scrollDelta < 0 ? -1 : scrollDelta > 0 ? 1 : 0;

    // Adjust virtual items and positioning offset if scroll occurred
    if (scrollDelta.abs() > math.max(_physicalSize, _targetSize)) {
      // Random access to point in list: guess new index based on average size
      deltaCount = ((scrollDelta /
          ((_physicalAverage > 0) ? _physicalAverage : height)) * _rowFactor)
          .round();
      deltaCount = math.max(deltaCount, -_virtualStart);
      deltaCount = math.min(deltaCount, _virtualCount - _virtualStart - 1);
      _physicalOffset += math.max(scrollDelta, -_physicalOffset);
      changeStartIndex(deltaCount);
    } else {
      // Incremental movement: adjust index by flipping items
      var base = _aboveSize + _physicalOffset;
      var margin = 0.3 * math.max(_physicalSize - _targetSize, _physicalSize);
      _upperBound = (base + margin).round();
      _lowerBound = (base + _physicalSize - _targetSize - margin).round();
      var flipBound = _dir > 0 ? _upperBound : _lowerBound;
      if (((_dir > 0 && _scrollTop > flipBound) ||
           (_dir < 0 && _scrollTop < flipBound))) {
        var flipSize = (_scrollTop - flipBound).abs();
        for (i = 0; (i < _physicalCount) && (flipSize > 0) &&
            ((_dir < 0 && _virtualStart > 0) ||
             (_dir > 0 && _virtualStart < _virtualCount-_physicalCount)); i++) {
          var idx = _virtualToPhysical(
              _dir > 0 ? _virtualStart : _virtualStart + _physicalCount -1);
          var size = _physicalSizes[idx];
          flipSize -= size;
          var cnt = getRowCount(_dir);
          if (_dir > 0) {
            // When scrolling down, offset is adjusted based on previous item's
            // size
            _physicalOffset += size;
          }
          changeStartIndex(cnt);
          if (_dir < 0) {
            _repositionedItems.add(_virtualStart);
          }
        }
      }
    }

    // Assign data to items lazily if scrolling, otherwise force
    if (_updateItems(scrollDelta == 0)) {
      // Position items after bindings resolve.
      // Dart Note: Polymer has different behavior based on the availability of
      // Object Observers, but we always just use async().
      async((_) => _positionItems());
    }
  }

  bool _updateItems(force) {
    var i, virtualIndex, physicalIndex;
    var needsReposition = false;
    var groupIndex = _groupStart;
    var groupItemIndex = _groupStartIndex;
    for (i = 0; i < _physicalCount; ++i) {
      virtualIndex = _virtualStart + i;
      physicalIndex = _virtualToPhysical(virtualIndex);
      // Update physical item with new user data and list metadata
      needsReposition = _updateItemData(force, physicalIndex, virtualIndex,
          groupIndex, groupItemIndex) || needsReposition;
      // Increment
      groupItemIndex++;
      if (groups != null && groupIndex < groups.length - 1) {
        if (groupItemIndex >= getGroupLen(groupIndex)) {
          groupItemIndex = 0;
          groupIndex++;
        }
      }
    }
    return needsReposition;
  }

  void _positionItems() {
    var i, virtualIndex, physicalIndex, physicalItem;

    // Measure
    updateMetrics();

    // Pre-positioning tasks
    if (_dir < 0) {
      // When going up, remove offset after measuring size for
      // new data for item being moved from bottom to top
      while (_repositionedItems.length > 0) {
        virtualIndex = _repositionedItems.removeLast();
        physicalIndex = _virtualToPhysical(virtualIndex);
        _physicalOffset -= _physicalSizes[physicalIndex];
      }
      // Adjust scroll position to home into top when going up
      if (_scrollTop + _targetSize < _viewportSize) {
        _updateScrollPosition(_scrollTop);
      }
    }

    // Position items
    var divider, upperBound, lowerBound;
    var rowx = 0;
    var x = _rowMargin;
    var y = _physicalOffset;
    var lastHeight = 0;
    for (i = 0; i < _physicalCount; ++i) {
      // Calculate indices
      virtualIndex = _virtualStart + i;
      physicalIndex = _virtualToPhysical(virtualIndex);
      physicalItem = _physicalItems[physicalIndex];
      var physicalItemData = _physicalItemData[physicalItem];
      // Position divider
      if (physicalItemData.isDivider) {
        if (rowx != 0) {
          y += lastHeight;
          rowx = 0;
        }
        divider = _physicalDividers[physicalIndex];
        var dividerData = _physicalItemData[divider];
        if (dividerData == null) {
          dividerData = new _PhysicalItemData();
          _physicalItemData[divider] = dividerData;
        }
        x = _rowMargin;
        if (divider != null &&
            (dividerData.translateX != x || dividerData.translateY != y)) {
          divider.style.opacity = '1';
          if (grid) {
            divider.style.width = '${width * _rowFactor}px';
          }
          _setTransform(divider, 'translate3d(${x}px,${y}px,0)');
          dividerData.translateX = x.round();
          dividerData.translateY = y.round();
        }
        if (_dividerSizes.length > physicalIndex) {
          y += _dividerSizes[physicalIndex];
        }
      }
      // Position item
      if (physicalItemData.translateX != x ||
          physicalItemData.translateY != y) {
        physicalItem.style.opacity = '1';
        _setTransform(physicalItem, 'translate3d(${x}px,${y}px,0)');
        physicalItemData.translateX = x.round();
        physicalItemData.translateY = y.round();
      }
      // Increment offsets
      lastHeight = (_itemSizes.length > physicalIndex) ?
          _itemSizes[physicalIndex] : 0;
      if (grid) {
        rowx++;
        if (rowx >= _rowFactor) {
          rowx = 0;
          y += lastHeight;
        }
        x = _rowMargin + rowx * width;
      } else {
        y += lastHeight;
      }
    }

    if (_scrollTop >= 0) {
      _updateViewportHeight();
    }
  }

  void _updateViewportHeight() {
    var remaining = math.max(_virtualCount - _virtualStart - _physicalCount, 0);
    remaining = (remaining / _rowFactor).ceil();
    var vs = _physicalOffset + _physicalSize + remaining * _physicalAverage;
    if (_viewportSize != vs) {
      _viewportSize = vs;
      $['viewport'].style.height = '${_viewportSize}px';
      syncScroller();
    }
  }

  void _updateScrollPosition(int scrollTop) {
    var deltaHeight = _virtualStart == 0 ? _physicalOffset :
      math.min(scrollTop + _physicalOffset, 0);
    if (deltaHeight != 0) {
      if (adjustPositionAllowed) {
        _scrollTop = _target.scrollTop = scrollTop - deltaHeight;
      }
      _physicalOffset -= deltaHeight;
    }
  }

  // list selection
  tapHandler(Event e) {
    var n = e.target;
    var p = e.path;
    if (!selectionEnabled || identical(n, this)) return;
    window.requestAnimationFrame((_) {
      // Gambit: only select the item if the tap wasn't on a focusable child
      // of the list (since anything with its own action should be focusable
      // and not result in result in list selection).  To check this, we
      // asynchronously check that shadowRoot.activeElement is null, which 
      // means the tapped item wasn't focusable. On polyfill where
      // activeElement doesn't follow the data-hinding part of the spec, we
      // can check that document.activeElement is the list itself, which will
      // catch focus in lieu of the tapped item being focusable, as we make
      // the list focusable (tabindex="-1") for this purpose.  Note we also
      // allow the list items themselves to be focusable if desired, so those
      // are excluded as well.
      var active = (js.context['ShadowDOMPolyfill'] != null)
          ? js.context['wrap'].apply([document.activeElement])
          : shadowRoot.activeElement;
      if (active != null && active != this && active.parentNode != this
          && document.activeElement != document.body) {
        return;
      }
      // Unfortunately, Safari does not focus certain form controls via mouse,
      // so we also blacklist input, button, & select
      // (https://bugs.webkit.org/show_bug.cgi?id=118043)
      if ((p[0].localName == 'input') || 
          (p[0].localName == 'button') || 
          (p[0].localName == 'select')) {
        return;
      }
      var instance = nodeBind(n).templateInstance;
      _ListModel model = instance != null ? instance.model.model : null;
      if (model != null) {
        var theData = dataForIndex(
            model.index, model.groupIndex, model.groupItemIndex);
        var item = _physicalItems[model.physicalIndex];
        if (!multi && identical(theData, selection)) {
          _invokeSelect(null);
        } else {
          _invokeSelect(theData);
        }
        asyncFire('core-activate',
            detail: new CoreActivateEvent(data: theData, item: item));
      }
    });
  }

  // Dart note: Dartium creates a new proxy every time a Dart object is sent via
  // jsinterop, unless the object is previsously jsified. This extra logic here
  // is used to ensure that core-selection works correctly in `multi` mode
  // (tapping an element twice should deselect it).
  _invokeSelect(item) {
    if (item != null) item = _wrap(item);
    _selection.select(item);
  }

  _getSelection() {
    var s = _selection.getSelection();
    if (!_inDartium || s == null) return s;
    if (s is List) return s.map(_unwrap).toList();
    return _unwrap(s);
  }

  static final _inDartium = window.navigator.dartEnabled;

  Expando dartObjectProxy = new Expando();

  JsObject _wrap(item) {
    if (!_inDartium) return item;
    var o = dartObjectProxy[item];
    if (o == null) {
      o = new JsObject.jsify({'original': item});
      dartObjectProxy[item] = o;
    }
    return o;
  }

  _unwrap(item) => _inDartium ? item['original'] : item;

  void selectedHandler(Event e) {
    selection = _getSelection();
    // TODO(sigmund): remove this use of JsInterop when dartbug.com/20648 is
    // fixed
    var detail = new JsObject.fromBrowserObject(e)['detail'];
    var item = _unwrap(detail['item']);
    var id = indexesForData(item);
    // TODO(sorvell): we should be relying on selection to store the
    // selected data but we want to optimize for lookup.
    _selectedData[item] = detail['isSelected'];

    var physical = id['physical'];
    if (physical != null && physical >= 0) {
      refresh();
    }
  }

  /**
   * Select the list item at the given index.
   *
   * @method selectItem
   * @param {number} index
   */
  void selectItem(int index) {
    if (!selectionEnabled) return;
    var item = data[index];
    if (item != null) {
      _invokeSelect(item);
    }
  }

  /**
   * Set the selected state of the list item at the given index.
   *
   * @method setItemSelected
   * @param {number} index
   * @param {boolean} isSelected
   */
  void setItemSelected(int index, bool isSelected) {
    var item = data[index];
    if (item != null) {
      _setItemSelected(_selection, _wrap(item), isSelected);
    }
  }

  Map indexesForData(dataItem) {
    var virtual = -1;
    var groupsLen = 0;
    if (_nestedGroups) {
      for (var i = 0; i < groups.length; i++) {
        virtual = data[i].indexOf(dataItem);
        if (virtual < 0) {
          groupsLen += data[i].length;
        } else {
          virtual += groupsLen;
          break;
        }
      }
    } else {
      virtual = data.indexOf(dataItem);
    }

    var physical = virtualToPhysicalIndex(virtual);
    return { 'virtual': virtual, 'physical': physical };
  }

  virtualToPhysicalIndex(index) {
    for (var i=0, l=_physicalData.length; i<l; i++) {
      if (_physicalData[i].index == index) {
        return i;
      }
    }
    return -1;
  }

  /**
   * Clears the current selection state of the list.
   *
   * @method clearSelection
   */
  clearSelection() {
    _clearSelection();
    refresh();
  }

  _clearSelection() {
    _selectedData = new Expando();
    _selection.jsElement.callMethod('clear');
    selection = _getSelection();
  }

  int _getFirstVisibleIndex() {
    for (var i = 0; i < _physicalCount; i++) {
      var virtualIndex = _virtualStart + i;
      var physicalIndex = _virtualToPhysical(virtualIndex);
      var item = _physicalItems[physicalIndex];
      var itemData = _physicalItemData[item];
      if (itemData.translateY != null && itemData.translateY >= _scrollTop) {
        return virtualIndex;
      }
    }
    return null;
  }

  _resetIndex(int index) {
    index = (index == null) ? 0 : index;
    index = math.min(index, _virtualCount-1);
    index = math.max(index, 0);
    changeStartIndex(index - _virtualStart);
    _scrollTop = _target.scrollTop =
        ((index / _rowFactor) * _physicalAverage).floor();
    _physicalOffset = _scrollTop;
    _dir = 0;
  }

  /**
   * Scroll to an item.
   *
   * Note, when grouping is used, the index is based on the
   * total flattened number of items.  For scrolling to an item
   * within a group, use the `scrollToGroupItem` API.
   *
   * @method scrollToItem
   * @param {number} index
   */
  void scrollToItem(index) {
    scrollToGroupItem(null, index);
  }

  /**
   * Scroll to a group.
   *
   * @method scrollToGroup
   * @param {number} group
   */
  void scrollToGroup(int group) {
    scrollToGroupItem(group, 0);
  }

  /**
   * Scroll to an item within a group.
   *
   * @method scrollToGroupItem
   * @param {number} group
   * @param {number} index
   */
  scrollToGroupItem(int group, int index) {
    if (group != null) {
      index = virtualIndexForGroup(group, index);
    }
    _resetIndex(index);
    refresh();
  }
}

/// The [CustomEvent.detail] of the [CoreList] `core-activate` event.
class CoreActivateEvent {
  Element item;
  var data;

  CoreActivateEvent({this.data, this.item});
}

/// Model used for groups if supplied.
class CoreListGroup extends Observable {
  @observable int length;
  @observable var data;
  CoreListGroup({this.length, this.data});
}

typedef void _VoidFn();
/// Interface for custom scrollers.
abstract class CoreListScroller {
  int get scrollTop;
  set scrollTop(int value);
  void sync() {}
}

/// Model used for the template of each item in the list.
class _ListModel extends Observable {
  @observable int physicalIndex;
  @observable int index;
  @observable bool selected;
  @observable var model;
  @observable CoreListGroup groupModel;
  @observable int groupIndex;
  @observable int groupItemIndex;
}

class _PhysicalItemData {
  bool isDivider;
  bool isRowStart;
  int translateX;
  int translateY;
  _PhysicalItemData({this.isDivider, this.isRowStart, this.translateX,
      this.translateY});
}

// TODO: this should be on the CoreSelection type.
_setItemSelected(CoreSelection node, x, y) =>
    node.jsElement.callMethod('setItemSelected', [x, y]);

void _setTransform(Element element, String value) {
  element.style.setProperty('-webkit-transform', value);
  element.style.transform = value;
}
