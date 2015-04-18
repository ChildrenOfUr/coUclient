// DO NOT EDIT: auto-generated with `pub run custom_element_apigen:update`

/// Dart API for the polymer element `core_iconset`.
@HtmlImport('core_iconset_nodart.html')
library core_elements.core_iconset;

import 'dart:html';
import 'dart:js' show JsArray, JsObject;
import 'package:web_components/custom_element_proxy.dart';
import 'package:web_components/html_import_annotation.dart';
import 'core_meta.dart';

/// The `core-iconset` element allows users to define their own icon sets.
/// The `src` property specifies the url of the icon image. Multiple icons may
/// be included in this image and they may be organized into rows.
/// The `icons` property is a space separated list of names corresponding to the
/// icons. The names must be ordered as the icons are ordered in the icon image.
/// Icons are expected to be square and are the size specified by the `iconSize`
/// property. The `width` property corresponds to the width of the icon image
/// and must be specified if icons are arranged into multiple rows in the image.
///
/// All `core-iconset` elements are available for use by other `core-iconset`
/// elements via a database keyed by id. Typically, an element author that wants
/// to support a set of custom icons uses a `core-iconset` to retrieve
/// and use another, user-defined iconset.
///
/// Example:
///
///     <core-iconset id="my-icons" src="my-icons.png" width="96" iconSize="24"
///         icons="location place starta stopb bus car train walk">
///     </core-iconset>
///
/// This will automatically register the icon set "my-icons" to the iconset
/// database.  To use these icons from within another element, make a
/// `core-iconset` element and call the `byId` method to retrieve a
/// given iconset. To apply a particular icon to an element, use the
/// `applyIcon` method. For example:
///
///     iconset.applyIcon(iconNode, 'car');
///
/// Themed icon sets are also supported. The `core-iconset` can contain child
/// `property` elements that specify a theme with an offsetX and offsetY of the
/// theme within the icon resource. For example.
///
///     <core-iconset id="my-icons" src="my-icons.png" width="96" iconSize="24"
///         icons="location place starta stopb bus car train walk">
///       <property theme="special" offsetX="256" offsetY="24"></property>
///     </core-iconset>
///
/// Then a themed icon can be applied like this:
///
///     iconset.applyIcon(iconNode, 'car', 'special');
@CustomElementProxy('core-iconset')
class CoreIconset extends CoreMeta {
  CoreIconset.created() : super.created();
  factory CoreIconset() => new Element.tag('core-iconset');

  /// The URL of the iconset image.
  String get src => jsElement[r'src'];
  set src(String value) { jsElement[r'src'] = value; }

  /// The width of the iconset image. This must only be specified if the
  /// icons are arranged into separate rows inside the image.
  num get width => jsElement[r'width'];
  set width(num value) { jsElement[r'width'] = value; }

  /// A space separated list of names corresponding to icons in the iconset
  /// image file. This list must be ordered the same as the icon images
  /// in the image file.
  String get icons => jsElement[r'icons'];
  set icons(String value) { jsElement[r'icons'] = value; }

  /// The size of an individual icon. Note that icons must be square.
  num get iconSize => jsElement[r'iconSize'];
  set iconSize(num value) { jsElement[r'iconSize'] = value; }

  /// The horizontal offset of the icon images in the inconset src image.
  /// This is typically used if the image resource contains additional images
  /// beside those intended for the iconset.
  num get offsetX => jsElement[r'offsetX'];
  set offsetX(num value) { jsElement[r'offsetX'] = value; }

  /// The vertical offset of the icon images in the inconset src image.
  /// This is typically used if the image resource contains additional images
  /// beside those intended for the iconset.
  num get offsetY => jsElement[r'offsetY'];
  set offsetY(num value) { jsElement[r'offsetY'] = value; }

  /// Returns an object containing `offsetX` and `offsetY` properties which
  /// specify the pixel locaion in the iconset's src file for the given
  /// `icon` and `theme`. It's uncommon to call this method. It is useful,
  /// for example, to manually position a css backgroundImage to the proper
  /// offset. It's more common to use the `applyIcon` method.
  ///
  /// Returns object specifying the offset of the given icon
  /// within the icon resource file; `offsetX` is the horizontal offset and
  /// `offsetY` is the vertical offset. Both values are in pixel units.
  /// [icon]: The name of the icon or the index of the
  ///     icon within in the icon image.
  /// [theme]: The name of the theme.
  getOffset(icon, String theme) =>
      jsElement.callMethod('getOffset', [icon, theme]);

  /// Applies an icon to the given element as a css background image. This
  /// method does not size the element, and it's often necessary to set
  /// the element's height and width so that the background image is visible.
  ///
  /// Returns icon element.
  /// [element]: The element to which the background is
  ///     applied.
  /// [icon]: The name or index of the icon to apply.
  /// [scale]: (optional, defaults to 1) A scaling factor 
  ///     with which the icon can be magnified.
  applyIcon(Element element, icon, [num scale]) =>
      jsElement.callMethod('applyIcon', [element, icon, scale]);
}
