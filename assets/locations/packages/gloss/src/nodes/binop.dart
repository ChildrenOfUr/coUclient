part of nodes;

class Binop extends Node {
  String op;
  Node left, right;

  Binop(this.op, this.left, this.right);

  eval(env) {
    Dimension l = left.eval(env),
      r = right.eval(env);
    return l.operate(op, r).eval(env);
  }
}