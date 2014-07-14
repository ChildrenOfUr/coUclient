library watch;

import 'dart:io';
import 'dart:async';
import 'package:path/path.dart' as path;

class Watch {
  Stream _stream;

  Watch (String path) {
    var streamController = new StreamController();
    _stream = streamController.stream;

    new Directory(path).list(recursive: true).listen((entity) {
      if (entity is File) {
        entity.watch().listen((event) => streamController.add(event));
      }
    });
  }

  Stream match(String extension) {
    return _stream.where((event) {
      return !event.isDirectory && path.extension(event.path) == extension;
    });
  }
}
