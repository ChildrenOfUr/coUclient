part of nodes;

Map coercion = {
  'mm': {
    'cm': 10,
    'in': 25.4
  },
  'cm': {
    'mm': 1 / 10,
    'in': 2.54
  },
  'in': {
    'mm': 1 / 25.4,
    'cm': 1 / 2.54
  },
  'ms': {
    's': 1000
  },
  's': {
    'ms': 1 / 1000
  },
  'rad': {
    'deg': PI / 180
  },
  'deg': {
    'rad': 180 / PI
  }
};

class Dimension extends Node {
  num value;
  String unit;

  Dimension(value, [unit]) {
    this.value = value is num ? value : double.parse(value);
    this.unit = unit != null ? unit : '';
  }

  parse(num n) {
    var i = n.toInt();
    if (i == n) {
      return i;
    } else {
      return n;
    }
  }

  operate(String op, Dimension other) {
    if ((op == '-' || op == '+') && other.unit == '%') {
      other.value = value * (other.value / 100);
    } else {
      other = coerce(other);
    }
    return new Dimension(calc(op, value, other.value),
                         unit != '' ? unit : other.unit );
  }

  coerce(other) {
    if (other is Dimension) {
      var multiplier = 1;
      if (coercion[unit] != null && coercion[unit][other.unit] != null) {
        multiplier = coercion[unit][other.unit];
      }
      return new Dimension(other.value * multiplier, unit != '' ? unit : other.unit);
    }
    return new Dimension(double.parse(other), this.unit);
  }

  calc(String op, num a, num b) {
    switch (op) {
      case '+':
        return a + b;
      case '-':
        return a - b;
      case '*':
        return a * b;
      case '/':
      case '%':
        return a / b;
    }
  }

  css(env) {
    var n = parse(this.value);

    if (env.compress > 0) {
      var isFloat = n != (n ~/ 1);

      if (unit != '%' && n == 0) {
        return '0';
      }

      if (isFloat && n < 1 && n > -1) {
        return '${n.toString().replaceFirst('0.', '.')}$unit';
      }
    }

    return '$n$unit';
  }
}


