// DO NOT EDIT: auto-generated with `pub run custom_element_apigen:update`

/// Dart API for the polymer element `core_shared_lib`.
@HtmlImport('core_shared_lib_nodart.html')
library core_elements.core_shared_lib;

import 'dart:html';
import 'dart:js' show JsArray, JsObject;
import 'package:web_components/custom_element_proxy.dart';
import 'package:web_components/html_import_annotation.dart';
import 'package:custom_element_apigen/src/common.dart' show PolymerProxyMixin, DomProxyMixin;

/// Supports sharing a JSONP-based JavaScript library.
///
///     <core-shared-lib on-core-shared-lib-load="{{load}}" url="https://apis.google.com/js/plusone.js?onload=%%callback%%">
///
/// Multiple components can request a library using a `core-shared-lib` component and only one copy of that library will
/// loaded from the network.
///
/// Currently, the library must support JSONP to work as a shared-lib.
///
/// Some libraries require a specific global function be defined. If this is the case, specify the `callbackName` property.
///
/// Where possible, you should use an HTML Import to load library dependencies. Rather than using this element,
/// create an import (`<link rel="import" href="lib.html">`) that wraps loading the .js file:
///
/// lib.html:
///
///     <script src="lib.js"></script>
@CustomElementProxy('core-shared-lib')
class CoreSharedLib extends HtmlElement with DomProxyMixin, PolymerProxyMixin {
  CoreSharedLib.created() : super.created();
  factory CoreSharedLib() => new Element.tag('core-shared-lib');

  get url => jsElement[r'url'];
  set url(value) { jsElement[r'url'] = (value is Map || value is Iterable) ? new JsObject.jsify(value) : value;}

  get notifyEvent => jsElement[r'notifyEvent'];
  set notifyEvent(value) { jsElement[r'notifyEvent'] = (value is Map || value is Iterable) ? new JsObject.jsify(value) : value;}

  get callbackName => jsElement[r'callbackName'];
  set callbackName(value) { jsElement[r'callbackName'] = (value is Map || value is Iterable) ? new JsObject.jsify(value) : value;}
}
