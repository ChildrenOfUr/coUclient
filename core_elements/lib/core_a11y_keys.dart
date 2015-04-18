// DO NOT EDIT: auto-generated with `pub run custom_element_apigen:update`

/// Dart API for the polymer element `core_a11y_keys`.
@HtmlImport('core_a11y_keys_nodart.html')
library core_elements.core_a11y_keys;

import 'dart:html';
import 'dart:js' show JsArray, JsObject;
import 'package:web_components/custom_element_proxy.dart';
import 'package:web_components/html_import_annotation.dart';
import 'package:custom_element_apigen/src/common.dart' show PolymerProxyMixin, DomProxyMixin;

/// `core-a11y-keys` provides a normalized interface for processing keyboard commands that pertain to [WAI-ARIA best
/// practices](http://www.w3.org/TR/wai-aria-practices/#kbd_general_binding). The element takes care of browser differences
/// with respect to Keyboard events and uses an expressive syntax to filter key presses.
///
/// Use the `keys` attribute to express what combination of keys will trigger the event to fire.
///
/// Use the `target` attribute to set up event handlers on a specific node.
/// The `keys-pressed` event will fire when one of the key combinations set with the `keys` attribute is pressed.
///
/// Example:
///
/// This element will call `arrowHandler` on all arrow keys:
///
///     <core-a11y-keys target="{{}}" keys="up down left right" on-keys-pressed="{{arrowHandler}}"></core-a11y-keys>
///
/// Keys Syntax:
///
/// The `keys` attribute can accepts a space seprated, `+` concatenated set of modifier keys and some common keyboard keys.
///
/// The common keys are `a-z`, `0-9` (top row and number pad), `*` (shift 8 and number pad), `F1-F12`, `Page Up`, `Page
/// Down`, `Left Arrow`, `Right Arrow`, `Down Arrow`, `Up Arrow`, `Home`, `End`, `Escape`, `Space`, `Tab`, and `Enter` keys.
///
/// The modifier keys are `Shift`, `Control`, and `Alt`.
///
/// All keys are expected to be lowercase and shortened:
/// `Left Arrow` is `left`, `Page Down` is `pagedown`, `Control` is `ctrl`, `F1` is `f1`, `Escape` is `esc` etc.
///
/// Keys Syntax Example:
///
/// Given the `keys` attribute value "ctrl+shift+f7 up pagedown esc space alt+m", the `<core-a11y-keys>` element will send
/// the `keys-pressed` event if any of the follow key combos are pressed: Control and Shift and F7 keys, Up Arrow key, Page
/// Down key, Escape key, Space key, Alt and M key.
///
/// Slider Example:
///
/// The following is an example of the set of keys that fulfil the WAI-ARIA "slider" role [best
/// practices](http://www.w3.org/TR/wai-aria-practices/#slider):
///
///     <core-a11y-keys target="{{}}" keys="left pagedown down" on-keys-pressed="{{decrement}}"></core-a11y-keys>
///     <core-a11y-keys target="{{}}" keys="right pageup up" on-keys-pressed="{{increment}}"></core-a11y-keys>
///     <core-a11y-keys target="{{}}" keys="home" on-keys-pressed="{{setMin}}"></core-a11y-keys>
///     <core-a11y-keys target="{{}}" keys="end" on-keys-pressed="{{setMax}}"></core-a11y-keys>
///
/// The `increment` function will move the slider a set amount toward the maximum value.
/// The `decrement` function will move the slider a set amount toward the minimum value.
/// The `setMin` function will move the slider to the minimum value.
/// The `setMax` function will move the slider to the maximum value.
///
/// Keys Syntax Grammar:
///
/// [EBNF](http://en.wikipedia.org/wiki/Extended_Backus%E2%80%93Naur_Form) Grammar of the `keys` attribute.
///
///     modifier = "shift" | "ctrl" | "alt";
///     ascii = ? /[a-z0-9]/ ? ;
///     fnkey = ? f1 through f12 ? ;
///     arrow = "up" | "down" | "left" | "right" ;
///     key = "tab" | "esc" | "space" | "*" | "pageup" | "pagedown" | "home" | "end" | arrow | ascii | fnkey ;
///     keycombo = { modifier, "+" }, key ;
///     keys = keycombo, { " ", keycombo } ;
@CustomElementProxy('core-a11y-keys')
class CoreA11yKeys extends HtmlElement with DomProxyMixin, PolymerProxyMixin {
  CoreA11yKeys.created() : super.created();
  factory CoreA11yKeys() => new Element.tag('core-a11y-keys');

  /// The set of key combinations that will be matched (in keys syntax).
  String get keys => jsElement[r'keys'];
  set keys(String value) { jsElement[r'keys'] = value; }

  /// The node that will fire keyboard events.
  /// Default to this element's parentNode unless one is assigned
  get target => jsElement[r'target'];
  set target(value) { jsElement[r'target'] = (value is Map || value is Iterable) ? new JsObject.jsify(value) : value;}
}
