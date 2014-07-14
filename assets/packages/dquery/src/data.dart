part of dquery;

class _Storage {
  
  final String _name;
  final Expando<Map> _cache;
  
  _Storage(String name) :
  _name = name,
  _cache = new Expando<Map>(name);
  
  void set(owner, String key, value) {
    getSpace(owner)[key] = value;
  }
  
  void setAll(Node owner, Map<String, dynamic> props) {
    final Map space = getSpace(owner);
    props.forEach((String key, value) => space[key] = value);
  }
  
  get(owner, String key) {
    Map space = _cache[owner];
    return space == null ? null : space[key];
  }
  
  Map getSpace(owner, [bool autoCreate = true]) {
    Map space = _cache[owner];
    if (autoCreate && space == null)
      space = _cache[owner] = new HashMap();
    return space;
  }
  
  void remove(Node owner, String key) {
    Map space = _cache[owner];
    if (space != null) {
      space.remove(key);
      if (space.isEmpty)
        _cache[owner] = null;
    }
  }
  
  bool hasData(owner) {
    Map space = _cache[owner];
    return space != null && !space.isEmpty;
  }
  
  void discard(owner) {
    _cache[owner] = null;
  }
  
}

final _Storage _dataUser = new _Storage('dquery-data-user');
final _Storage _dataPriv = new _Storage('dquery-data-priv');

/** The interface for accessing element data.
 */
class Data {
  
  final _DQuery _dq;
  
  Data._(this._dq);
  
  /** Retrieve the entire space of element data.
   */
  Map space() => _dq.isEmpty ? null : _dataUser.getSpace(_dq.first);
  
  /** Retrieve the data of the given [key].
   */
  get(String key) => _dq.isEmpty ? null : space()[key];
  
  /** Set the data of the given [key].
   */
  void set(String key, value) => 
      _dq.forEach((t) => _dataUser.set(t, key, value));
  
  /** Delete the data of the given [key].
   */
  void remove(String key) =>
      _dq.forEach((t) => _dataUser.remove(t, key));
  
}

/*
_dataAttr(Element elem, String key, data) {
  // TODO: it's a function that offers some fix to the key and data to leverege HTML 5 
  // data- attributes, should be important to plug-in environment
  
  return data;
}
*/
