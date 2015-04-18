//Copyright (c) 2014 The Polymer Project Authors. All rights reserved.
//This code may only be used under the BSD style license found at http://polymer.github.io/LICENSE.txt
//The complete set of authors may be found at http://polymer.github.io/AUTHORS.txt
//The complete set of contributors may be found at http://polymer.github.io/CONTRIBUTORS.txt
//Code distributed by Google as part of the polymer project is also
//subject to an additional IP rights grant found at http://polymer.github.io/PATENTS.txt

//<polymer-element name="core-ajax" attributes="url handleAs auto params response method headers body contentType withCredentials">

@HtmlImport('core_ajax_dart_nodart.html')
library core_elements.core_ajax_dart;

import 'dart:convert' show JSON;
import 'dart:async';
import 'dart:html';

import 'package:logging/logging.dart';
import 'package:polymer/polymer.dart';
import 'package:quiver/core.dart';
import 'package:quiver/strings.dart';

import 'core_xhr_dart.dart';

@CustomTag('core-ajax-dart')
class CoreAjax extends PolymerElement {

  static const _onCoreResponse = const EventStreamProvider('core-response');
  static const _onCoreComplete = const EventStreamProvider('core-complete');
  static const _onCoreError = const EventStreamProvider('core-error');

  CoreXhr xhr;
  PolymerJob _goJob;
// TODO: enable xhrArgs
//  var xhrArgs;

  CoreAjax.created() : super.created() {
    logger.fine('CoreAjax.created');
    this.xhr = document.createElement('core-xhr-dart');
  }

  factory CoreAjax() => document.createElement('core-ajax-dart');

  /**
   * Fired when a response is received.
   */
  Stream<CustomEvent> get onCoreResponse => _onCoreResponse.forElement(this);

  /**
   * Fired when an error is received.
   */
  Stream<CustomEvent> get onCoreComplete => _onCoreComplete.forElement(this);

  /**
   * Fired whenever a response or an error is received.
   */
  Stream<CustomEvent> get onCoreError => _onCoreError.forElement(this);

  final Logger logger = new Logger('polymer.core_elements.core_ajax_dart');

  /**
   * The URL target of the request.
   */
  @published
  String url;

  /**
   * Specifies what data to store in the `response` property, and
   * to deliver as `event.response` in `response` events.
   *
   * One of:
   *
   *    `text`: uses `XHR.responseText`.
   *
   *    `xml`: uses `XHR.responseXML`.
   *
   *    `json`: uses `XHR.responseText` parsed as JSON.
   *
   *    `arraybuffer`: uses `XHR.response`.
   *
   *    `blob`: uses `XHR.response`.
   *
   *    `document`: uses `XHR.response`.
   */
  @published
  String handleAs = 'text';

  /**
   * If true, automatically performs an Ajax request when either `url` or `params` changes.
   */
  @published
  bool auto = false;

  /**
   * Parameters to send to the specified URL, as JSON string or Map object.
   */
  @published
  var params = '';

  /**
   * The response for the current request, or null if it hasn't completed yet or
   * the request resulted in error.
   */
  @published
  var response;

  /**
   * The error for the current request, or null if it hasn't completed yet or
   * the request resulted in success.
   */
  @published
  var error;

  /**
   * The HTTP method to use such as 'GET', 'POST', 'PUT', or 'DELETE'.
   * Default is 'GET'.
   */
  @published
  String method = '';

  /**
   * HTTP request headers to send.
   *
   * Example:
   *
   *     <core-ajax
   *         auto
   *         url="http://somesite.com"
   *         headers='{"X-Requested-With": "XMLHttpRequest"}'
   *         handleAs="json"
   *         on-core-response="{{handleResponse}}"></core-ajax>
   */
  @published
  Map headers = null;

  /**
   * Optional raw body content to send when method === "POST".
   *
   * Example:
   *
   *     <core-ajax method="POST" auto url="http://somesite.com"
   *         body='{"foo":1, "bar":2}'>
   *     </core-ajax>
   */
  @published
  String body;

  /**
   * Content type to use when sending data.
   *
   * @default 'application/x-www-form-urlencoded'
   */
  String contentType = 'application/x-www-form-urlencoded';

  /**
   * Set the withCredentials flag on the request.
   *
   * @attribute withCredentials
   * @type boolean
   * @default false
   */
  bool withCredentials = false;

  /**
   * Whether the current request is currently loading.
   *
   * @attribute loading
   * @type boolean
   * @default false
   */
  @published
  bool loading = false;

  /**
   * The progress of the current request.
   *
   * @attribute progress
   * @type {loaded: number, total: number, lengthComputable: boolean}
   * @default {}
   */
  @published
  CoreAjaxProgress progress;

  /**
   * The currently active request.
   */
  HttpRequest activeRequest;

  void receive(response, HttpRequest xhr) {
    logger.fine('receive');
    if (this.isSuccess(xhr)) {
      this.processResponse(xhr);
    } else {
      this.processError(xhr);
    }
    this.complete(xhr);
  }

  bool isSuccess(HttpRequest xhr) {
    var status = xhr.status;
    return (status == null || status == 0) || (status >= 200 && status < 300);
  }

  void processResponse(xhr) {
    var response = this.evalResponse(xhr);
    if (xhr == this.activeRequest) {
      this.response = response;
      loading = false;
    }
    this.fire('core-response', detail: {'response': response, 'xhr': xhr});
  }


  void processError(xhr) {
    var response = evalResponse(xhr);
    var error = {
      'statusCode': xhr.status,
      'response': response,
    };
    if (xhr == this.activeRequest) {
      this.error = error;
    }
    this.fire('core-error', detail: {'response': error, 'xhr': xhr});
  }

  void processProgress(ProgressEvent progress, HttpRequest xhr) {
    if (!identical(xhr, activeRequest)) return;
    this.progress = new CoreAjaxProgress(loaded: progress.loaded,
        total: progress.total, lengthComputable: progress.lengthComputable);
  }

  complete(xhr) {
    if (!identical(xhr, activeRequest)) return;
    this.fire('core-complete', detail: {'response': xhr.status, 'xhr': xhr});
  }

  evalResponse(xhr) {
    switch (handleAs) {
      case 'xml':
        return xmlHandler(xhr);
      case 'json':
        return jsonHandler(xhr);
      case 'document':
        return documentHandler(xhr);
      case 'blob':
        return blobHandler(xhr);
      case 'arraybuffer':
        return arraybufferHandler(xhr);
      default:
        return textHandler(xhr);
    }
  }

  xmlHandler(HttpRequest xhr) {
    return xhr.responseXml;
  }

  textHandler(HttpRequest xhr) {
    return xhr.responseText;
  }

  dynamic jsonHandler(HttpRequest xhr) {
    var r = xhr.responseText;
    try {
      return JSON.decode(r);
    } catch (x) {
      logger.severe(
          'core-ajax caught an exception trying to parse response as JSON:');
      logger.severe('url: $url');
      logger.severe(x);
      return r;
    }
  }

  documentHandler(HttpRequest xhr) {
    return xhr.response;
  }

  blobHandler(HttpRequest xhr) {
    return xhr.response;
  }

  arraybufferHandler(HttpRequest xhr) {
    return xhr.response;
  }

  urlChanged() {
    if (!isBlank(this.handleAs) && url != null) {
      var ext = this.url.split('.').last;
      switch (ext) {
        case 'json':
          this.handleAs = 'json';
          break;
      }
    }
    this.autoGo();
  }

  paramsChanged() {
    this.autoGo();
  }

  bodyChanged() {
    this.autoGo();
  }

  autoChanged() {
    this.autoGo();
  }

  // TODO(sorvell): multiple side-effects could call autoGo
  // during one micro-task, use a job to have only one action
  // occur
  autoGo() {
    if (this.auto) {
      this._goJob = this.scheduleJob(this._goJob, this.go, new Duration());
    }
  }

  /**
   * Performs an Ajax request to the specified URL.
   *
   * @method go
   */
  go() {
    // TODO(justinfagnani): support xhrArgs configuration
/*
    Map args = firstNonNull(xhrArgs, {});
     //TODO(sjmiles): we may want XHR to default to POST if body is set
    var body = firstNonNull(this.body, args.body);
    var params = firstNonNull(this.params, args.params);
    if (args.params is String) {
      args.params = JSON.decode(args.params);
    }
    var headers = firstNonNull(this.headers, args.headers, {});
*/
    var params;
    if (this.params.isEmpty) params = {};
    else if (this.params is String) params = JSON.decode(this.params);
    else if (this.params is Map) params = this.params;

    var headers = firstNonNull(this.headers, {});
    if (headers is String) {
      headers = JSON.decode(headers);
    }
    var hasContentType = headers.keys.any((header) {
      return header.toLowerCase() == 'content-type';
    });
    if (!hasContentType && this.contentType != null
        && !this.contentType.isEmpty) {
      headers['Content-Type'] = this.contentType;
    }
    var responseType;
    if (this.handleAs == 'arraybuffer' || this.handleAs == 'blob' ||
        this.handleAs == 'document') {
      responseType = this.handleAs;
    }
    this.response = this.error = this.progress = null;
    this.activeRequest = url == null ? null : this.xhr.request(
        url: url,
        method: method,
        headers: headers,
        body: body,
        params: params,
        withCredentials: withCredentials,
        responseType: responseType,
        callback: this.receive
    );
    if (this.activeRequest != null) {
      loading = true;
      var request = activeRequest;
      activeRequest.on['progress'].listen((ProgressEvent e) {
        processProgress(e, request);
      });
      if (!HttpRequest.supportsProgressEvent) {
        progress = new CoreAjaxProgress(lengthComputable: false);
      }
    }
    return this.activeRequest;
  }

  void abort() {
    if (activeRequest == null) return;
    activeRequest.abort();
    activeRequest = null;
    loading = false;
    progress = null;
  }
}

class CoreAjaxProgress extends Observable {
  @observable int loaded;
  @observable int total;
  @observable bool lengthComputable;
  CoreAjaxProgress({this.loaded, this.total, this.lengthComputable});

  String toString() =>
      '{loaded: $loaded, total: $total, lengthComputable: $lengthComputable}';
}
