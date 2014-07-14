//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Fri, Jun 14, 2013  9:59:15 AM
// Author: tomyeh
library rikulo_logging;

import "dart:async" show Future;
import "package:logging/logging.dart";

/** A simple implementation of [LoggerHandler].
 * You can use it to configure your root logger,
 * such as
 *
 *     new Logger("myorg").onRecord.listen(simpleLoggerHandler);
 */
void simpleLoggerHandler(LogRecord record) {
  //for better response time, do it async (since the onRecord stream is sync)
  new Future(() {
    print("${record.time}:${record.loggerName}:${record.sequenceNumber}\n"
      "${record.level}: ${record.message}");
    if (record.stackTrace != null)
      print("${record.stackTrace}");
  });
}
