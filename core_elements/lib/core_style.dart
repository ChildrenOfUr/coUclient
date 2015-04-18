// DO NOT EDIT: auto-generated with `pub run custom_element_apigen:update`

/// Dart API for the polymer element `core_style`.
@HtmlImport('core_style_nodart.html')
library core_elements.core_style;

import 'dart:html';
import 'dart:js' show JsArray, JsObject;
import 'package:web_components/custom_element_proxy.dart';
import 'package:web_components/html_import_annotation.dart';
import 'package:custom_element_apigen/src/common.dart' show PolymerProxyMixin, DomProxyMixin;

/// The `core-style` element helps manage styling inside other elements and can
/// be used to make themes. The `core-style` element can be either a producer
/// or consumer of styling. If it has its `id` property set, it's a producer.
/// Elements that are producers should include css styling as their text content.
/// If a `core-style` has its `ref` property set, it's a consumer. A `core-style`
/// typically sets its `ref` property to the value of the `id` property of the
/// `core-style` it wants to use. This allows a single producer to be used in
/// multiple places, for example, in many different elements.
///
/// It's common to place `core-style` producer elements inside HTMLImports.
/// Remote stylesheets should be included this way, the &#64;import css mechanism is
/// not currently supported.
///
/// Here's a basic example:
///
///     <polymer-element name="x-test" noscript>
///       <template>
///         <core-style ref="x-test"></core-style>
///         <content></content>
///       </template>
///     </polymer-element>
///
/// The `x-test` element above will be styled by any `core-style` elements that have
/// `id` set to `x-test`. These `core-style` producers are separate from the element
/// definition, allowing a user of the element to style it independent of the author's
/// styling. For example:
///
///     <core-style id="x-test">
///       :host {
///         backgound-color: steelblue;
///       }
///     </core-style>
///
/// The content of the `x-test` `core-style` producer gets included inside the
/// shadowRoot of the `x-test` element. If the content of the `x-test` producer
/// `core-style` changes, all consumers of it are automatically kept in sync. This
/// allows updating styling on the fly.
///
/// The `core-style` element also supports bindings, in which case the producer
/// `core-style` element is the model. Here's an example:
///
///     <core-style id="x-test">
///       :host {
///         background-color: {{myColor}};
///       }
///     </core-style>
///     <script>
///       document._currentScript.ownerDocument.getElementById('x-test').myColor = 'orange';
///     </script>
///
/// Finally, to facilitate sharing data between `core-style` elements, all
/// `core-style` elements have a `g` property which is set to the global
/// `CoreStyle.g`. Here's an example:
///
///     <core-style id="x-test">
///       :host {
///         background-color: {{g.myColor}};
///       }
///     </core-style>
///     <script>
///       CoreStyle.g.myColor = 'tomato';
///     </script>
///
/// Finally, one `core-style` can be nested inside another. The `core-style`
/// element has a `list` property which is a map of all the `core-style` producers.
/// A `core-style` producer's content is available via its `cssText` property.
/// Putting this together:
///
///     <core-style id="common">
///       :host {
///         font-family: sans-serif;
///       }
///     </core-style>
///
///     <core-style id="x-test">
///       {{list.common.cssText}}
///
///       :host {
///         background-color: {{g.myColor}};
///       }
///     </core-style>
@CustomElementProxy('core-style')
class CoreStyle extends HtmlElement with DomProxyMixin, PolymerProxyMixin {
  CoreStyle.created() : super.created();
  factory CoreStyle() => new Element.tag('core-style');

  /// The `id` property should be set if the `core-style` is a producer
  /// of styles. In this case, the `core-style` should have text content
  /// that is cssText.
  String get id => jsElement[r'id'];
  set id(String value) { jsElement[r'id'] = value; }

  /// The `ref` property should be set if the `core-style` element is a
  /// consumer of styles. Set it to the `id` of the desired `core-style`
  /// element.
  String get ref => jsElement[r'ref'];
  set ref(String value) { jsElement[r'ref'] = value; }

  /// The `list` is a map of all `core-style` producers stored by `id`. It
  /// should be considered readonly. It's useful for nesting one `core-style`
  /// inside another.
  get list => jsElement[r'list'];
  set list(value) { jsElement[r'list'] = (value is Map || value is Iterable) ? new JsObject.jsify(value) : value;}
}
