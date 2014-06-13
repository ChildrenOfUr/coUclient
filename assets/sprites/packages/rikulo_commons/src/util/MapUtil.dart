//Copyright (C) 2012 Potix Corporation. All Rights Reserved.
//History: Thu, Jun 28, 2012 10:30:47 AM
// Author: tomyeh
part of rikulo_util;

/** A readonly and empty map.
 */
const Map EMPTY_MAP = const {};

/**
 * A collection of Map related utilities.
 */
class MapUtil {
  /** Returns a map that will be created only when necessary, such as
   * [Map.putIfAbsent] is called.
   *
   * It assumes the map was empty, and creates by invoking [creator]
   * when necessary. Don't use this method if the map already exists.
   *
   * It is useful to save the memory, if you have a map that won't contain
   * anything in most case.
   *
   * Notice you don't have to keep the object being returned by this method,
   * since it is just a proxy to the real map.
   * Refer to Rikulo UI's `View.dataset` for a sample implementation.
   */
  static Map onDemand(AsMap creator) => new _OnDemandMap(creator);

  /** Copies the given map ([source]) to the destination ([dest]).
   */
  static Map copy(Map source, Map dest, [bool filter(key, value)]) {
    for (final key in source.keys) {
      final value = source[key];
      if (filter != null || filter(key, value))
        dest[key] = value;
    }
    return dest;
  }

  /** Parses the given string into a map.
   * The format of data is the same as HTML: `=` is optional, and
   * the value must be enclosed with `'` or `"`.
   *
   * * [backslash] specifies whether to handle backslash, such \n and \\.
   * * [defaultValue] specifies the value to use if it is not specified
   * (i.e., no equal sign).
   */
  static Map<String, String> parse(String data,
    {bool backslash:true, String defaultValue}) {
    Map<String, String> map = new LinkedHashMap();
    for (int i = 0, len = data.length; i < len;) {
      i = StringUtil.skipWhitespaces(data, i);
      if (i >= len)
        break; //no more

      final j = i;
      for (; i < len; ++i) {
        final cc = data[i];
        if (cc == '=' || StringUtil.isChar(cc, whitespace: true))
          break;
        if (cc == "'" || cc == '"')
          throw new FormatException("Quotation marks not allowed in key, $data");
      }

      final key = data.substring(j, i);
      if (key.isEmpty)
        throw new FormatException("Key required, $data");

      i = StringUtil.skipWhitespaces(data, i);
      if (i >= len || data[i] != '=') {
        map[key] = defaultValue;
        if (i >= len)
          break; //done
        continue;
      }

      final val = new StringBuffer();
      i = StringUtil.skipWhitespaces(data, i + 1);
      if (i < len) {
        final sep = data[i];
        if (sep != '"' &&  sep != "'")
          throw new FormatException("Quatation marks required for a value, $data");

        for (;;) {
          if (++i >= len)
            throw new FormatException("Unclosed string, $data");

          final cc = data[i];
          if (cc == sep) {
            ++i;
            break; //done
          }
          if (backslash && cc == '\\') {
            if (++i >= len)
              throw new FormatException("Illegal backslash, $data");
            switch (data[i]) {
              case 'n': val.write('\n'); continue;
              case 't': val.write('\t'); continue;
              case 'b': val.write('\b'); continue;
              case 'r': val.write('\r'); continue;
              default: val.write(data[i]); continue;
            }
          }
          val.write(cc);
        }
      } //if i >= 0
      map[key] = val.toString();
    }
    return map; 
  }
}

class _OnDemandMap<K, V> implements Map<K,V> {
  final AsMap _creator;
  Map<K, V> _map;

  _OnDemandMap(AsMap this._creator);

  Map _init() => _map != null ? _map: (_map = _creator());

  @override
  V  operator[](K key) => _map != null ? _map[key]: null;
  @override
  void operator[]=(K key, V value) {
    _init()[key] = value;
  }
  @override
  void addAll(Map<K, V> other) {
    _init().addAll(other);
  }
  @override
  void clear() {
    if (_map != null) _map.clear();
  }
  @override
  bool containsKey(K key) => _map != null && _map.containsKey(key);
  @override
  bool containsValue(V value) => _map != null && _map.containsValue(value);
  @override
  void forEach(void f(key, value)) {
    if (_map != null) _map.forEach(f);
  }
  @override
  Iterable<K> get keys => _map != null ? _map.keys: EMPTY_LIST;
  @override
  Iterable<V> get values => _map != null ? _map.values: EMPTY_LIST;
  @override
  bool get isEmpty => _map == null || _map.isEmpty;
  @override
  bool get isNotEmpty => !isEmpty;
  @override
  int get length => _map != null ? _map.length: 0;
  @override
  V putIfAbsent(K key, V ifAbsent()) => _init().putIfAbsent(key, ifAbsent);
  @override
  V remove(K key) => _map != null ? _map.remove(key): null;
  @override
  String toString() => (_map != null ? _map: EMPTY_MAP).toString();
}
