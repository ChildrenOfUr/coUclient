part of nodes;

class Stylesheet implements Node {
  List<Node> nodes;

  Stylesheet([this.nodes]) {
    if (this.nodes == null) {
      this.nodes = [];
    }
  }

  push(Node node) => nodes.add(node);

  unshift(Node node) => nodes.insert(0, node);

  eval(env, [bool defOnly = false]) {
    if (defOnly) {
      nodes.forEach((node) {
        if (node is Definition || node is Declaration) {
          node.eval(env);
        }
      });
    } else {
      nodes = nodes.map((node) => node.eval(env)).toList();
    }

    return this;
  }

  css(env) {
    nodes.forEach((node) {
      var ret = node.css(env);
      if (ret != null) {
        env.buff.write('$ret\n');
      }
    });

    return env.buff.toString();
  }

}