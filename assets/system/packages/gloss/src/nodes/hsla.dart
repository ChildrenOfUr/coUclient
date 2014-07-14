part of nodes;

class HSLA extends Node {
  num h, s, l, a;

  HSLA(h,s,l,a) {
    this.h = clampDegrees(h);
    this.s = clampPercentage(s);
    this.l = clampPercentage(l);
    this.a = clampAlpha(a);
  }

  css(env) {
    return 'hsla($h,${s.toStringAsFixed(0)},${l.toStringAsFixed(0)},a)';
  }

  static HSLA fromRGBA(RGBA rgba) {
    num r = rgba.r / 255,
        g = rgba.g / 255,
        b = rgba.b / 255,
        a = rgba.a;

    num minimal = min(min(r,g),b),
      maximal = max(max(r,g),b),
      l = (maximal + minimal) / 2,
      d = maximal - minimal,
      h, s;
    if (maximal == minimal) {
      h = 0;
    } else if (maximal == r) {
      h = 60 * (g-b) / d;
    } else if (maximal == g) {
      h = 60 * (b-r) / d + 120;
    } else if (maximal == b) {
      h = 60 * (r-g) / d + 240;
    }

    if (maximal == minimal) {
      s = 0;
    } else if (l < 0.5) {
      s = d / (2 * l);
    } else {
      s = d / (2 - 2 * l);
    }

    h %= 360;
    s *= 100;
    l *= 100;

    return new HSLA(h, s, l, a);
  }
}

clampDegrees(num n) {
  n = n % 360;
  return n >= 0 ? n : 360 + n;
}

clampPercentage(num n) => max(0, min(n, 100));

clampAlpha(num n) => max(0, min(n, 1));
