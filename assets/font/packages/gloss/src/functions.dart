part of env;

modifiers() {
  var modifiers = new Map<String,Function>();

  modifiers['adjust'] = (RGBA color, String property, Dimension amount) {
    var hsla = HSLA.fromRGBA(color),
        value = amount.value;

    if (amount.unit == '%'){
      num current;
      switch (property) {
        case 'hue':
          current = hsla.h;
          break;
        case 'saturation':
          current = hsla.s;
          break;
        case 'lightness':
        case 'light':
          current = hsla.l;
          break;
        default:
          current = hsla.a;
      }
      value = (property == 'lightness' || property == 'light') && value > 0
          ? (100 - hsla.l) * value / 100
          : current * value / 100;
    }
    switch (property) {
      case 'hue':
        hsla.h += value;
        break;
      case 'saturation':
        hsla.s += value;
        break;
      case 'lightness':
      case 'light':
        hsla.l += value;
        break;
      default:
        hsla.a += value;
    }
    return RGBA.fromHSLA(hsla);
  };

  modifiers['saturate'] = (color, amount) {
    return modifiers['adjust'](color, 'saturation', amount);
  };

  modifiers['desaturate'] = (color, amount) {
    amount.value *= -1;
    return modifiers['adjust'](color, 'saturation', amount);
  };

  modifiers['lighten'] = (color, amount) {
    return modifiers['adjust'](color, 'lightness', amount);
  };

  modifiers['darken'] = (color, amount) {
    amount.value *= -1;
    return modifiers['adjust'](color, 'lightness', amount);
  };

  modifiers['fadein'] = (color, amount) {
    return modifiers['adjust'](color, 'alpha', amount);
  };

  modifiers['fadeout'] = (color, amount) {
    amount.value *= -1;
    return modifiers['adjust'](color, 'alpha', amount);
  };

  return modifiers;
}

modes() {
  var modes = new Map<String,Function>();

  modes['multiply'] = (a, b) => (a * b) / 255;

  modes['average'] = (a, b) => (a + b) / 2;

  modes['add'] = (a, b) => min(255, a + b);

  modes['substract'] = (a, b) => (a + b < 255) ? 0 : a + b - 255;

  modes['difference'] = (a, b) => (a - b).abs();

  modes['negation'] = (a, b) => 255 - (255 - a - b).abs();

  modes['screen'] = (a, b) => 255 - (((255 - a) * (255 - b)).toInt() >> 8);

  modes['exclusion'] = (a, b) => a + b - 2 * a * b / 255;

  modes['overlay'] = (a, b) => b < 128
      ? 2 * a * b / 255
      : 255 - 2 * (255 - a) * (255 - b) / 255;

  modes['softlight'] = (a, b) => b < 128
      ? (2 * ((a >> 1) + 64)) * (b / 255)
      : 255 - 2 * (255 - (( a >> 1) + 64)) * (255 - b) / 255;

  modes['hardlight'] = (a, b) => modes['overlay'](b, a);

  modes['colordodge'] = (a, b) => b == 255 ? b : min(255, ((a << 8 ) / (255 - b)));

  modes['colorburn'] = (a, b) => b == 0 ? b : max(0, (255 - ((255 - a).toInt() << 8 ) / b));

  modes['lineardodge'] = (a, b) => modes['add'](a, b);

  modes['linearburn'] = (a, b) => modes['substract'](a, b);

  modes['linearlight'] = (a, b) => b < 128
      ? modes['linearburn'](a, 2 * b)
      : modes['lineardodge'](a, (2 * (b - 128)));

  modes['vividlight'] = (a, b) => b < 128
      ? modes['colorburn'](a, 2 * b)
      : modes['colordodge'](a, (2 * (b - 128)));

  modes['pinlight'] = (a, b) => b < 128
        ? modes['darken'](a, 2 * b)
        : modes['lighten'](a, (2 * (b - 128)));

  modes['hardmix'] = (a, b) => modes['vividlight'](a, b) < 128 ? 0 : 255;

  modes['reflect'] = (a, b) => b == 255 ? b : min(255, (a * a / (255 - b)));

  modes['glow'] = (a, b) => modes['reflect'](b, a);

  modes['phoenix'] = (a, b) => min(a, b) - max(a, b) + 255;

  return modes;
}