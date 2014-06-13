part of nodes;

class Atrule implements Node {
  String name;
  Expression expression;
  var block;

  Atrule(this.name, [this.expression, this.block]);

  eval(env) {
    expression = expression.eval(env);
    block = block != null ? block.eval(env) : null;
    return this;
  }

  css(env) {
    env.buff.write(name + ' ');
    env.buff.write(expression.css(env));
    if (block != null) {
      env.buff.write(env.compress > 4 ? '{' : ' {\n');
      ++env.indents;
      block.css(env);
      --env.indents;
      env.buff..write('}')
              ..write(env.compress > 4 ? '' : '\n');
    } else {
      env.buff..write(env.compress > 4 ? ';' : ';\n');
    }
  }
}