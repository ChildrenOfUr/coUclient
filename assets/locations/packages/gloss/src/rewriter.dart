library rewriter;

typedef num Block(List<String> token, num i, List<List<String>> tokens);

typedef bool Condition(List<String> token, num i);

typedef void Action(List token, num i);

class Rewriter {
  List<List<String>> _tokens;

  static final  EXPRESSION_START = ['{', 'indent'],
                 EXPRESSION_END = ['}', 'outdent'],
                 LINEBREAKS = ['newline', 'indent', 'outdent'];

  Rewriter(this._tokens);

  List rewrite() {
    return _addImplicitBraces()
           ._tokens;
  }

  Rewriter _scan(Block block) {
    var i = 0;
    while (i < _tokens.length) {
      var token = _tokens[i];
      i += block(token, i, _tokens);
    }
    
    return this;
  }

  Rewriter _addImplicitBraces() {
    var stack = [],
        sameLine = true;

    Condition condition = (token, i) {
      var tag = token[0];
      if (LINEBREAKS.contains(tag)) {
        sameLine = false;
      }
      
      return (tag == 'newline' || tag == 'outdent') && sameLine;
    };
    
    Action action = (token, i) {
      var tok = ['}'];
      _tokens.insert(i, tok);
    };

    return _scan((token, i, tokens) {
      var tag = token[0];

      if (EXPRESSION_START.contains(tag)) {
        stack.add([(tag == 'indent' && tokens[i - 1][0] == '{' ? '{' : tag), i]);
        return 1;
      }

      if (EXPRESSION_END.contains(tag)) {
        stack.removeRange(0, 1);
        return 1;
      }

      if (!((tag == 'ident' || tag == 'dimension' || tag == ':') && stack.length > 0 && stack[stack.length - 1][0] != '{')) {
        return 1;
      }

      sameLine = true;
      stack.add(['{']);
      var tok = ['{'];
      tokens.insert(i - 1, tok);

      _detectEnd(i + 2, condition, action);
      return 1;
    });
  }

  void _detectEnd(num i, Condition condition, Action action) {
    var levels = 0;
    while (i < _tokens.length) {
      var token = _tokens[i];
      if (levels == 0 && condition(token, i)) {
        return action(token, i);
      }
      if (levels < 0) {
        return action(token, i);
      }
      if (EXPRESSION_START.contains(token[0])) {
        ++levels;
      } else if (EXPRESSION_END.contains(token[0])) {
        --levels;
      }
      
      ++i;
    }
  }
}

