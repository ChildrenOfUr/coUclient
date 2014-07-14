part of nodes;

class Ident implements Node {
  String name;
  var value;

  Ident(this.name, [this.value]);

  eval(env) {
    if (value == null) {
      value = env.lookup(name);
      return value != null && value is! Function ? value.eval(env) : this;
    } else {
      value = value.eval(env);
      env.scope.add(this);
      return new Null();
    }
 }

  css(env) {
    return name;
  }
}
