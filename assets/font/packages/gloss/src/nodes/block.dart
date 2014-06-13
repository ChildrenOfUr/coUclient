part of nodes;

class Block implements Node {
  List nodes = [];
  num index = 0;

  Block([this.nodes]) {
    if(this.nodes == null) {
      this.nodes = [];
    }
  }

  push(node) => nodes.add(node);

  get hasDeclarations {
    for (var i = 0, len = nodes.length; i < len; ++i)
      if (nodes[i] is Declaration) {
        return true;
      }
    return false;
  }

  get length => nodes.length;

  eval(env) {
    env.block = this;

    for (index = 0; index < nodes.length; ++index) {
      nodes[index] = nodes[index].eval(env);
    }
    if (env.compress > 2) {
      var nodesMap = {},
          compressed,
          node,
          prop;

      for (var i = 0, prop, len = nodes.length; i < len; ++i) {
        node = nodes[i];
        if (
          node is Declaration
          && shorthands[prop = node.property.replaceAll(new RegExp(r'-?(top|right|bottom|left)'), '')] != null
        ) {
          if (nodesMap[prop] == null) {
            nodesMap[prop] = [];
          }
          nodesMap[prop].add({
            'index': i,
            'side': shorthands[prop].indexOf(node.property),
            'value': node.value
          });
        }
      }
      nodesMap.keys.forEach((prop) {
        if ((compressed = compressProperties(nodesMap[prop])) != null) {
          node = nodes[compressed['index']];
          node.property = prop;
          node.value = compressed['value'];
          node = node.eval(env);
          for(var i in compressed['toRemove']) {
            nodes[i] = null;
          }
        }
      });

      nodes = nodes.where((_) => _ != null).toList();
    }

    return this;
  }

  css(env) {
    var node;

    if (this.hasDeclarations) {
      env.buff.write(env.compress > 4 ? '{' : ' {\n');
      var arr = [];
      ++env.indents;
      for (var i = 0, len = nodes.length; i < len; ++i) {
        node = nodes[i];
        if (node is Declaration) {
           arr.add(node.css(env));
        }
      }
      --env.indents;
      if (env.compress < 4) {
        arr.add('');
      }
      env.buff..write(arr.join(env.compress > 4 ? ';' : ';\n'))
              ..write(env.compress == 4 ? '\n' : '')
              ..write(env.indent)
              ..write(env.compress > 4 ? '}' : '}\n');
    }

    for (var i = 0, len = nodes.length; i < len; ++i) {
      node = nodes[i];
      if (node is Ruleset || node is Atrule || node is Block) {
        node.css(env);
      }
    }
  }

  compressProperties(arr) {
    if (arr.length < 2) return null;

    var toRemove = [],
        expr = new Expression(),
        index;

    expr.nodes = new List(4);

    arr.forEach((node) {
      if (arr.first == node) {
        index = node['index'];
      } else {
        toRemove.add(node['index']);
      }
      if (node['side'] == -1) {
        expr = node['value'];
        if (expr.nodes.length < 2) {
          expr.push(expr.nodes[0]);
        }

        if (expr.nodes.length < 3) {
          expr.push(expr.nodes[0]);
        }

        if (expr.nodes.length < 4) {
          expr.push(expr.nodes[1]);
        }
      } else {
        expr.nodes[node['side']] = node['value'].nodes[0];
      }
    });

    if (expr.nodes.every((_) => _ != null)) {
      return {
        'value': expr,
        'index': index,
        'toRemove': toRemove
      };
    }
    return null;
  }
}
