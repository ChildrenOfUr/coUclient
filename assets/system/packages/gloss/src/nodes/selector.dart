part of nodes;

class Selector extends Node {
  List segments;

  Selector(this.segments);

  css(env) {
    return env.compress > 4
      ? segments.join('').replaceAll(new RegExp(r'\s*([+~>])\s*'), '\1').trim()
      : segments.join('').trim();
  }
}