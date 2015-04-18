# Core elements

This package wraps the Polymer project's core elements, providing the
following features:

 * Because the elements are bundled into a single pub package, you can add
   `core_elements` as a dependency in your pubspec. You don't need to
   install npm or bower.
 * Core elements that are either performance sensitive (like `core-list`) or
   use native objects that are difficult to use via dart:js (like `core-ajax`)
   have been ported to Dart.
 * The remaining core elements are wrapped with Dart proxy classes, making
   them easier to interact with from Dart apps.
   
You can find out more about core elements here:
http://www.polymer-project.org/docs/elements/core-elements.html


## Status

This is an early access version of the core elements. The elements are still
changing on both the JavaScript and Dart sides.


## Using elements

All elements live at the top level of the `lib/` folder.

Import into HTML:

    <link rel="import" href="packages/core_elements/core_input.html">

Import into Dart:

    import 'package:core_elements/core_input.dart';


## Examples

All examples are located in a separate repo,
https://github.com/dart-lang/polymer-core-and-paper-examples.
