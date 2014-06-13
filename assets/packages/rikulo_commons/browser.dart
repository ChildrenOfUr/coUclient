//Copyright (C) 2012 Potix Corporation. All Rights Reserved.
//History: Mon, Mar 12, 2012  9:26:04 AM
// Author: tomyeh
library rikulo_browser;

typedef bool _BrowserMatch(RegExp regex);

/**
 * The browser.
 */
abstract class Browser {
  // all RegExp shall be lower case here
  static final RegExp _rwebkit = new RegExp(r"(webkit)[ /]([\w.]+)"),
    _rsafari = new RegExp(r"(safari)[ /]([\w.]+)"),
    _rchrome = new RegExp(r"(chrome)[ /]([\w.]+)"),
    _rmsie = new RegExp(r"(msie) ([\w.]+)"),
    _rmozilla = new RegExp(r"(mozilla)(?:.*? rv:([\w.]+))?"),
    _ropera = new RegExp(r"(opera)(?:.*version)?[ /]([\w.]+)"),
    _rios = new RegExp(r"os[ /]([\w_]+) like mac os"),
    _randroid = new RegExp(r"android[ /]([\w.]+)"),
    _rdart = new RegExp(r"[^a-z]dart[^a-z]");

  /** The browser's name. */
  String name;
  /** The browser's version. */
  double version;

  /** Whether it is Safari. */
  bool safari = false;
  /** Whether it is Chrome. */
  bool chrome = false;
  /** Whether it is Internet Explorer. */
  bool msie = false;
  /** Whether it is Firefox. */
  bool firefox = false;
  /** Whether it is WebKit-based. */
  bool webkit = false;
  /** Whether it is Opera. */
  bool opera = false;

  /** Whether it is running on iOS. */
  bool ios = false;
  /** Whether it is running on Android. */
  bool android = false;

  /** Whehter it is running on a mobile device.
   * By mobile we mean the browser takes the full screen and non-sizable.
   * If false, the browser is assumed to run on a desktop and
   * it can be resized by the user.
   */
  bool mobile = false;
  /** Whether it supports the touch gestures.
   */
  bool touch = false;

  /** Whether Dart is supported.
   */
  bool dart = false;

  /** The webkit's version if this is a webkit-based browser, or null
   * if it is not webkit-based.
   */
  double webkitVersion;
  /** The version of iOS if it is running on iOS, or null if not.
   */
  double iosVersion;
  /** The version of Android if it is running on Android, or null if not.
   */
  double androidVersion;

  Browser() {
    _initBrowserInfo();
  }

  ///Returns the user agent.
  String get userAgent;

  String toString() {
    return "$name(v$version)";
  }
  void _initBrowserInfo() {
    final String ua = userAgent.toLowerCase();
    final _BrowserMatch bm = (RegExp regex) {
      Match m = regex.firstMatch(ua);
      if (m != null) {
        name = m.group(1);
        version = _versionOf(m.group(2));
        return true;
      }
      return false;
    };

    // os detection
    Match m2;
    if ((m2 = _randroid.firstMatch(ua)) != null) {
      touch = mobile = android = true;
      androidVersion = _versionOf(m2.group(1));
    } else if ((m2 = _rios.firstMatch(ua)) != null) {
      touch = mobile = ios = true;
      iosVersion = _versionOf(m2.group(1), '_');
    }
    
    if (bm(_rwebkit)) {
      webkit = true;
      webkitVersion = version;

      if (bm(_rchrome)) {
        chrome = true;

      } else if (bm(_rsafari)) {
        safari = true;

      }
    } else if (bm(_rmsie)) {
      msie = true;
      touch = mobile = ua.indexOf("iemobile") >= 0;
    } else if (bm(_ropera)) {
      opera = true;
    } else if (ua.indexOf("compatible") < 0 && bm(_rmozilla)) {
      name = "firefox"; //rename it
      firefox = true;
    } else {
      name = "unknown";
      version = 1.0;
    }

    dart = _rdart.hasMatch(ua);
  }
  static double _versionOf(String version, [String separator='.']) {
    int j = version.indexOf(separator);
    if (j >= 0) {
      j = version.indexOf(separator, j + 1);
      if (j >= 0)
        version = version.substring(0, j);
    }
    try {
      return double.parse(version);
    } catch (e) {
      return 1.0; //ignore it
    }
  }
}
