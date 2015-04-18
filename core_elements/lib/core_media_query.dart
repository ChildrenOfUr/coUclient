// DO NOT EDIT: auto-generated with `pub run custom_element_apigen:update`

/// Dart API for the polymer element `core_media_query`.
@HtmlImport('core_media_query_nodart.html')
library core_elements.core_media_query;

import 'dart:html';
import 'dart:js' show JsArray, JsObject;
import 'package:web_components/custom_element_proxy.dart';
import 'package:web_components/html_import_annotation.dart';
import 'package:custom_element_apigen/src/common.dart' show PolymerProxyMixin, DomProxyMixin;

/// core-media-query can be used to data bind to a CSS media query.
/// The "query" property is a bare CSS media query.
/// The "queryMatches" property will be a boolean representing if the page matches that media query.
///
/// core-media-query uses media query listeners to dynamically update the "queryMatches" property.
/// A "core-media-change" event also fires when queryMatches changes.
///
/// Example:
///
///      <core-media-query query="max-width: 640px" queryMatches="{{phoneScreen}}"></core-media-query>
///
///
///
/// Fired when the media query state changes
@CustomElementProxy('core-media-query')
class CoreMediaQuery extends HtmlElement with DomProxyMixin, PolymerProxyMixin {
  CoreMediaQuery.created() : super.created();
  factory CoreMediaQuery() => new Element.tag('core-media-query');

  /// The CSS media query to evaulate
  String get mediaQuery => jsElement[r'query'];
  set mediaQuery(String value) { jsElement[r'query'] = value; }

  /// The Boolean return value of the media query
  bool get queryMatches => jsElement[r'queryMatches'];
  set queryMatches(bool value) { jsElement[r'queryMatches'] = value; }
}
