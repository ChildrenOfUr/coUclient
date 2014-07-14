part of nodes;

class Literal extends Node {
  String value;

  Literal(this.value);

  css(env) => value;
}
