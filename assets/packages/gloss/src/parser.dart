library parser;

import 'lexer.dart';
import 'nodes.dart';

class Parser {
  List<String> _state = ['stylesheet'];
  List<List> _stash = [], _tokens;
  Stylesheet _root;
  num _parens = 0;
  bool _operand = false;

  List _selectorTokens = [
    'ident',
    'string',
    'function',
    'comment',
    'space',
    'hash',
    'klass',
    'dimension',
    'matching',
    '[',
    ']',
    '(',
    ')',
    '+',
    '>',
    '*',
    ':',
    '&',
    '~'
  ];

  Parser(str) {
    this._tokens = new Lexer(str).rewrite();
    this._root = new Stylesheet();
  }

  String get _currentState => _state.last;

  Stylesheet parse() {
    var block = _root;
    while (peek[0] != 'eos') {
      if (_accept('newline') != null) {
        continue;
      }
      var smt = _statement();
      _accept(';');
      if (smt == null) {
        _error('unexpected token {peek}, not allowed at the root level');
      }
      block.push(smt);
    }
    return block;
  }

  void _error(msg) {
    throw new Exception(msg.replaceAll('{peek}', '"${peek[0]}"'));
  }

  List<Object> get peek => _stash.length > 0 ? _stash.last : _tokens[0];

  List get next {
    var tok = _stash.length > 0
      ? _stash.removeLast()
      : _tokens.removeAt(0);

    return tok;
  }

  List<Object> _accept(tag) {
    if (peek[0] == tag) {
      return next;
    }
  }

  List<Object> _expect(tag) {
    if (peek[0] != tag) {
      _error('expected "$tag", got {peek}');
    }
    return next;
  }

  List<Object> lookahead(n) => _tokens[--n];

  bool _lineContains(tag) {
    var i = 1;

    while (i++ < _tokens.length) {
      var la = lookahead(i++);
      if (['indent', 'outdent', 'newline'].contains(la[0])) {
        return false;
      }
      if (la[0] == tag) {
        return true;
      }
    }
    return false;
  }

  void _skipWhitespace() {
    while (['space', 'indent', 'outdent', 'newline'].contains(peek[0])) {
      next;
    }
  }

  void _skipNewlines() {
    while (peek[0] == 'newline') {
      next;
    }
  }

  void _skipSpaces() {
    while (peek[0] == 'space') {
      next;
    }
  }

  bool _looksLikeDefinition(int i) {
    return lookahead(i)[0] == 'indent'
          || lookahead(i)[0] == '{';
  }

  bool _isSelectorToken(int i) {
    var la = lookahead(i)[0];
    
    return _selectorTokens.contains(la);
  }

  Node _statement() {
    var tag = peek[0];
    switch(tag) {
      case 'dimension':
        return _dimension();
      case 'atkeyword':
        return _atkeyword();
      case 'ident':
        return _ident();
      case 'function':
        return _function();
      case 'comment':
        return _comment();
      case 'hash':
      case 'klass':
      case '~':
      case '>':
      case '+':
      case '&':
      case ':':
      case '[':
        return _selector();
      default:
        _error('unexpected {peek}');
        break;
    }
  }

  Ruleset _selector() {
    var ruleset = new Ruleset();

    do {
      List selector = [];
      _accept('newline');
      while(_isSelectorToken(1)) {
        var tok = next;
        switch(tok[0]) {
          case 'hash':
          case 'klass':
          case 'ident':
          case 'matching':
            selector.add(tok[1]);
            break;
          case 'function':
            selector.add("${tok[1]}(");
            break;
          case 'dimension':
            selector.add("${tok[1][0]}${tok[1][1]}");
            break;
          case 'string':
            selector.add(tok[1][0]);
            break;
          case 'space':
            selector.add(" ");
            break;
          case 'comment':
            break;
          default:
            selector.add(tok[0]);
            break;
        }
        _accept('newline');
      }
      ruleset.push(new Selector(selector));
    } while (_accept(',') != null || _accept('newline') != null);

    _state.add('selector');
    ruleset.block = _block();
    _state.removeLast();

    return ruleset;
  }

  Block _block() {
    var block = new Block();

    _skipNewlines();
    _accept('{');
    _skipWhitespace();

    while (peek[0] != '}') {
      if (_accept('newline') != null) {
        continue;
      }
      var statement = _statement();
      _accept(';');
      _skipWhitespace();
      if (statement == null) {
        _error('unexpected token {peek} in block');
      }
      block.push(statement);
    }

    _expect('}');
    _accept('outdent');
    _skipSpaces();
    return block;
  }

  Ruleset _dimension() {
    var ruleset = new Ruleset();

    do {
      _accept('newline');
      ruleset.push(new Selector(next[1]));
    } while (_accept(',') != null);

    _state.add('selector');
    ruleset.block = _block();
    _state.removeLast();

    return ruleset;
  }

  Atrule _atkeyword() {
    var keyword = '@${next[1]}';
    var atrule = new Atrule(keyword);
    _state.add('atrule');
    atrule.expression = _list();
    if (peek[0] == '{') {
      atrule.block = _block();
    }
    _state.removeLast();
    return atrule;
  }

  Node _ident() {
    var i = 2;
    var la = lookahead(i)[0];

    while (la == 'space') {
      la = lookahead(++i)[0];
    }

    switch (la) {
      case '=':
        return _assignment();
      case '-':
      case '+':
      case '/':
      case '*':
      case '%':
        switch (_currentState) {
          case 'selector':
          case 'atrule':
            return _declaration();
        }
        break;
      case '{':
        if (_currentState == 'expression') {
          return new Ident(next[1]);
        }
        return _selector();
      default:
        switch (_currentState) {
          case 'stylesheet':
            return _selector();
          case 'selector':
          case 'function':
          case 'atrule':
            return _declaration();
          default:
            var tok = _expect('ident');
            _accept('space');
            return new Ident(tok[1]);
        }
        break;
    }
  }

  Node _declaration() {
    var ident = _accept('ident')[1],
        decl = new Declaration(ident),
        ret = decl;

    _accept('space');
    if (_accept(':') != null) _accept('space');

    _state.add('declaration');
    decl.value = _list();
    if (decl.value.isEmpty) {
      ret = new Ident(ident);
    }
    _state.removeLast();
    _skipSpaces();
    _accept(';');

    return ret;
  }

  Expression _list() {
    var node = _expression();
    _skipSpaces();
    while (_accept(',') != null || _accept('indent') != null) {
      if (node.isList) {
        node.push(_expression());
      } else {
        var list = new Expression(true);
        list.push(node);
        list.push(_expression());
        node = list;
      }
    }
    return node;
  }

  Node _assignment() {
    var name = _expect('ident')[1];

    _accept('space');
    _expect('=');

    _state.add('assignment');
    var expr = _list(),
        node = new Ident(name, expr);
    _state.removeLast();

    return node;
  }

  Expression _expression([bool parens]) {
    var expr = new Expression();
    Node node;

    _state.add('expression');
    if (parens != null) {
      expr.push(new Literal('('));
    }
    while ((node = _additive()) != null) {
      expr.push(node);
    }
    if (parens != null) {
      expr.push(new Literal(')'));
    }
    _state.removeLast();
    return expr;
  }

  Node _additive() {
    var node = _multiplicative();
    List op;
    _skipSpaces();
    while ((op = _accept('+')) != null || (op = _accept('-')) != null) {
      _operand = true;
      node = new Binop(op[0], node, _multiplicative());
      _operand = false;
    }
    return node;
  }

  Node _multiplicative() {
    var node = _primary();
    List op;
    _skipSpaces();
    while ((op = _accept('*')) != null
      || (op = _accept('/')) != null
      || (op = _accept('%')) != null) {
      _operand = true;
      if (op[0] == '/' && _currentState == 'expression' && _parens == 0) {
        _stash.add(['literal', '/']);
        _operand = false;
        return node;
      } else {
        if (node == null) {
          _error('illegal unary "$op", missing left-hand operand');
        }
        node = new Binop(op[0], node, _primary());
        _operand = false;
      }
    }
    return node;
  }

  Node _primary() {
    _skipSpaces();
    if (_accept('(') != null) {
      ++_parens;
      var expr = _expression(true);
      _expect(')');
      --_parens;
      if(_accept('%') != null) {
        expr.push(new Literal('%'));
      }
      return expr;
    }

    switch (peek[0]) {
      case 'dimension':
        var tok = next;
        return new Dimension(tok[1][0], tok[1][1]);
      case 'hash':
        return new Color(next[1].substring(1));
      case 'string':
        var tok = next;
        return new Str(tok[1][0], tok[1][1]);
      case 'literal':
        return new Literal(next[1]);
      case 'ident':
        return _ident();
      case 'url':
        return _url();
      case 'function':
        return _fncall();
      case ':':
        return new Literal(next[0]);
    }
  }

  Node _function() {
    var p = 1,
        i = 2,
        out = false;
    List tok;

    while ((tok = this.lookahead(i++)) != null) {
      switch (tok[0]) {
        case 'function':
        case '(':
          ++p;
          break;
        case ')':
          if (--p == 0) {
            out = true;
          }
          break;
        case 'eos':
          _error('failed to find closing paren ")"');
          break;
      }
      if (out) break;
    }
    while((tok = this.lookahead(i))[0] == 'space') {
      ++i;
    }
    switch (_currentState) {
      case 'expression':
        return _fncall();
      default:
        return _looksLikeDefinition(i)
          ? _definition()
          : _expression();
    }
  }


  // FIXME
  Node _url() {
    return new Call('url', new Arguments(false, [new Literal(next[1])]));
  }

  Definition _definition() {
    var name = _expect('function')[1];

    _state.add('params');
    _skipWhitespace();
    var params = _params();
    _skipWhitespace();
    _expect(')');
    _state.removeLast();
    _skipSpaces();
    _state.add('function');
    var f = new Definition(name, params);
    f.block = _block();
    _state.removeLast();
    return f;
  }

  Call _fncall() {
    String name = _expect('function')[1];
    _state.add('arguments');
    ++_parens;
    Arguments args = _args();
    _expect(')');
    --_parens;
    _state.removeLast();
    return new Call(name, args);
  }

  Params _params() {
    var params = new Params();
    List tok;
    Ident node;

    while ((tok = _accept('ident')) != null) {
      _accept('space');
      params.push(node = new Ident(tok[1]));
      if (_accept('=') != null) {
        node.value = _expression();
      }
      _skipWhitespace();
      _accept(',');
      _skipWhitespace();
    }
    return params;
  }

  Arguments _args() {
    var args = new Arguments();

    do {
      if (peek[0] == 'ident' && lookahead(2)[0] == '=') {
        var keyword = next[1];
        _expect('=');
        args.map[keyword] = _expression();
      } else {
        args.push(_expression());
      }
    } while (_accept(',') != null);

    return args;
  }

  _comment() {
    var node = next[1];
    _skipSpaces();
    return node;
  }

  _literal() => _expect('literal')[1];
}
