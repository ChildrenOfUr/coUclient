// Copyright (c) 2013, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Tools to help implement refactoring like transformations to Dart code.
///
/// [TextEditTransaction] supports making a series of changes to a text buffer.
/// [guessIndent] helps to guess the appropriate indentiation for the new code.
library source_maps.refactor;

import 'span.dart';
import 'printer.dart';

/// Editable text transaction.
///
/// Applies a series of edits using original location
/// information, and composes them into the edited string.
class TextEditTransaction {
  final SourceFile file;
  final String original;
  final _edits = <_TextEdit>[];

  TextEditTransaction(this.original, this.file);

  bool get hasEdits => _edits.length > 0;

  /// Edit the original text, replacing text on the range [begin] and [end]
  /// with the [replacement]. [replacement] can be either a string or a
  /// [NestedPrinter].
  void edit(int begin, int end, replacement) {
    _edits.add(new _TextEdit(begin, end, replacement));
  }

  /// Create a source map [Location] for [offset].
  Location _loc(int offset) =>
      file != null ? file.location(offset) : null;

  /// Applies all pending [edit]s and returns a [NestedPrinter] containing the
  /// rewritten string and source map information. [filename] is given to the
  /// underlying printer to indicate the name of the generated file that will
  /// contains the source map information.
  /// 
  /// Throws [UnsupportedError] if the edits were overlapping. If no edits were
  /// made, the printer simply contains the original string.
  NestedPrinter commit() {
    var printer = new NestedPrinter();
    if (_edits.length == 0) {
      return printer..add(original, location: _loc(0), isOriginal: true);
    }

    // Sort edits by start location.
    _edits.sort();

    int consumed = 0;
    for (var edit in _edits) {
      if (consumed > edit.begin) {
        var sb = new StringBuffer();
        sb..write(file.location(edit.begin).formatString)
            ..write(': overlapping edits. Insert at offset ')
            ..write(edit.begin)
            ..write(' but have consumed ')
            ..write(consumed)
            ..write(' input characters. List of edits:');
        for (var e in _edits) sb..write('\n    ')..write(e);
        throw new UnsupportedError(sb.toString());
      }

      // Add characters from the original string between this edit and the last
      // one, if any.
      var betweenEdits = original.substring(consumed, edit.begin);
      printer..add(betweenEdits, location: _loc(consumed), isOriginal: true)
             ..add(edit.replace, location: _loc(edit.begin));
      consumed = edit.end;
    }

    // Add any text from the end of the original string that was not replaced.
    printer.add(original.substring(consumed),
        location: _loc(consumed), isOriginal: true);
    return printer;
  }
}

class _TextEdit implements Comparable<_TextEdit> {
  final int begin;
  final int end;

  /// The replacement used by the edit, can be a string or a [NestedPrinter].
  final replace;

  _TextEdit(this.begin, this.end, this.replace);

  int get length => end - begin;

  String toString() => '(Edit @ $begin,$end: "$replace")';

  int compareTo(_TextEdit other) {
    int diff = begin - other.begin;
    if (diff != 0) return diff;
    return end - other.end;
  }
}

/// Returns all whitespace characters at the start of [charOffset]'s line.
String guessIndent(String code, int charOffset) {
  // Find the beginning of the line
  int lineStart = 0;
  for (int i = charOffset - 1; i >= 0; i--) {
    var c = code.codeUnitAt(i);
    if (c == _LF || c == _CR) {
      lineStart = i + 1;
      break;
    }
  }

  // Grab all the whitespace
  int whitespaceEnd = code.length;
  for (int i = lineStart; i < code.length; i++) {
    var c = code.codeUnitAt(i);
    if (c != _SPACE && c != _TAB) {
      whitespaceEnd = i;
      break;
    }
  }

  return code.substring(lineStart, whitespaceEnd);
}

const int _CR = 13;
const int _LF = 10;
const int _TAB = 9;
const int _SPACE = 32;
