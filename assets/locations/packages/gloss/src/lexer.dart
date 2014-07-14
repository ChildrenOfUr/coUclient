library lexer;

import 'rewriter.dart';

class Lexer {
  String _str;
  List<num> _indents = [];
  List _stash = [];

  final Map<String,RegExp> _rules = {
    'ident': new RegExp('^-?[_a-zA-Z\$-]+'),
    'atkeyword': new RegExp('^@(-?[_a-zA-Z\$-]+)'),
    'string': new RegExp('^"([^"]*)"|^\'([^\']*)\''),
    'hash': new RegExp(r'^#[_a-zA-Z0-9\$-]+'),
    'klass': new RegExp(r'^\.[_a-zA-Z\$-]+'),
    'dimension': new RegExp(r'^(-?[0-9]*\.?[0-9]+)([a-zA-Z]+|%)?'),
    'url': new RegExp(r'^url\(([^\)]+)\)'),
    'space': new RegExp(r'^[ \t]+'),
    'indentation': new RegExp(r'^\n( *)'),
    'comment': new RegExp(r'^\/\*(?:[^*]|\*+[^\/*])*\*+\/\n?|^\/\/.*'),
    'matching': new RegExp('^[~^\$*|]='),
    'function': new RegExp(r'^(-?[_a-zA-Z\$-]+)\('),
    'operator': new RegExp(r'^[-+*\/%]|^[~,>:=&]'),
    'important': new RegExp('^! *important'),
    'brace': new RegExp(r'^[{}\[\]]'),
    'paren': new RegExp('^[()]'),
    'sep': new RegExp('^;')
  };
  

  Lexer(this._str);

  Match _match(type) => _rules[type].firstMatch(_str);

  List tokenize() {
    var tokens = [];

    while (_str.length > 0) {
      var tok = next;
      if (tok != null) {
        tokens.add(tok);
      }
    }

    while (_stash.length > 0) {
      tokens.add(_stashed());
    }

    tokens.add(['eos']);

    return tokens;

  }

  List rewrite() {
    var rewriter = new Rewriter(tokenize());
    return rewriter.rewrite();
  }

  List get next {
    final nodes = [_stashed, _comment, _atkeyword, _important, _url, _function, _brace, _paren, _hash,
             _klass, _string, _dimension, _ident, _indentation, _space, _matching, _operator, _sep];
    
    return nodes.map((node) => node()).firstWhere((List v) => v != null, 
        orElse: (){ throw new Exception('parse error at:\n$_str'); });
  }

  void _skip(len) {
    _str = _str.substring(len is Match
      ? len.group(0).length
      : len);
  }

  List _stashed() => _stash.length > 0 ? _stash.removeAt(0) : null;

  List _indentation() {
    var match = _match('indentation');
    if (match != null) {
      _skip(match);
      var spaces = match.group(1) != null ? match.group(1).length : 0,
          prev = _indents.length > 0 ? _indents.last : 0;

      if (spaces > prev) {
        return _indent(spaces);
      }
      if (spaces < prev) {
        return _outdent(spaces);
      }

      return ['newline'];
    }
  }

  List _indent(num spaces) {
    _indents.add(spaces);
    return ['indent'];
  }

  List _outdent(num spaces) {
    while (_indents.length > 0 && _indents.last > spaces) {
      _indents.removeLast();
      _stash.add(['outdent']);
    }
    return _stashed();
  }


  List _sep() {
    var match = _match('sep');
    if (match != null) {
      _skip(match);
      return [';'];
    }
  }

  List _url() {
    var match = _match('url');
    if (match != null) {
      _skip(match);
      return ['url', match.group(1)];
    }
  }

  List _atkeyword() {
    var match = _match('atkeyword');
    if (match != null) {
      _skip(match);
      return ['atkeyword', match.group(1)];
    }
  }

  List _comment() {
    var match = _match('comment');
    if (match != null) {
      var lines = match.group(0).split('\n').length;
      _skip(match);
      return ['comment', match.group(0)];
    }
  }

  List _important() {
    var match = _match('important');
    if (match != null) {
      _skip(match);
      return ['literal', '!important'];
    }
  }

  List _function() {
    var match = _match('function');
    if (match != null) {
      _skip(match);
      return ['function', match.group(1)];
    }
  }

  List _brace() {
    var match = _match('brace');
    if (match != null) {
      _skip(1);
      return [match.group(0)];
    }
  }

  List _paren() {
    var match = _match('paren');
    if (match != null) {
      var paren = match.group(0);
      _skip(match);
      return [paren];
    }
  }

  List _hash() {
    var match = _match('hash');
    if (match != null) {
      _skip(match);
      return ['hash', match.group(0)];
    }
  }

  List _klass() {
    var match = _match('klass');
    if (match != null) {
      _skip(match);
      return ['klass', match.group(0)];
    }
  }

  List _string() {
    var match = _match('string');
    if (match != null) {
      var s = match.group(1),
        quote = match.group(0)[0];
      _skip(match);
      s = s.replaceAll('\n', '\n');
      return ['string', [s, quote]];
    }
  }

  List _dimension() {
    var match = _match('dimension');
    if (match != null) {
      _skip(match);
      return ['dimension', [match.group(1), match.group(2)]];
    }
  }

  List _ident() {
    var match = _match('ident');
    if (match != null) {
      _skip(match);
      var ident = match.group(0);
      if (ident[0] == r'$') {
        ident = ident.substring(1);
      }
      return ['ident', ident];
    }
  }

  List _operator() {
    var match = _match('operator');
    if (match != null) {
      _skip(match);
      return [match.group(0)];
    }
  }

  List _matching() {
    var match = _match('matching');
    if (match != null) {
      _skip(match);
      return ['matching', match.group(0)];
    }
  }

  List _space() {
    var match = _match('space');
    if (match != null) {
      _skip(match);
      return ['space'];
    }
  }

}
