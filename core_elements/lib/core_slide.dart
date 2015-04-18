// DO NOT EDIT: auto-generated with `pub run custom_element_apigen:update`

/// Dart API for the polymer element `core_slide`.
@HtmlImport('core_slide_nodart.html')
library core_elements.core_slide;

import 'dart:html';
import 'dart:js' show JsArray, JsObject;
import 'package:web_components/custom_element_proxy.dart';
import 'package:web_components/html_import_annotation.dart';
import 'package:custom_element_apigen/src/common.dart' show PolymerProxyMixin, DomProxyMixin;


@CustomElementProxy('core-slide')
class CoreSlide extends HtmlElement with DomProxyMixin, PolymerProxyMixin {
  CoreSlide.created() : super.created();
  factory CoreSlide() => new Element.tag('core-slide');

  get open => jsElement[r'open'];
  set open(value) { jsElement[r'open'] = (value is Map || value is Iterable) ? new JsObject.jsify(value) : value;}

  get closed => jsElement[r'closed'];
  set closed(value) { jsElement[r'closed'] = (value is Map || value is Iterable) ? new JsObject.jsify(value) : value;}

  get vertical => jsElement[r'vertical'];
  set vertical(value) { jsElement[r'vertical'] = (value is Map || value is Iterable) ? new JsObject.jsify(value) : value;}

  get target => jsElement[r'target'];
  set target(value) { jsElement[r'target'] = (value is Map || value is Iterable) ? new JsObject.jsify(value) : value;}

  get targetId => jsElement[r'targetId'];
  set targetId(value) { jsElement[r'targetId'] = (value is Map || value is Iterable) ? new JsObject.jsify(value) : value;}
}
