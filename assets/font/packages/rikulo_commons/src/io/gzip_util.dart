//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Fri, Jun 21, 2013  5:32:15 PM
// Author: tomyeh
part of rikulo_io;

/** Deflates a list of bytes with GZIP.
 */
List<int> gzip(List<int> bytes, {int level: 6}) {
  final output = [];
  var error;
  var controller = new StreamController(sync: true);
  controller.stream
    .transform(new ZLibEncoder(level: level))
    .listen((data) => output.addAll(data),
      onError: (e) => error = e);
  controller.add(bytes);
  controller.close();
  if (error != null) throw error;
  return output; //note: it is done synchronously
}

/** Deflates a String into a list of bytes with GZIP.
 */
List<int> gzipString(String string, {Encoding encoding: UTF8, int level: 6})
=> gzip(encoding.encode(string), level: level);

/** Inflates a GZIP-ed list of bytes back to the original list of bytes.
 */
List<int> ungzip(List<int> bytes) {
  final output = [];
  var error;
  var controller = new StreamController(sync: true);
  controller.stream
    .transform(new ZLibDecoder())
    .listen((data) => output.addAll(data),
      onError: (e) => error = e);
  controller.add(bytes);
  controller.close();
  if (error != null) throw error;
  return output; //note: it is done synchronously
}

/** Inflates a GIZP-ed string back to the original string.
 */
String ungzipString(List<int> bytes, {Encoding encoding: UTF8})
=> encoding.decode(ungzip(bytes));
