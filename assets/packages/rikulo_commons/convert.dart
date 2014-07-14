//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Mon, Mar 18, 2013 11:01:44 AM
// Author: tomyeh
library rikulo_convert;

import "dart:async" show Future, Stream;
import "dart:convert";

/** Reads the entire stream as a string using the given [Encoding].
 */
Future<String> readAsString(Stream<List<int>> stream, 
    {Encoding encoding: UTF8}) {
  final List<int> result = [];
  return stream.listen((data) {
    result.addAll(data);
  }).asFuture().then((_) {
    return encoding.decode(result);
  });
}
/** Reads the entire stream as a JSON string using the given [Encoding],
 * and then convert to an object.
 */
Future<dynamic> readAsJson(Stream<List<int>> stream,
    {Encoding encoding: UTF8})
=> readAsString(stream, encoding: encoding).then((String data) => JSON.decode(data));
