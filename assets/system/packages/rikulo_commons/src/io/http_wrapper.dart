//Copyright (C) 2013 Potix Corporation. All Rights Reserved.
//History: Tue, Jan 08, 2013  6:46:38 PM
// Author: tomyeh
part of rikulo_io;

/**
 * The HTTP request wrapper.
 */
class HttpRequestWrapper extends StreamWrapper<List<int>> implements HttpRequest {
  HttpRequestWrapper(HttpRequest origin): super(origin);

  ///The original HTTP request
  HttpRequest get origin => super.origin as HttpRequest;

  @override
  int get contentLength => origin.contentLength;
  @override
  bool get persistentConnection => origin.persistentConnection;
  @override
  String get method => origin.method;
  @override
  Uri get uri => origin.uri;
  @override
  HttpHeaders get headers => origin.headers;
  @override
  List<Cookie> get cookies => origin.cookies;
  @override
  X509Certificate get certificate => origin.certificate;
  @override
  HttpSession get session => origin.session;
  @override
  HttpResponse get response => origin.response;
  @override
  String get protocolVersion => origin.protocolVersion;
  @override
  HttpConnectionInfo get connectionInfo => origin.connectionInfo;

  String toString() => origin.toString();
}

/**
 * The HTTP response wrapper.
 */
class HttpResponseWrapper extends IOSinkWrapper implements HttpResponse {
  HttpResponseWrapper(HttpResponse origin): super(origin);

  ///The original HTTP response
  HttpResponse get origin => super.origin as HttpResponse;

  @override
  int get contentLength => origin.contentLength;
  @override
  void set contentLength(int contentLength) {
    origin.contentLength = contentLength;
  }

  @override
  int get statusCode => origin.statusCode;
  @override
  void set statusCode(int statusCode) {
    origin.statusCode = statusCode;
  }

  @override
  String get reasonPhrase => origin.reasonPhrase;
  @override
  void set reasonPhrase(String reasonPhrase) {
    origin.reasonPhrase = reasonPhrase;
  }

  @override
  bool get persistentConnection => origin.persistentConnection;
  @override
  void set persistentConnection(bool persistentConnection) {
    origin.persistentConnection = persistentConnection;
  }
  @override
  Duration get deadline => origin.deadline;
  @override
  void set deadline(Duration deadline) {
    origin.deadline = deadline;
  }

  @override
  HttpHeaders get headers => origin.headers;
  @override
  List<Cookie> get cookies => origin.cookies;

  @override
  Future redirect(Uri location, {int status: HttpStatus.MOVED_TEMPORARILY})
  => origin.redirect(location, status: status);

  @override
  Future<Socket> detachSocket() => origin.detachSocket();
  @override
  HttpConnectionInfo get connectionInfo => origin.connectionInfo;
}

/** A skeletal implementation for buffered HTTP response
 */
abstract class _BufferedResponse extends HttpResponseWrapper {
  _BufferedResponse(HttpResponse origin): super(origin);

  @override
  Future<HttpResponse> addStream(Stream<List<int>> stream) {
    final completer = new Completer();
    stream.listen((data) {add(data);})
      ..onDone(() {
        completer.complete(this);
      })
      ..onError((err) {
        completer.completeError(err);
      });
    return completer.future;
  }
  @override
  Future close() {
    _closer.complete(this);
    return done;
  }
  @override
  Future<HttpResponse> get done => _closer.future.then((_) => this);

  //Used for implementing [close] and [done]//
  Completer get _closer => _$closer != null ? _$closer: (_$closer = new Completer());
  Completer _$closer;
}

/** A buffered HTTP response that stores the output in the given string buffer
 * rather than the original `HttpResponse` instance.
 */
class StringBufferedResponse extends _BufferedResponse {
  ///The buffer for holding the output (instead of [origin])
  final StringBuffer buffer;
  StringBufferedResponse(HttpResponse origin, this.buffer): super(origin);

  @override
  void add(List<int> data) {
    buffer.write(encoding.decode(data));
  }
  @override
  void write(Object obj) {
    buffer.write(obj);
  }
}

/** A buffered HTTP response that stores the output in the given list of bytes
 * buffer rather than the original `HttpResponse` instance.
 */
class BufferedResponse extends _BufferedResponse {
  ///The buffer for holding the output (instead of [origin]).
  ///It is a list of bytes.
  final List<int> buffer;
  BufferedResponse(HttpResponse origin, this.buffer): super(origin);

  @override
  void add(List<int> data) {
    buffer.addAll(data);
  }
  @override
  void write(Object obj) {
    if (obj is int)
      buffer.add(obj);
    else if (obj is String)
      buffer.addAll(encoding.encode(obj));
    else
      throw new ArgumentError("Unsupported object: $obj");
  }
}

/**
 * The HTTP headers wrapper.
 */
class HttpHeadersWrapper extends HttpHeaders {
  ///The original HTTP headers
  final HttpHeaders origin;

  HttpHeadersWrapper(this.origin);

  @override
  List<String> operator[](String name) => origin[name];
  @override
  String value(String name) => origin.value(name);
  @override
  void add(String name, Object value) {
    origin.add(name, value);
  }
  @override
  void set(String name, Object value) {
    origin.set(name, value);
  }
  @override
  void remove(String name, Object value) {
    origin.remove(name, value);
  }
  @override
  void removeAll(String name) {
    origin.removeAll(name);
  }
  @override
  void forEach(void f(String name, List<String> values)) {
    origin.forEach(f);
  }
  @override
  void noFolding(String name) {
    origin.noFolding(name);
  }
  @override
  DateTime get date => origin.date;
  @override
  void set date(DateTime date) {
    origin.date = date;
  }
  @override
  DateTime get expires => origin.expires;
  @override
  void set expires(DateTime expires) {
    origin.expires = expires;
  }
  @override
  DateTime get ifModifiedSince => origin.ifModifiedSince;
  @override
  void set ifModifiedSince(DateTime ifModifiedSince) {
    origin.ifModifiedSince = ifModifiedSince;
  }
  @override
  String get host => origin.host;
  @override
  void set host(String host) {
    origin.host = host;
  }
  @override
  int get port => origin.port;
  @override
  void set port(int port) {
    origin.port = port;
  }
  @override
  ContentType get contentType => origin.contentType;
  @override
  void set contentType(ContentType contentType) {
    origin.contentType = contentType;
  }
}
