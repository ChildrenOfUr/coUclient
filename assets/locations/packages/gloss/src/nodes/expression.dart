part of nodes;

class Expression implements Node {
  List nodes;
  bool isList;

  Expression([this.isList = false, this.nodes]) {
    if (this.nodes == null) {
      this.nodes = [];
    }
  }

  get isEmpty => nodes.length == 0;

  get length => nodes.length;

  push(Node node) => nodes.add(node);

  pop() => nodes.removeLast();

  get(num idx) {
    if (idx < length && nodes[idx] != null) {
      return nodes[idx].value;
    }
  }

  eval(env) {
    nodes = nodes.map((node) => node.eval(env)).toList();
    return this;
  }

  css(env) {
    var buff = new StringBuffer(),
        n = nodes.map((node) => node.css(env));

    for (var i = 0, len = n.length; i < len; i++) {
      var last = i == (len - 1);
      buff.write(n.elementAt(i));
      if (n.elementAt(i) == '/' || (i + 1 < len && n.elementAt(i + 1) == '/')) continue;
      if (last) continue;
      buff.write(isList
        ? (env.compress > 4 ? ',' : ', ')
        : (env.isURL ? '' : ' '));
    }

    return buff.toString();
  }
}
