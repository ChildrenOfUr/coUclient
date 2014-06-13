library env;

import 'nodes.dart';
import 'dart:math';

part 'functions.dart';
part 'colors.dart';

class Env {
  num compress, _spaces, indents = 0;
  String path;

  List stack, calling = [], selectors = [];

  StringBuffer buff;

  Block block;

  bool isURL = false;

  Env([this.compress = 0, this._spaces = 2, this.path]) {
    var scope = new Scope();
    this.stack = [scope];
    this.buff = new StringBuffer();

    for (var name in colors.keys) {
      var rgb = colors[name],
          rgba = new RGBA(rgb[0], rgb[1], rgb[2], 1),
          node = new Ident(name, rgba);
      scope.add(node);
    }

    var modesList = modes();
    for (var name in modesList.keys) {
      var mode = modesList[name],
          function = (color1, color2) {
            var r = mode(color1.r, color2.r),
                g = mode(color1.g, color2.g),
                b = mode(color1.b, color2.b),
                a = color1.a + color2.a * (1 - color1.a);
            return new RGBA(r, g, b, a);
          };

      scope.add(new Ident(name, function));
    }

    var modifiersList = modifiers();
    for (var name in modifiersList.keys) {
      var modifier = modifiersList[name];
      scope.add(new Ident(name, modifier));
    }
  }

  lookup(name) {
    var i = stack.length,
        needle;

    while (i-- > 0) {
      if ((needle = stack[i].lookup(name)) != null) {
        return needle;
      }
    }
    return null;
  }

  Scope get scope => stack.last;

  String get indent {
    if (compress > 4) {
      return '';
    }
    return times(times(' ', _spaces), indents);
  }
}

String times(s, n) {
  var sb = new StringBuffer();
  for(int i = 0; i < n; i++) {
    sb.write(s);
  }
  return sb.toString();
}
