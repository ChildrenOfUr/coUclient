part of nodes;

class Str extends Node {
  String value, quote;

  Str(this.value, [this.quote = "'"]);

  css(env) => '$quote$value$quote';
}
