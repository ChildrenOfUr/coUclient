/*
 * Copyright (c) 2014 The Polymer Project Authors. All rights reserved.
 * This code may only be used under the BSD style license found at http://polymer.github.io/LICENSE.txt
 * The complete set of authors may be found at http://polymer.github.io/AUTHORS.txt
 * The complete set of contributors may be found at http://polymer.github.io/CONTRIBUTORS.txt
 * Code distributed by Google as part of the polymer project is also
 * subject to an additional IP rights grant found at http://polymer.github.io/PATENTS.txt
 */
/// Dart API for the polymer element `core-localstorage-dart`.
@HtmlImport('core_localstorage_dart_nodart.html')
library core_elements.core_localstorage_dart;

import 'dart:html';
import 'dart:convert' show JSON;
import 'package:polymer/polymer.dart';

/// Element access to localStorage.  The "name" property
/// is the key to the data ("value" property) stored in localStorage.
///
/// `core-localstorage-dart` automatically saves the value to localStorage when
/// value is changed.  Note that if value is an object auto-save will be
/// triggered only when value is a different instance.
///
///     <core-localstorage-dart name="my-app-storage" value="{{value}}"></core-localstorage-dart>
@CustomTag('core-localstorage-dart')
class CoreLocalStorage extends PolymerElement {
  /**
   * Fired when a value is loaded from localStorage.
   * @event core-localstorage-load
   */

  /**
   * The key to the data stored in localStorage.
   *
   * @attribute name
   * @type string
   * @default null
   */
  @observable String name = '';

  /**
   * The data associated with the specified name.
   *
   * @attribute value
   * @type object
   * @default null
   */
  @observable var value;

  /**
   * If true, the value is stored and retrieved without JSON processing.
   *
   * @attribute useRaw
   * @type boolean
   * @default false
   */
  @observable bool useRaw = false;

  /**
   * If true, auto save is disabled.
   *
   * @attribute autoSaveDisabled
   * @type boolean
   * @default false
   */
  @observable bool autoSaveDisabled = false;

  @observable bool loaded = false;

  factory CoreLocalStorage() => new Element.tag('core-localstorage-dart');
  CoreLocalStorage.created() : super.created();

  @override
  attached() {
    // wait for bindings are all setup
    this.async((_) => load());
  }

  void valueChanged() {
    if (this.loaded && !this.autoSaveDisabled) {
      this.save();
    }
  }

  void load() {
    var v = window.localStorage[name];
    if (useRaw) {
      value = v;
    } else {
      // localStorage has a flaw that makes it difficult to determine
      // if a key actually exists or not (getItem returns null if the
      // key doesn't exist, which is not distinguishable from a stored
      // null value)
      // however, if not `useRaw`, an (unparsed) null value unambiguously
      // signals that there is no value in storage (a stored null value would
      // be escaped, i.e. "null")
      // in this case we save any non-null current (default) value
      if (v == null) {
        if (this.value != null) {
          this.save();
        }
      } else {
        try {
          v = JSON.decode(v);
        } catch(x) {
        }
        this.value = v;
      }
    }
    this.loaded = true;
    this.asyncFire('core-localstorage-load');
  }

  /**
   * Saves the value to localStorage.
   *
   * @method save
   */
  void save() {
    window.localStorage[name] = useRaw ? value : JSON.encode(value);
  }
}
