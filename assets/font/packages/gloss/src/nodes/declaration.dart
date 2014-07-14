part of nodes;

class Declaration implements Node {
  String property;
  var value;

  Declaration(this.property, [this.value]);

  eval(env) {
    var fn, args;

    if (env.calling.indexOf(property) < 0
        && (fn = env.lookup(property)) != null
        && (fn is Definition)
    ) {
      args = new Arguments(true);
      if (!value.isList) {
        args.push(this.value);
      } else {
        args.nodes = value.nodes;
      }
      return (new Call(property, args)).eval(env);
    }

    value = value.eval(env);

    if (env.compress > 1) {
      if (shorthands[this.property] != null) {
        var values = value;
        if (values.length >= 3 && values.get(1) == values.get(3)) {
          values.pop();
        }
        if (values.get(0) == values.get(2)) {
          values.pop();
        }
        if (values.length == 2 && values.get(0) == values.get(1)) {
          values.pop();
        }
      }
    }

    return this;
  }

  css(env) {
    var val = value.css(env).trim();
    return '${env.indent}$property${env.compress > 4 ? ':$val' : ': $val'}';
  }
}