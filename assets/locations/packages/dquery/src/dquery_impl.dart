//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
part of dquery;

// TODO: may simplify _first and _forEachEventTarget()

/*
// The deferred used on DOM ready
readyList,
*/

/*
// Use the correct document accordingly with window argument (sandbox)
location = window.location,
document = window.document,
docElem = document.documentElement,
*/

/*
// List of deleted data cache ids, so we can reuse them
core_deletedIds = [],
*/
/*
// Save a reference to some core methods
core_concat = core_deletedIds.concat,
core_push = core_deletedIds.push,
core_slice = core_deletedIds.slice,
core_indexOf = core_deletedIds.indexOf,
core_toString = class2type.toString,
core_hasOwn = class2type.hasOwnProperty,
core_trim = core_version.trim,
  // Used for matching numbers
core_pnum = /[+-]?(?:\d*\.|)\d+(?:[eE][+-]?\d+|)/.source,

// Used for splitting on whitespace
core_rnotwhite = /\S+/g,

// A simple way to check for HTML strings
// Prioritize #id over <tag> to avoid XSS via location.hash (#9521)
// Strict HTML recognition (#11290: must start with <)
rquickExpr = /^(?:(<[\w\W]+>)[^>]*|#([\w-]*))$/,

// Match a standalone tag
rsingleTag = /^<(\w+)\s*\/?>(?:<\/\1>|)$/,

// Matches dashed string for camelizing
rmsPrefix = /^-ms-/,
rdashAlpha = /-([\da-z])/gi,

// Used by jQuery.camelCase as callback to replace()
fcamelCase = function( all, letter ) {
  return letter.toUpperCase();
},

// The ready event handler and self cleanup method
completed = function() {
  document.removeEventListener( "DOMContentLoaded", completed, false );
  window.removeEventListener( "load", completed, false );
  jQuery.ready();
};
*/

abstract class _DQuery<T/* extends EventTarget*/> implements DQuery<T> {
  
  // skipped unless necessary
  // void _dquery(DQuery dquery) {}
  // void _function() {}
  // void _object() {}
  // void _html() {}
  
  @override
  get context => _context;
  var _context;

  _DQuery _prevObject;
  
  // DQuery //
  List<Element> _queryAll(String selector);
  
  @override
  T get firstIfAny => isEmpty ? null : first;
  
  @override
  String get selector => null;
  
  @override
  ElementQuery find(String selector) {
    final String s = this.selector != null ? "${this.selector} $selector" : selector;
    // jQuery: Needed because $( selector, context ) becomes $( context ).find( selector )
    return (pushStack(_queryAll(selector)) as _ElementQuery).._selector = s;
  }
  
  @override
  ElementQuery pushStack(List<Element> elems) => 
      new _ElementQuery(elems) // TODO: copy? no copy?
      .._prevObject = this
      .._context = _context;
  
  /*
  eq: function( i ) {
    var len = this.length,
    j = +i + ( i < 0 ? len : 0 );
    return this.pushStack( j >= 0 && j < len ? [ this[j] ] : [] );
  },
  map: function( callback ) {
    return this.pushStack( jQuery.map(this, function( elem, i ) {
      return callback.call( elem, i, elem );
    }));
  },
  */

  @override
  DQuery end() => _fallback(_prevObject, () => new ElementQuery([]));
  
  
  
  // data //
  @override
  Data get data => _fallback(_data, () => (_data = new Data._(this)));
  Data _data;
  
  // event //
  @override
  void on(String types, DQueryEventListener handler, {String selector}) {
    _on(types, handler, selector, false);
  }
  
  @override
  void one(String types, DQueryEventListener handler, {String selector}) {
    _on(types, handler, selector, true);
  }
  
  void _on(String types, DQueryEventListener handler, String selector, bool one) {
    if (handler == null)
      return;
    
    // TODO: handle guid for removal
    DQueryEventListener h = !one ? handler : (DQueryEvent dqevent) {
      // jQuery: Can use an empty set, since event contains the info
      _offEvent(dqevent);
      handler(dqevent);
    };
    
    forEach((EventTarget t) => _EventUtil.add(t, types, h, selector));
  }
  
  @override
  void off(String types, {String selector, DQueryEventListener handler}) =>
      forEach((EventTarget t) => _EventUtil.remove(t, types, handler, selector));
  
  // utility refactored from off() to make type clearer
  static void _offEvent(DQueryEvent dqevent) {
    final _HandleObject handleObj = dqevent._handleObj;
    final String namespace = handleObj.namespace;
    final String type = namespace != null && !namespace.isEmpty ? 
        "${handleObj.origType}.${namespace}" : handleObj.origType;
    $(dqevent.delegateTarget).off(type, handler: handleObj.handler, selector: handleObj.selector);
  }
  
  @override
  void trigger(String type, {data}) =>
      forEach((EventTarget t) => _EventUtil.trigger(type, data, t));
  
  @override
  void triggerEvent(DQueryEvent event) =>
      forEach((EventTarget t) => _EventUtil.triggerEvent(event.._target = t));
  
  @override
  void triggerHandler(String type, {data}) {
    if (!isEmpty)
      _EventUtil.trigger(type, data, first, true);
  }
  
  // traversing //
  
}

class _DocQuery extends _DQuery<HtmlDocument> with ListMixin<HtmlDocument> implements DocumentQuery {
  
  HtmlDocument _document;
  
  _DocQuery([HtmlDocument doc]) : this._document = _fallback(doc, () => document);
  
  // DQuery //
  @override
  HtmlDocument operator [](int index) => _document;
  
  @override
  void operator []=(int index, HtmlDocument value) {
    if (index != 0 || value == null)
      throw new ArgumentError("$index: $value");
    _document = value;
  }
  
  @override
  int get length => 1;
  
  @override
  void set length(int length) {
    if (length != 1)
      throw new UnsupportedError("fixed length");
  }
  
  @override
  List<Element> _queryAll(String selector) => _document.querySelectorAll(selector);
  
  Window get _window => _document.window;
  
  @override
  int get scrollLeft => _window.pageXOffset;
  
  @override
  int get scrollTop => _window.pageYOffset;
  
  @override
  void set scrollLeft(int value) => 
      _window.scrollTo(value, _window.pageYOffset);
  
  @override
  void set scrollTop(int value) => 
      _window.scrollTo(_window.pageXOffset, value);
  
  @override
  int get width =>
      _max([_document.body.scrollWidth, _document.documentElement.scrollWidth,
            _document.body.offsetWidth, _document.documentElement.offsetWidth,
            _document.documentElement.clientWidth]);
  
  @override
  int get height =>
      _max([_document.body.scrollHeight, _document.documentElement.scrollHeight,
            _document.body.offsetHeight, _document.documentElement.offsetHeight,
            _document.documentElement.clientHeight]);
  
}

class _WinQuery extends _DQuery<Window> with ListMixin<Window> implements WindowQuery {
  
  Window _window;
  
  _WinQuery([Window win]) : this._window = _fallback(win, () => window);
  
  // DQuery //
  @override
  Window operator [](int index) => _window;
  
  @override
  void operator []=(int index, Window value) {
    if (index != 0 || value == null)
      throw new ArgumentError("$index: $value");
    _window = value;
  }
  
  @override
  int get length => 1;
  
  @override
  void set length(int length) {
    if (length != 1)
      throw new UnsupportedError("fixed length");
  }

  @override
  List<Element> _queryAll(String selector) => [];
  
  @override
  int get scrollLeft => _window.pageXOffset;
  
  @override
  int get scrollTop => _window.pageYOffset;
  
  @override
  void set scrollLeft(int value) => 
      _window.scrollTo(value, _window.pageYOffset);
  
  @override
  void set scrollTop(int value) => 
      _window.scrollTo(_window.pageXOffset, value);
  
  // jQuery: As of 5/8/2012 this will yield incorrect results for Mobile Safari, but there
  //         isn't a whole lot we can do. See pull request at this URL for discussion:
  //         https://github.com/jquery/jquery/pull/764
  @override
  int get width => _window.document.documentElement.clientWidth;
  
  @override
  int get height => _window.document.documentElement.clientHeight;
  
}

class _ElementQuery extends _DQuery<Element> with ListMixin<Element> implements ElementQuery {
  
  final List<Element> _elements;
  
  _ElementQuery(this._elements);
  
  @override
  String get selector => _selector;
  String _selector;
  
  // List //
  @override
  Element operator [](int index) {
      return _elements[index];
  }
  
  @override
  int get length => _elements.length;
  
  @override
  void operator []=(int index, Element value) {
    _elements[index] = value;
  }
  
  @override
  void set length(int length) {
    _elements.length = length;
  }
  
  // DQuery //
  @override
  List<Element> _queryAll(String selector) {
    switch (length) {
      case 0:
        return [];
      case 1:
        return first.querySelectorAll(selector);
      default:
        final List<Element> matched = new List<Element>();
        for (Element elem in _elements)
          matched.addAll(elem.querySelectorAll(selector));
        return DQuery.unique(matched);
    }
  }
  
  // ElementQuery //
  @override
  ElementQuery closest(String selector) {
    final Set<Element> results = new LinkedHashSet<Element>();
    Element c;
    for (Element e in _elements)
      if ((c = _closest(e, selector)) != null)
        results.add(c);
    return pushStack(results.toList(growable: true));
  }
  
  @override
  ElementQuery parent([String selector]) {
    final Set<Element> results = new LinkedHashSet<Element>();
    Element p;
    for (Element e in _elements)
      if ((p = e.parent) != null && (selector == null || p.matches(selector)))
        results.add(p);
    return pushStack(results.toList(growable: true));
  }
  
  @override
  ElementQuery children([String selector]) {
    final List<Element> results = new List<Element>();
    for (Element e in _elements)
      for (Element c in e.children)
        if (selector == null || c.matches(selector))
          results.add(c);
    return pushStack(results);
  }
  
  @override
  void show() => _showHide(_elements, true);
  
  @override
  void hide() => _showHide(_elements, false);
  
  @override
  void toggle([bool state]) {
    for (Element elem in _elements)
      _showHide([elem], _fallback(state, () => _isHidden(elem)));
  }
  
  @override
  css(String name, [String value]) =>
      value != null ? _elements.forEach((Element e) => _setCss(e, name, value)) :
          _elements.isEmpty ? null : _getCss(_elements.first, name);
  
  @override
  bool hasClass(String name) =>
      _elements.any((Element e) => e.classes.contains(name));
  
  @override
  void addClass(String name) =>
      _elements.forEach((Element e) => e.classes.add(name));
  
  @override
  void removeClass(String name) =>
      _elements.forEach((Element e) => e.classes.remove(name));
  
  @override
  void toggleClass(String name) =>
      _elements.forEach((Element e) => e.classes.toggle(name));
  
  @override
  void appendTo(target) =>
      _domManip(_resolveManipTarget(target), this, _appendFunc);
  
  @override
  void prependTo(target) =>
      _domManip(_resolveManipTarget(target), this, _prependFunc);
  
  @override
  void append(content) => _domManip(this, content, _appendFunc);
  
  @override
  void prepend(content) => _domManip(this, content, _prependFunc);
  
  @override
  void before(content) => _domManip(this, content, _beforeFunc);
  
  @override
  void after(content) => _domManip(this, content, _afterFunc);
  
  @override
  ElementQuery clone([bool withDataAndEvents, bool deepWithDataAndEvents]) =>
      pushStack(_elements.map((Element e) => _clone(e)));
  
  @override
  void detach({String selector, bool data: true}) => 
      (selector != null && !(selector = selector.trim()).isEmpty ? 
          _filter(selector, _elements) : new List<Element>.from(_elements))
          .forEach((Element e) => _detach(e, data));
  
  @override
  void empty() => _elements.forEach((Element e) => _empty(e));
  
  @override
  String get text =>
      (new StringBuffer()..writeAll(_elements.map((Element elem) => elem.text)))
      .toString();
  
  @override
  void set text(String value) =>
      _elements.forEach((Element e) => _setText(e, value));
  
  @override
  String get html =>
      isEmpty ? null : _elements.first.innerHtml;
  
  @override
  void set html(String value) =>
      _elements.forEach((Element e) => e.innerHtml = value);
  
  @override
  Point get offset => isEmpty ? null : _getOffset(_elements.first);
  
  @override
  void set offset(Point value) =>
      _elements.forEach((Element e) => _setOffset(e, left: value.x, top: value.y));
  
  @override
  void set offsetLeft(int left) =>
      _elements.forEach((Element e) => _setOffset(e, left: left));
  
  @override
  void set offsetTop(int top) =>
      _elements.forEach((Element e) => _setOffset(e, top: top));
  
  @override
  Point get position => isEmpty ? null : _getPosition(_elements.first);
  
  @override
  ElementQuery get offsetParent {
    final Set<Element> results = new LinkedHashSet<Element>();
    for (Element e in _elements)
      results.add(_getOffsetParent(e));
    return pushStack(results.toList(growable: true));
  }
  
  @override
  int get scrollLeft => isEmpty ? null : _elements.first.scrollLeft;
  
  @override
  int get scrollTop => isEmpty ? null : _elements.first.scrollTop;
  
  @override
  void set scrollLeft(int value) =>
      _elements.forEach((Element e) => e.scrollLeft = value);
  
  @override
  void set scrollTop(int value) =>
      _elements.forEach((Element e) => e.scrollTop = value);
  
  @override
  int get width => _elements.isEmpty ? null : _getElementWidth(_elements.first);
  
  @override
  int get height => _elements.isEmpty ? null : _getElementHeight(_elements.first);
  
}

// All DQuery objects should point back to these
DocumentQuery _rootDQuery = new DocumentQuery();

/*
// Is the DOM ready to be used? Set to true once it occurs.
isReady: false,

// A counter to track how many items to wait for before
// the ready event fires. See #6781
readyWait: 1,

// Hold (or release) the ready event
holdReady: function( hold ) {
  if ( hold ) {
    jQuery.readyWait++;
  } else {
    jQuery.ready( true );
  }
},

// Handle when the DOM is ready
ready: function( wait ) {

  // Abort if there are pending holds or we're already ready
  if ( wait === true ? --jQuery.readyWait : jQuery.isReady ) {
    return;
  }

  // Remember that the DOM is ready
  jQuery.isReady = true;

  // If a normal DOM Ready event fired, decrement, and wait if need be
  if ( wait !== true && --jQuery.readyWait > 0 ) {
    return;
  }

  // If there are functions bound, to execute
    readyList.resolveWith( document, [ jQuery ] );

  // Trigger any bound ready events
  if ( jQuery.fn.trigger ) {
    jQuery( document ).trigger("ready").off("ready");
  }
},
*/

// jQuery: See test/unit/core.js for details concerning isFunction.
//         Since version 1.3, DOM methods and functions like alert
//         aren't supported. They return false on IE (#2968).
// SKIPPED: js only
// src: isFunction: function( obj ) {

// SKIPPED: js only
// src: isArray: Array.isArray,

//bool _isWindow(obj) => obj != null && obj is Window;

/*
isNumeric: function( obj ) {
  return !isNaN( parseFloat(obj) ) && isFinite( obj );
},

type: function( obj ) {
  if ( obj == null ) {
    return String( obj );
  }
  // Support: Safari <= 5.1 (functionish RegExp)
  return typeof obj === "object" || typeof obj === "function" ?
    class2type[ core_toString.call(obj) ] || "object" :
    typeof obj;
},

isPlainObject: function( obj ) {
  // Not plain objects:
  // - Any object or value whose internal [[Class]] property is not "[object Object]"
  // - DOM nodes
  // - window
  if ( jQuery.type( obj ) !== "object" || obj.nodeType || jQuery.isWindow( obj ) ) {
    return false;
  }
  
  // Support: Firefox <20
  // The try/catch suppresses exceptions thrown when attempting to access
  // the "constructor" property of certain host objects, ie. |window.location|
  // https://bugzilla.mozilla.org/show_bug.cgi?id=814622
  try {
    if ( obj.constructor &&
    !core_hasOwn.call( obj.constructor.prototype, "isPrototypeOf" ) ) {
      return false;
    }
  } catch ( e ) {
    return false;
  }
  
  // If the function hasn't returned already, we're confident that
  // |obj| is a plain object, created by {} or constructed with new Object
  return true;
},
*/

/*

// data: string of html
// context (optional): If specified, the fragment will be created in this context, defaults to document
// keepScripts (optional): If true, will include scripts passed in the html string
parseHTML: function( data, context, keepScripts ) {
  if ( !data || typeof data !== "string" ) {
    return null;
  }
  if ( typeof context === "boolean" ) {
    keepScripts = context;
    context = false;
  }
  context = context || document;

  var parsed = rsingleTag.exec( data ),
  scripts = !keepScripts && [];

  // Single tag
  if ( parsed ) {
    return [ context.createElement( parsed[1] ) ];
  }

  parsed = jQuery.buildFragment( [ data ], context, scripts );

  if ( scripts ) {
    jQuery( scripts ).remove();
  }

  return jQuery.merge( [], parsed.childNodes );
},

parseJSON: JSON.parse,

// Cross-browser xml parsing
parseXML: function( data ) {
  var xml, tmp;
  if ( !data || typeof data !== "string" ) {
    return null;
  }

  // Support: IE9
  try {
    tmp = new DOMParser();
    xml = tmp.parseFromString( data , "text/xml" );
  } catch ( e ) {
    xml = undefined;
  }

  if ( !xml || xml.getElementsByTagName( "parsererror" ).length ) {
    jQuery.error( "Invalid XML: " + data );
  }
  return xml;
},
*/
//void _noop() {}
/*
// Evaluates a script in a global context
globalEval: function( code ) {
  var script,
  indirect = eval;

  code = jQuery.trim( code );

  if ( code ) {
    // If the code includes a valid, prologue position
    // strict mode pragma, execute code by injecting a
    // script tag into the document.
    if ( code.indexOf("use strict") === 1 ) {
      script = document.createElement("script");
      script.text = code;
      document.head.appendChild( script ).parentNode.removeChild( script );
    } else {
      // Otherwise, avoid the DOM node creation, insertion
      // and removal by using an indirect global eval
      indirect( code );
    }
  }
},

// Convert dashed to camelCase; used by the css and data modules
// Microsoft forgot to hump their vendor prefix (#9572)
camelCase: function( string ) {
  return string.replace( rmsPrefix, "ms-" ).replace( rdashAlpha, fcamelCase );
},
*/
bool _nodeName(elem, String name) =>
    elem is Element && (elem as Element).tagName.toLowerCase() == name.toLowerCase();

/*
// args is for internal usage only
each: function( obj, callback, args ) {
  var value,
    i = 0,
    length = obj.length,
    isArray = isArraylike( obj );

  if ( args ) {
    if ( isArray ) {
      for ( ; i < length; i++ ) {
        value = callback.apply( obj[ i ], args );

        if ( value === false ) {
          break;
        }
      }
    } else {
      for ( i in obj ) {
        value = callback.apply( obj[ i ], args );

        if ( value === false ) {
          break;
        }
      }
    }

    // A special, fast, case for the most common use of each
  } else {
    if ( isArray ) {
      for ( ; i < length; i++ ) {
        value = callback.call( obj[ i ], i, obj[ i ] );

        if ( value === false ) {
          break;
        }
      }
    } else {
      for ( i in obj ) {
        value = callback.call( obj[ i ], i, obj[ i ] );

        if ( value === false ) {
          break;
        }
      }
    }
  }

  return obj;
},
*/
String trim(String text) => text == null ? '' : text.trim();

/*
// results is for internal usage only
makeArray: function( arr, results ) {
  var ret = results || [];

  if ( arr != null ) {
    if ( isArraylike( Object(arr) ) ) {
      jQuery.merge( ret,
        typeof arr === "string" ?
        [ arr ] : arr
      );
    } else {
      core_push.call( ret, arr );
    }
  }

  return ret;
},

inArray: function( elem, arr, i ) {
  return arr == null ? -1 : core_indexOf.call( arr, elem, i );
},

merge: function( first, second ) {
  var l = second.length,
  i = first.length,
  j = 0;

  if ( typeof l === "number" ) {
    for ( ; j < l; j++ ) {
      first[ i++ ] = second[ j ];
    }
  } else {
    while ( second[j] !== undefined ) {
      first[ i++ ] = second[ j++ ];
    }
  }

  first.length = i;

  return first;
},
*/

/**
 * 
 */
List _grep(List list, bool test(obj, index), [bool invert = false]) {
  // USE Dart's implementation
  int i = 0;
  return new List.from(list.where((obj) => invert != test(obj, i++)));
}

/*
// arg is for internal usage only
map: function( elems, callback, arg ) {
  var value,
    i = 0,
    length = elems.length,
    isArray = isArraylike( elems ),
    ret = [];

  // Go through the array, translating each of the items to their
  if ( isArray ) {
    for ( ; i < length; i++ ) {
      value = callback( elems[ i ], i, arg );

      if ( value != null ) {
        ret[ ret.length ] = value;
      }
    }

  // Go through every key on the object,
  } else {
    for ( i in elems ) {
      value = callback( elems[ i ], i, arg );

      if ( value != null ) {
        ret[ ret.length ] = value;
      }
    }
  }

  // Flatten any nested arrays
  return core_concat.apply( [], ret );
},
*/

// jQuery: A global GUID counter for objects
int _guid = 1;

/*
// Bind a function to a context, optionally partially applying any
// arguments.
proxy: function( fn, context ) {
  var tmp, args, proxy;

  if ( typeof context === "string" ) {
    tmp = fn[ context ];
    context = fn;
    fn = tmp;
  }

  // Quick check to determine if target is callable, in the spec
  // this throws a TypeError, but we will just return undefined.
  if ( !jQuery.isFunction( fn ) ) {
    return undefined;
  }

  // Simulated bind
  args = core_slice.call( arguments, 2 );
  proxy = function() {
    return fn.apply( context || this, args.concat( core_slice.call( arguments ) ) );
  };

  // Set the guid of unique handler to the same of original handler, so it can be removed
  proxy.guid = fn.guid = fn.guid || jQuery.guid++;

  return proxy;
},

// Multifunctional method to get and set values of a collection
// The value/s can optionally be executed if it's a function
access: function( elems, fn, key, value, chainable, emptyGet, raw ) {
  var i = 0,
    length = elems.length,
    bulk = key == null;

  // Sets many values
  if ( jQuery.type( key ) === "object" ) {
    chainable = true;
    for ( i in key ) {
      jQuery.access( elems, fn, i, key[i], true, emptyGet, raw );
    }

  // Sets one value
  } else if ( value !== undefined ) {
    chainable = true;

    if ( !jQuery.isFunction( value ) ) {
      raw = true;
    }

    if ( bulk ) {
      // Bulk operations run against the entire set
      if ( raw ) {
        fn.call( elems, value );
        fn = null;

        // ...except when executing function values
      } else {
        bulk = fn;
        fn = function( elem, key, value ) {
          return bulk.call( jQuery( elem ), value );
        };
      }
    }

    if ( fn ) {
      for ( ; i < length; i++ ) {
        fn( elems[i], key, raw ? value : value.call( elems[i], i, fn( elems[i], key ) ) );
      }
    }
  }

  return chainable ?
    elems :

    // Gets
    bulk ?
      fn.call( elems ) :
      length ? fn( elems[0], key ) : emptyGet;
},

now: Date.now,

// A method for quickly swapping in/out CSS properties to get correct calculations.
// Note: this method belongs to the css module but it's needed here for the support module.
// If support gets modularized, this method should be moved back to the css module.
swap: function( elem, options, callback, args ) {
  var ret, name,
    old = {};

  // Remember the old values, and insert the new ones
  for ( name in options ) {
    old[ name ] = elem.style[ name ];
    elem.style[ name ] = options[ name ];
  }

  ret = callback.apply( elem, args || [] );

  // Revert the old values
  for ( name in options ) {
    elem.style[ name ] = old[ name ];
  }

  return ret;
},
*/

/*
// [[Class]] -> type pairs
class2type = {},

// Populate the class2type map
jQuery.each("Boolean Number String Function Array Date RegExp Object Error".split(" "), function(i, name) {
  class2type[ "[object " + name + "]" ] = name.toLowerCase();
});
*/

/*
function isArraylike( obj ) {
  var length = obj.length,
    type = jQuery.type( obj );

  if ( jQuery.isWindow( obj ) ) {
    return false;
  }

  if ( obj.nodeType === 1 && length ) {
    return true;
  }

  return type === "array" || type !== "function" &&
     ( length === 0 ||
      typeof length === "number" && length > 0 && ( length - 1 ) in obj );
}
*/
