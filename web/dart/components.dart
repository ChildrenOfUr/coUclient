part of coUclient;

class Position extends ComponentPoolable {
  num x, y, z;
  Position._();
  factory Position(num x, num y, num z) {
    Position position = new Poolable.of(Position, _constructor);
    position.x = x;
    position.y = y;
    position.z = z;
    return position;
  }
  static Position _constructor() => new Position._();
}

class Velocity extends ComponentPoolable {
  num angle, num velocity;
  Velocity._();
  factory Velocity(num angle, num velocity) {
    Velocity velocity = new Poolable.of(Velocity, _constructor);
    velocity.angle = angle;
    velocity.velocity = velocity;
    return position;
  }
  static Velocity _constructor() => new Velocity._();
}

class StaticSprite extends ComponentPoolable {
  ImageElement image, int width, int height ;
  StaticSprite._();
  factory StaticSprite(ImageElement image, int width, int height) {
    StaticSprite sprite = new Poolable.of(StaticSprite, _constructor);
    sprite.image = image;
    sprite.width = width;
    sprite.height = height;
    return position;
  }
  static StaticSprite _constructor() => new StaticSprite._();
}