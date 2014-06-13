part of nodes;

class Definition extends Node {
  String name;
  Params params;
  Block block;

  Definition(this.name, this.params, [this.block]);

  get arity => params.length;

  eval(env) {
    env.scope.add(new Ident(name, this));
    return new Null();
  }
}