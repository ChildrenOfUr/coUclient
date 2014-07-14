library gloss;

import 'src/env.dart';
import 'src/parser.dart';

class Gloss {
  static String parse(String str) {
    var parser = new Parser(str),
        env = new Env(),
        ast = parser.parse(),
        css = ast.eval(env)
                 .css(env);

    return css;
  }
}