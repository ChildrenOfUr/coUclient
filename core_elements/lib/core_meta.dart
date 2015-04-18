// DO NOT EDIT: auto-generated with `pub run custom_element_apigen:update`

/// Dart API for the polymer element `core_meta`.
@HtmlImport('core_meta_nodart.html')
library core_elements.core_meta;

import 'dart:html';
import 'dart:js' show JsArray, JsObject;
import 'package:web_components/custom_element_proxy.dart';
import 'package:web_components/html_import_annotation.dart';
import 'package:custom_element_apigen/src/common.dart' show PolymerProxyMixin, DomProxyMixin;

/// `core-meta` provides a method of constructing a self-organizing database.
/// It is useful to collate element meta-data for things like catalogs and for
/// designer.
///
/// Example, an element folder has a `metadata.html` file in it, that contains a
/// `core-meta`, something like this:
///
///     <core-meta id="my-element" label="My Element">
///       <property name="color" value="blue"></property>
///     </core-meta>
///
/// An application can import as many of these files as it wants, and then use
/// `core-meta` again to access the collected data.
///
///     <script>
///       var meta = document.createElement('core-meta');
///       console.log(meta.list); // dump a list of all meta-data elements that have been created
///     </script>
///
/// Use `byId(id)` to retrive a specific core-meta.
///
///     <script>
///       var meta = document.createElement('core-meta');
///       console.log(meta.byId('my-element'));
///     </script>
///
/// By default all meta-data are stored in a single databse.  If your meta-data
/// have different types and want them to be stored separately, use `type` to
/// differentiate them.
///
/// Example:
///
///     <core-meta id="x-foo" type="xElt"></core-meta>
///     <core-meta id="x-bar" type="xElt"></core-meta>
///     <core-meta id="y-bar" type="yElt"></core-meta>
///
///     <script>
///       var meta = document.createElement('core-meta');
///       meta.type = 'xElt';
///       console.log(meta.list);
///     </script>
@CustomElementProxy('core-meta')
class CoreMeta extends HtmlElement with DomProxyMixin, PolymerProxyMixin {
  CoreMeta.created() : super.created();
  factory CoreMeta() => new Element.tag('core-meta');

  get label => jsElement[r'label'];
  set label(value) { jsElement[r'label'] = (value is Map || value is Iterable) ? new JsObject.jsify(value) : value;}

  /// The type of meta-data.  All meta-data with the same type with be
  /// stored together.
  String get type => jsElement[r'type'];
  set type(String value) { jsElement[r'type'] = value; }

  /// Returns a list of all meta-data elements with the same type.
  JsArray get list => jsElement[r'list'];

  get metaArray => jsElement[r'metaArray'];

  get metaData => jsElement[r'metaData'];

  /// Retrieves meta-data by ID.
  /// [id]: The ID of the meta-data to be returned.
  byId(String id) =>
      jsElement.callMethod('byId', [id]);
}
