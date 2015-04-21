library auction_imports;

export 'dart:convert';
export 'dart:html';
export 'dart:async';
export 'dart:math';

export 'package:polymer/polymer.dart';
export 'package:redstone_mapper/mapper.dart' hide Range;
export 'package:intl/intl.dart';
export 'package:pump/pump.dart';

export 'auction.dart';
export 'search_result.dart';

export 'auction_buy_confirm/auction_buy_confirm.dart';
export 'auction_search/auction_search.dart';

import '../../configs.dart';

String serverAddress = "http://${Configs.utilServerAddress}";