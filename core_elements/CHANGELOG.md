## version 0.7.0
  * Update to match JS version 0.5.5.
    * **Breaking Change** `core-icons` has been rebased on the opensource set
      from https://github.com/google/material-design-icons.
      * The "post-" icons in the "social" set have been removed.
      * A few other icons from other sets have been removed.
      * The `png-icons` set has been removed.
    * `core-list-dart` does not yet have the `resizable` mixin like it does on
      the js side, [205](https://github.com/dart-lang/core-elements/issues/205).

## version 0.6.1+2
  * Update constraint on `web_components`.

## version 0.6.1+1
  * Add back `waitForMutation` param to `clearLower` and `clearUpper` for
    `core-scroll-threshold`.

## version 0.6.1
  * Increase `polymer` and `custom_element_apigen` lower bounds. Now takes
    advantage of `@HtmlImport` so manual html imports are no longer required to
    use the elements, just a dart import will work.
  * Added support for the `roboto` font and all the `core-animated-pages`
    transitions outside of the src folder. Also added a dart file for each of
    these which just includes an @HtmlImport.

## version 0.6.0+5
  * Increase quiver upper bound to <0.22.0.

## version 0.6.0+4
  * Increase quiver upper bound
    [185](https://github.com/dart-lang/core-elements/issues/185)

## version 0.6.0+3
  * Fix calling `updateSize` in `core-list-dart` with null data
    [182](https://github.com/dart-lang/core-elements/issues/182)

## version 0.6.0+2
  * Fix bug in `core-list-dart` where clicking a selected item would cause a
    runtime error [177](https://github.com/dart-lang/core-elements/issues/177).

## version 0.6.0+1
  * Fix bug in `core-ajax` with setting an indeterminate progress when in a
    browser that doesn't support progress events. Also the `url` attribute now
    defaults to null instead of an empty string.

## version 0.6.0
  * The `offset` property of the `core-animation` element is now called
    `animationOffset` so that it won't conflict with the `offset` property in
    its base class, `HtmlElement`.
  * Moved examples to central repo and updated readme
    https://github.com/dart-lang/polymer-core-and-paper-examples. 

## version 0.5.0+2
  * `core-list-dart` no longer crashes if the window is resized before the list
    data is initialized.

## version 0.5.0+1
  * Added some methods/properties from the polymer base class.
  * Added mixin support so CoreFocusable works as intended.
  * Fixed warning in `core-list-dart`.

## version 0.5.0
  * Update to match JS version 0.5.1.
    * **New** `core-image` is a new element which is a fancy version of the
      standard `img` tag.
    * **New** `core-label` is a new element which allows you to provide rich
      content as a label, as opposed to just text like the regular `label` tag.
    * **New** `core-scroll-threshold` is a new element which fires events based
      on scroll positions for target elements.
    * **Major Update** `core-list-dart` has received a major update. It now
      supports groups of items, grid layouts, and variable height items.
    * **Removed** `core-dropdown-overlay` has been removed.
    * **Breaking Change** `core-input` no longer supports the `multiline`
      attribute. It also now extends the `input` element directly, so it should
      be created using the `is` keyword: `<input is="core-input" />`.
    * **Breaking Change** `core-dropdown-menu` now requires that you nest a
      `core-dropdown` or some other overlay and a `core-selector` or other
      selector element as children.

## version 0.4.0+6
  * Update core-list-dart to have runtime checks for valid templates,
    [142](https://github.com/dart-lang/core-elements/issues/142).

## version 0.4.0+5
  * Cherry pick
    [core-focusable#3](https://github.com/Polymer/core-focusable/pull/3/files)
    which removes invalid comment tokens from a .js file.

## version 0.4.0+4
  * Cherry pick [33](https://github.com/Polymer/core-overlay/pull/33) to fix
    repeated quick showing and hiding of core overlays.

## version 0.4.0+3
  * Fix `core-list-dart` for the case where it is initialized with an empty
    array [137](https://github.com/dart-lang/core-elements/issues/137).

## version 0.4.0+2
  * Optimize `core-list-dart` for cases where the original list is cleared out
    entirely but not replaced by a new list (such as calling `.clear()` or
    setting `.length = 0`).

## version 0.4.0+1
  * Fixes for `core-list-dart`, coming from
    [130](https://github.com/dart-lang/core-elements/issues/130). Adding and
    removing items from small lists is fixed.

## version 0.4.0
  * Updated core elements to match JavaScript version 0.4.2
    * **Important breaking change**: core_list_dart behaves differently. You no
      longer need special properties on the model of the list item. The template
      will be bound to a wrapper model object that contains the index, whether
      the item is selected, and the model you provided. See dartdoc for details.
  * Cherry-picked newer version of core-tooltip/core-focusable to avoid adding a
    dependency to paper elements.
  * removed unnecessary files (README from the core element repos)

## version 0.3.2
  * Updated to use polymer 0.15.1 (Dart interop support is loaded automatically
    now.)

## version 0.3.1+1

  * Fix `core-list-dart` division by zero error when list is empty
    [124](https://github.com/dart-lang/core-elements/issues/124).

## version 0.3.1

  * Update `core_elements_config.yaml` with the new `deletion_patterns` option.
    This deletes a lot of cruft code from `bower update`.

## version 0.3.0+1

  * Fix import in `core_transition_pages`
    [118](https://github.com/dart-lang/core-elements/issues/118).

## version 0.3.0

  * Update elements to the 0.4.1 js versions.
    * **Breaking Change** `core-dropdown` has been renamed to
      `core-dropdown-menu`, `core-popup-menu` has been renamed to
      `core-dropdown`, and `core-popup-overlay` has been renamed to
      `core-dropdown-overlay`.
    * **New** `core-a11y-keys` element, which helps when dealing with key
      events.

## version 0.2.2+1

  * Upgrade `custom_element_apigen` to a real dependency as its required in the
  wrappers.
  
## version 0.2.2

  * Update all elements so they can be built from code using a normal factory
    constructor, such as `new CoreInput()`. It is still necessary however to
    include the html import for each element you wish to create this way.

## version 0.2.1+2

  * Fix for [107](https://github.com/dart-lang/core-elements/issues/107).
    The `core-ajax-dart` element no longer throws exception in checked mode, and
    the `content-type` header will have the proper default.

## version 0.2.1+1

  * Update `core-input` element to
    [88cbe6f](https://github.com/Polymer/core-input/commit/88cbe6f). This
    removes the need to use js interop for many methods that are forwarded to
    the underlying input element.

## version 0.2.1

  * Update all elements to the 0.4.0 js versions.
    * **New** Added new element core_popup_menu.
    * Fix core_drag_drop example.
  * Upgrade polymer dependency to >= 0.14.0.
    * Removed platform.js from all tests and examples.
  * Upgrade dependency on web_components to >=0.7.0.

## version 0.2.0+1

Upgrade polymer dependency to >=0.13.0

## version 0.2.0

Updated all elements to the 0.3.5 js versions.

  * **New** Added core-dropdown element, which acts like a <select> tag.
  * **New** Ported examples/demo.html which provides a central page to run all
    the other demos.
  * **Breaking Change** All icons that previously lived under 
    'packages/core_elements/core_icons/iconsets/' now live directly under
    'packages/core_elements/'.
  * Workaround in core-list-dart for [bug
20648](https://code.google.com/p/dart/issues/detail?id=20648)
  * Expanded polymer version constraint to <0.14.0.

## version 0.1.1+2

Fix for https://dartbug.com/20265, core-ajax-dart no longer throws an exception
when handling errors.

## version 0.1.1+1

Fix for https://github.com/dart-lang/core-elements/issues/84, core-ajax-dart no
longer fails if no params attribute is supplied.

## version 0.1.1

Fix for https://github.com/dart-lang/core-elements/issues/39, added missing
togglePanel method to core-drawer-panel.

## version 0.1.0+1

Updated all elements to the 0.3.4 js version.

## version 0.0.4

New generated wrappers for core-elements. This completely replaces and is
incompatible with earlier version of the package.

## version 0.0.3 and earlier

This was an attempt to port the core-elements to Dart. This version of the
package is deprecated.
