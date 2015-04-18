// DO NOT EDIT: auto-generated with `pub run custom_element_apigen:update`

/// Dart API for the polymer element `core_image`.
@HtmlImport('core_image_nodart.html')
library core_elements.core_image;

import 'dart:html';
import 'dart:js' show JsArray, JsObject;
import 'package:web_components/custom_element_proxy.dart';
import 'package:web_components/html_import_annotation.dart';
import 'package:custom_element_apigen/src/common.dart' show PolymerProxyMixin, DomProxyMixin;

/// `core-image` is an element for displaying an image that provides useful sizing and
/// preloading options not found on the standard `<img>` tag.
///
/// The `sizing` option allows the image to be either cropped (`cover`) or
/// letterboxed (`contain`) to fill a fixed user-size placed on the element.
///
/// The `preload` option prevents the browser from rendering the image until the
/// image is fully loaded.  In the interim, either the element's CSS `background-color`
/// can be be used as the placeholder, or the `placeholder` property can be
/// set to a URL (preferably a data-URI, for instant rendering) for an
/// placeholder image.
///
/// The `fade` option (only valid when `preload` is set) will cause the placeholder
/// image/color to be faded out once the image is rendered.
///
/// Examples:
///
///   Basically identical to &lt;img src="..."&gt; tag:
///
///     <core-image src="http://lorempixel.com/400/400"></core-image>
///
///   Will letterbox the image to fit:
///
///     <core-image style="width:400px; height:400px;" sizing="contain"
///       src="http://lorempixel.com/600/400"></core-image>
///
///   Will crop the image to fit:
///
///     <core-image style="width:400px; height:400px;" sizing="cover"
///       src="http://lorempixel.com/600/400"></core-image>
///
///   Will show light-gray background until the image loads:
///
///     <core-image style="width:400px; height:400px; background-color: lightgray;"
///       sizing="cover" preload src="http://lorempixel.com/600/400"></core-image>
///
///   Will show a base-64 encoded placeholder image until the image loads:
///
///     <core-image style="width:400px; height:400px;" placeholder="data:image/gif;base64,..."
///       sizing="cover" preload src="http://lorempixel.com/600/400"></core-image>
///
///   Will fade the light-gray background out once the image is loaded:
///
///     <core-image style="width:400px; height:400px; background-color: lightgray;"
///       sizing="cover" preload fade src="http://lorempixel.com/600/400"></core-image>
@CustomElementProxy('core-image')
class CoreImage extends HtmlElement with DomProxyMixin, PolymerProxyMixin {
  CoreImage.created() : super.created();
  factory CoreImage() => new Element.tag('core-image');

  /// The URL of an image.
  String get src => jsElement[r'src'];
  set src(String value) { jsElement[r'src'] = value; }

  /// When false, the image is prevented from loading and any placeholder is
  /// shown.  This may be useful when a binding to the src property is known to
  /// be invalid, to prevent 404 requests.
  bool get load => jsElement[r'load'];
  set load(bool value) { jsElement[r'load'] = value; }

  /// Sets a sizing option for the image.  Valid values are `contain` (full
  /// aspect ratio of the image is contained within the element and
  /// letterboxed) or `cover` (image is cropped in order to fully cover the
  /// bounds of the element), or `null` (default: image takes natural size).
  String get sizing => jsElement[r'sizing'];
  set sizing(String value) { jsElement[r'sizing'] = value; }

  /// When a sizing option is uzed (`cover` or `contain`), this determines
  /// how the image is aligned within the element bounds.
  String get position => jsElement[r'position'];
  set position(String value) { jsElement[r'position'] = value; }

  /// When `true`, any change to the `src` property will cause the `placeholder`
  /// image to be shown until the
  bool get preload => jsElement[r'preload'];
  set preload(bool value) { jsElement[r'preload'] = value; }

  /// This image will be used as a background/placeholder until the src image has
  /// loaded.  Use of a data-URI for placeholder is encouraged for instant rendering.
  String get placeholder => jsElement[r'placeholder'];
  set placeholder(String value) { jsElement[r'placeholder'] = value; }

  /// When `preload` is true, setting `fade` to true will cause the image to
  /// fade into place.
  bool get fade => jsElement[r'fade'];
  set fade(bool value) { jsElement[r'fade'] = value; }

  /// Read-only value that tracks the loading state of the image when the `preload`
  /// option is used.
  bool get loading => jsElement[r'loading'];
  set loading(bool value) { jsElement[r'loading'] = value; }

  /// Can be used to set the width of image (e.g. via binding); size may also be
  /// set via CSS.
  num get width => jsElement[r'width'];
  set width(num value) { jsElement[r'width'] = value; }

  /// Can be used to set the height of image (e.g. via binding); size may also be
  /// set via CSS.
  num get height => jsElement[r'height'];
  set height(num value) { jsElement[r'height'] = value; }
}
