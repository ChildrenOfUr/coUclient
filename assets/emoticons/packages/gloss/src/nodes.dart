library nodes;

import 'dart:math';

part 'scope.dart';

part 'shorthands.dart';

part 'nodes/arguments.dart';
part 'nodes/atrule.dart';
part 'nodes/binop.dart';
part 'nodes/block.dart';
part 'nodes/call.dart';
part 'nodes/color.dart';
part 'nodes/comment.dart';
part 'nodes/declaration.dart';
part 'nodes/definition.dart';
part 'nodes/dimension.dart';
part 'nodes/expression.dart';
part 'nodes/hsla.dart';
part 'nodes/ident.dart';
part 'nodes/literal.dart';
part 'nodes/null.dart';
part 'nodes/params.dart';
part 'nodes/rgba.dart';
part 'nodes/ruleset.dart';
part 'nodes/selector.dart';
part 'nodes/str.dart';
part 'nodes/stylesheet.dart';

class Node {
  Node eval(env) => this;
  String css(env) => '';
}
