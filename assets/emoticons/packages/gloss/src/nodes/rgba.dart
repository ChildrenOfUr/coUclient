part of nodes;

class RGBA extends Node implements Color {
  num r, g, b, a;

  RGBA(r, g, b, a) {
    this.r = clamp(r);
    this.g = clamp(g);
    this.b = clamp(b);
    this.a = clampAlpha(a);
  }

  css(env) {
    if (this.a == 1) {
      String rp = pad(r),
          gp = pad(g),
          bp = pad(b);

      if (env.compress > 0 && rp[0] == rp[1] && gp[0] == gp[1] && bp[0] == bp[1]) {
        return '#${rp[0]}${gp[0]}${bp[0]}';
      } else {
        return '#$rp$gp$bp';
      }
    } else {
      return 'rgba($r,$g,$b,${a.toStringAsFixed(3)})';
    }
  }

  static fromHSLA(HSLA hsla) {
    num h = hsla.h / 360,
        s = hsla.s / 100,
        l = hsla.l / 100,
        a = hsla.a,
        r, g, b;

    var q = l < 0.5 ? l * (s + 1) : l + s - l * s,
        p = l * 2 - q;

    hue(num h) {
      if (h < 0) ++h;
      if (h > 1) --h;
      if (h < 1 / 6) {
        return p + (q - p) * h * 6;
      }
      if (h < 1 / 2) {
        return q;
      }
      if (h < 2 / 3) {
        return p + (q - p) * (2 / 3 - h) * 6;
      }
      return p;
    }

    r = hue(h + 1 / 3);
    g = hue(h);
    b = hue(h - 1 / 3);

    r *= 255;
    g *= 255;
    b *= 255;

    return new RGBA(r, g, b, a);
  }
}

clamp(num n) => max(0, min(n, 255));

pad(num n) => n < 16 ? '0${n.toInt().toRadixString(16)}' : n.toInt().toRadixString(16);