//Copyright (c) 2014 The Polymer Project Authors. All rights reserved.
//This code may only be used under the BSD style license found at http://polymer.github.io/LICENSE.txt
//The complete set of authors may be found at http://polymer.github.io/AUTHORS.txt
//The complete set of contributors may be found at http://polymer.github.io/CONTRIBUTORS.txt
//Code distributed by Google as part of the polymer project is also
//subject to an additional IP rights grant found at http://polymer.github.io/PATENTS.txt

/**
 * @group Polymer Core Elements
 *
 * core-xhr can be used to perform XMLHttpRequests.
 *
 *     <core-xhr id="xhr"></core-xhr>
 *     ...
 *     this.$.xhr.request({url: url, params: params, callback: callback});
 *
 * @element core-xhr
 */
@HtmlImport('core_xhr_dart_nodart.html')
library core_elements.core_xhr_dart;

import 'dart:html';

import 'package:polymer/polymer.dart';
import 'package:quiver/core.dart';
import 'package:quiver/strings.dart';

typedef void ResponseHandler(response, HttpRequest req);

@CustomTag('core-xhr-dart')
class CoreXhr extends PolymerElement {

  static const _bodyMethods = const ['POST', 'PUT', 'PATCH', 'DELETE'];

  CoreXhr.created() : super.created();

  /**
   * Sends a HTTP request to the server and returns the XHR object.
   *
   * String [url] The url to which the request is sent.
   * String [method] The HTTP method to use, default is GET.
   * boolean [sync] By default, all requests are sent asynchronously. To send synchronous requests, set to true.
   * Object [params] Data to be sent to the server.
   * Object [body] The content for the request body for POST method.
   * Object [headers] HTTP request headers.
   * String [responseType] The response type. Default is 'text'.
   * boolean [withCredentials] Whether or not to send credentials on the request. Default is false.
   * Object [callback] Called when request is completed.
   * returns [HttpRequest] object.
   */
  HttpRequest request({
      String url,
      String method,
      bool sync,
      Map params,
      body,
      headers,
      String responseType,
      bool withCredentials,
      ResponseHandler callback}) {

    HttpRequest xhr = new HttpRequest();
    method = isBlank(method) ? 'GET' : method;
    bool async = (sync != true);

    String paramsString = _toQueryString(params);
    if (!isBlank(paramsString) && method.toUpperCase() == 'GET') {
      url += (url.indexOf('?') > 0 ? '&' : '?') + paramsString;
    }
    var xhrParams = _isBodyMethod(method)
        ? firstNonNull(body, paramsString)
        : null;

    xhr.open(method, url, async: async);

    if (!isBlank(responseType)) {
      xhr.responseType = responseType;
    }
    if (withCredentials == true) {
      xhr.withCredentials = true;
    }
    this._makeReadyStateHandler(xhr, callback);
    this._setRequestHeaders(xhr, headers);
    xhr.send(xhrParams);
    if (!async) {
      // TODO: make this work in Dart
//          xhr.onreadystatechange(xhr);
    }
    return xhr;
  }

  String _toQueryString(Map params) {
    var r = [];
    for (var n in params.keys) {
      var v = params[n];
      n = Uri.encodeComponent('$n');
      r.add(v == null ? n : ('$n=${Uri.encodeComponent('$v')}'));
    }
    return r.join('&');
  }

  _isBodyMethod(String method) => _bodyMethods.contains(method);

  _makeReadyStateHandler(HttpRequest xhr, ResponseHandler callback) {
    xhr.onReadyStateChange.listen((_) {
      if (xhr.readyState == 4) {
        if (callback != null) callback(xhr.response, xhr);
      }
    });
  }

  _setRequestHeaders(HttpRequest xhr, Map headers) {
    if (headers != null) {
      for (var name in headers.keys) {
        xhr.setRequestHeader(name, headers[name]);
      }
    }
  }

}
