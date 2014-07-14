part of nodes;
class Params extends Node {
  List<Node> nodes;

  Params([this.nodes]) {
    if (this.nodes == null) {
      this.nodes = [];
    }
  }

  get length => nodes.length;

  push(Node node) => nodes.add(node);
}
